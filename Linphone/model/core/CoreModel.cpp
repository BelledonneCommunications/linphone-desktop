/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "CoreModel.hpp"

#include <QApplication>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QQuickWindow>
#include <QSysInfo>
#include <QTimer>

#include "core/App.hpp"
#include "core/notifier/Notifier.hpp"
#include "core/path/Paths.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

#if defined(Q_OS_MACOS)
#include "core/event-count-notifier/EventCountNotifierMacOs.hpp"
#else
#include "core/event-count-notifier/EventCountNotifierSystemTrayIcon.hpp"
#endif // if defined(Q_OS_MACOS)

// =============================================================================
DEFINE_ABSTRACT_OBJECT(CoreModel)

std::shared_ptr<CoreModel> CoreModel::gCoreModel;

CoreModel::CoreModel(const QString &configPath, QThread *parent)
    : ::Listener<linphone::Core, linphone::CoreListener>(nullptr, parent) {
	connect(parent, &QThread::finished, this, [this]() {
		// Model thread
		if (mCore && mCore->getGlobalState() == linphone::GlobalState::On) mCore->stop();
		gCoreModel = nullptr;
	});
	mConfigPath = configPath;
	mLogger = std::make_shared<LoggerModel>(this);
	mLogger->init();
	moveToThread(parent);
}

CoreModel::~CoreModel() {
}

std::shared_ptr<CoreModel> CoreModel::create(const QString &configPath, QThread *parent) {
	if (gCoreModel) return gCoreModel;
	auto model = std::make_shared<CoreModel>(configPath, parent);
	model->setSelf(model);
	gCoreModel = model;
	return model;
}

void CoreModel::start() {
	setPathBeforeCreation();
	mCore =
	    linphone::Factory::get()->createCore(Utils::appStringToCoreString(Paths::getConfigFilePath(mConfigPath)),
	                                         Utils::appStringToCoreString(Paths::getFactoryConfigFilePath()), nullptr);
	setMonitor(mCore);
	mCore->usePreviewWindow(true);
	// Force capture/display.
	// Useful if the app was built without video support.
	// (The capture/display attributes are reset by the core in this case.)
	// if (!mCore->videoSupported()) {
	// 	config->setInt("video", "capture", 0);
	// 	config->setInt("video", "display", 0);
	// }

	mCore->enableVideoPreview(false); // SDK doesn't write the state in configuration if not ready.
	auto config = mCore->getConfig();
	QString userAgent = ToolModel::computeUserAgent(config);
	mCore->setUserAgent(Utils::appStringToCoreString(userAgent), LINPHONESDK_VERSION);
	mCore->start();
	migrate();
	setPathAfterStart();
	if (SettingsModel::clearLocalLdapFriendsUponStartup(config)) {
		// Remove ldap friends cache list. If not, old stored friends will take priority on merge and will not be
		// updated from new LDAP requests..
		auto ldapFriendList = mCore->getFriendListByName("ldap_friends");
		if (ldapFriendList) mCore->removeFriendList(ldapFriendList);
	}
	mCore->enableFriendListSubscription(true);
	if (mCore->getLogCollectionUploadServerUrl().empty())
		mCore->setLogCollectionUploadServerUrl(Constants::DefaultUploadLogsServer);

	mIterateTimer = new QTimer(this);
	mIterateTimer->setInterval(20);
	connect(mIterateTimer, &QTimer::timeout, [this]() { mCore->iterate(); });

	mIterateTimer->start();

	auto linphoneSearch = mCore->createMagicSearch();
	linphoneSearch->setLimitedSearch(true);
	mMagicSearch = Utils::makeQObject_ptr<MagicSearchModel>(linphoneSearch);
	mMagicSearch->setSelf(mMagicSearch);
	connect(mMagicSearch.get(), &MagicSearchModel::searchResultsReceived, this,
	        [this] { emit magicSearchResultReceived(mMagicSearch->mLastSearch); });
	mStarted = true;
}
// -----------------------------------------------------------------------------

bool CoreModel::isInitialized() const {
	return mStarted;
}

std::shared_ptr<CoreModel> CoreModel::getInstance() {
	return gCoreModel;
}

std::shared_ptr<linphone::Core> CoreModel::getCore() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mCore;
}

std::shared_ptr<LoggerModel> CoreModel::getLogger() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mLogger;
}

//-------------------------------------------------------------------------------
void CoreModel::setConfigPath(QString path) {
	if (mConfigPath != path) {
		mConfigPath = path;
		if (!mCore) {
			qWarning() << log().arg("Setting config path after core creation is not yet supported");
		}
	}
}

void CoreModel::refreshOidcRemainingTime() {
	for (auto oidc : mOpenIdConnections) {
		if (oidc && oidc->isTimerRunning()) {
			emit oidcRemainingTimeBeforeTimeoutChanged(oidc->getRemainingTimeBeforeTimeOut());
		}
	}
}

//-------------------------------------------------------------------------------
//				PATHS
//-------------------------------------------------------------------------------
#define SET_FACTORY_PATH(TYPE, PATH)                                                                                   \
	do {                                                                                                               \
		lInfo() << QStringLiteral("[CoreModel] Set `%1` factory path: `%2`").arg(#TYPE).arg(PATH);                     \
		factory->set##TYPE##Dir(Utils::appStringToCoreString(PATH));                                                   \
	} while (0);

void CoreModel::setPathBeforeCreation() {
	std::shared_ptr<linphone::Factory> factory = linphone::Factory::get();
	SET_FACTORY_PATH(Msplugins, Paths::getPackageMsPluginsDirPath());
	SET_FACTORY_PATH(TopResources, Paths::getPackageTopDirPath());
	SET_FACTORY_PATH(Data, Paths::getAppLocalDirPath());
	SET_FACTORY_PATH(Download, Paths::getDownloadDirPath());
	SET_FACTORY_PATH(Config, Paths::getConfigDirPath(true));
}

void CoreModel::setPathsAfterCreation() {
	// auto friendsPath = Paths::getFriendsListFilePath();
	// if (!friendsPath.isEmpty() && QFileInfo(friendsPath).exists()) {
	// 	lInfo() << log().arg("Using old friends database at %1").arg(friendsPath);
	// 	std::shared_ptr<linphone::Config> config = mCore->getConfig();
	// 	config->setString("storage", "friends_db_uri", Utils::appStringToCoreString(friendsPath));
	// }
	std::shared_ptr<linphone::Factory> factory = linphone::Factory::get();
	QString downloadFolder = SettingsModel::getInstance()->getDownloadFolder();
	if (downloadFolder.isEmpty()) downloadFolder = Paths::getDownloadDirPath();
	if (!downloadFolder.endsWith(QDir::separator())) downloadFolder.append(QDir::separator());
	SET_FACTORY_PATH(Download, (downloadFolder));
}

void CoreModel::setPathAfterStart() {
	// Use application path if Linphone default is not available
	if (mCore->getZrtpSecretsFile().empty() ||
	    !Paths::filePathExists(Utils::coreStringToAppString(mCore->getZrtpSecretsFile()), true))
		mCore->setZrtpSecretsFile(Utils::appStringToCoreString(Paths::getZrtpSecretsFilePath()));
	lInfo() << "[CoreModel] Using ZrtpSecrets path : " << QString::fromStdString(mCore->getZrtpSecretsFile());
	// Use application path if Linphone default is not available
	if (mCore->getUserCertificatesPath().empty() ||
	    !Paths::filePathExists(Utils::coreStringToAppString(mCore->getUserCertificatesPath()), true))
		mCore->setUserCertificatesPath(Utils::appStringToCoreString(Paths::getUserCertificatesDirPath()));
	lInfo() << "[CoreModel] Using UserCertificate path : " << QString::fromStdString(mCore->getUserCertificatesPath());
	// Use application path if Linphone default is not available
	QString rootCaPath = Utils::coreStringToAppString(mCore->getRootCa());
	QString relativeRootCa = Paths::getAppRootCaFilePath();
	lDebug() << "[CoreModel] Getting rootCa paths: " << rootCaPath << " VS " << relativeRootCa;
	if (!Paths::filePathExists(rootCaPath) || Paths::isSameRelativeFile(rootCaPath, relativeRootCa)) {
		lInfo() << "[CoreModel] Reset rootCa path to: " << relativeRootCa;
		mCore->setRootCa(Utils::appStringToCoreString(relativeRootCa));
	}
	lInfo() << "[CoreModel] Using RootCa path : " << QString::fromStdString(mCore->getRootCa());
}

//-------------------------------------------------------------------------------
//				FETCH CONFIG
//-------------------------------------------------------------------------------

QString CoreModel::getFetchConfig(QString filePath, bool *error) {
	*error = false;
	if (!filePath.isEmpty()) {
		if (QUrl(filePath).isRelative()) { // this is a file path
			filePath = Paths::getConfigFilePath(filePath, false);
			if (!filePath.isEmpty()) filePath = "file://" + filePath;
		}
		if (filePath.isEmpty()) {
			qWarning() << "Remote provisioning cannot be retrieved. Command have been cleaned";
			Utils::showInformationPopup(tr("info_popup_error_title"),
			                            //: "Remote provisioning cannot be retrieved"
			                            tr("fetching_config_failed_error_message"), false);
			*error = true;
		}
	}
	return filePath;
}

void CoreModel::useFetchConfig(QString filePath, bool askForConfirmation) {
	bool error = false;
	filePath = getFetchConfig(filePath, &error);
	if (!error && !filePath.isEmpty()) {

		if (mCore && mCore->getGlobalState() == linphone::GlobalState::On) {
			// TODO
			// if (mSettings->getAutoApplyProvisioningConfigUriHandlerEnabled()) setFetchConfig(filePath); else
			emit requestFetchConfig(filePath, askForConfirmation);
		} else {
			connect(
			    this, &CoreModel::globalStateChanged, this, [filePath, this]() { useFetchConfig(filePath); },
			    Qt::SingleShotConnection);
		}
	}
}

bool CoreModel::setFetchConfig(QString filePath) {
	bool fetched = false;
	qDebug() << "setFetchConfig with " << filePath;
	if (!filePath.isEmpty()) {
		if (mCore) {
			filePath.replace('\\', '/');
			QUrl url(filePath);
			fetched = mCore->setProvisioningUri(Utils::appStringToCoreString(url.toEncoded())) == 0;
		}
	}
	if (!fetched) {
		qWarning() << "Remote provisionning cannot be retrieved. Command have been cleaned";
	} else emit requestRestart();
	return fetched;
}

void CoreModel::migrate() {
	std::shared_ptr<linphone::Config> config = mCore->getConfig();
	int rcVersion = config->getInt(SettingsModel::UiSection, Constants::RcVersionName, 0);
	if (rcVersion == Constants::RcVersionCurrent) return;
	if (rcVersion > Constants::RcVersionCurrent) {
		lWarning() << log()
		                  .arg("RC file version (%1) is more recent than app rc file version (%2)!!!")
		                  .arg(rcVersion)
		                  .arg(Constants::RcVersionCurrent);
		return;
	}

	lInfo() << log().arg("Migrate from old rc file (%1 to %2).").arg(rcVersion).arg(Constants::RcVersionCurrent);
	bool setLimeServerUrl = false;
	for (const auto &account : mCore->getAccountList()) {
		auto params = account->getParams();
		auto newParams = params->clone();
		QString accountIdentity =
		    (newParams->getIdentityAddress() ? newParams->getIdentityAddress()->asString().c_str() : "no-identity");
		if (params->getDomain() == Constants::LinphoneDomain) {
			if (rcVersion < 1) {
				newParams->setContactParameters(Constants::DefaultContactParameters);
				newParams->setExpires(Constants::DefaultExpires);
				lInfo() << log().arg("Migrating") << accountIdentity
				        << "for version 1. contact parameters =" << Constants::DefaultContactParameters
				        << ", expires =" << Constants::DefaultExpires;
			}
			if (rcVersion < 2) {
				bool exists = newParams->getConferenceFactoryUri() != "";
				setLimeServerUrl = true;
				if (!exists) {
					newParams->setConferenceFactoryAddress(ToolModel::interpretUrl(Constants::DefaultConferenceURI));
				}
				lInfo() << log().arg("Migrating") << accountIdentity << "for version 2. Conference factory URI"
				        << (exists ? std::string("unchanged") : std::string("= ") + Constants::DefaultConferenceURI)
				               .c_str();
				// note: using std::string.c_str() to avoid having double quotes in qInfo()
			}
			if (rcVersion < 3) {
				newParams->enableCpimInBasicChatRoom(true);
				lInfo() << log().arg("Migrating") << accountIdentity
				        << "for version 3. Enable Cpim in basic chat rooms";
			}
			if (rcVersion < 4) {
				newParams->enableRtpBundle(true);
				lInfo() << log().arg("Migrating") << accountIdentity << "for version 4. Enable RTP bundle mode";
			}
			if (rcVersion < 5) {
				bool exists = !!newParams->getAudioVideoConferenceFactoryAddress();
				setLimeServerUrl = true;
				if (!exists)
					newParams->setAudioVideoConferenceFactoryAddress(
					    ToolModel::interpretUrl(Constants::DefaultVideoConferenceURI));
				lInfo() << log().arg("Migrating") << accountIdentity << "for version 5. Video conference factory URI"
				        << (exists ? std::string("unchanged")
				                   : std::string("= ") + Constants::DefaultVideoConferenceURI)
				               .c_str();
				// note: using std::string.c_str() to avoid having double quotes in qInfo()
			}
			if (rcVersion < 6) { // Last 5.2 (5.2.6)
				newParams->setPublishExpires(Constants::DefaultPublishExpires);
				lInfo() << log().arg("Migrating") << accountIdentity
				        << "for version 6. publish expires =" << Constants::DefaultPublishExpires;
			}
			if (rcVersion < 7) { // First 6.x
				                 // 6.x reg_route added to use/create-app-sip-account.rc files on 6.x
				if (newParams->getRoutesAddresses().empty()) {
					std::list<std::shared_ptr<linphone::Address>> routes;
					routes.push_back(ToolModel::interpretUrl(Constants::DefaultRouteAddress));
					newParams->setRoutesAddresses(routes);
					lInfo() << log().arg("Migrating") << accountIdentity
					        << "for version 7. Setting route to: " << Constants::DefaultRouteAddress;
				}
				// File transfer server URL modified to use/create-app-sip-account.rc files on 6.x
				if (mCore->getLogCollectionUploadServerUrl() == Constants::RetiredUploadLogsServer) {
					mCore->setLogCollectionUploadServerUrl(Constants::DefaultUploadLogsServer);
					lInfo() << log().arg("Migrating") << accountIdentity
					        << "for version 7. Setting Log collection upload server rul to: "
					        << Constants::DefaultUploadLogsServer;
				}
			}
		}
		if (rcVersion < 7) { // 6.x lime algo c25519 added to all 6.x rc files
			newParams->setLimeAlgo("c25519");
			lInfo() << log().arg("Migrating") << accountIdentity << "for version 7. lime algo = c25519";
		}
		account->setParams(newParams);
	}

	if (rcVersion < 7) { // 6.x
		                 // Video policy added to all 6.x rc files - done via config as API calls only saves config for
		                 // these when core is ready.
		if (!config->hasEntry("video", "automatically_accept")) config->setInt("video", "automatically_accept", 1);
		if (!config->hasEntry("video", "automatically_initiate")) config->setInt("video", "automatically_initiate", 0);
		// Force automatically accept direction to receive only for 6.x version for asymetrical video
		config->setInt("video", "automatically_accept_direction", 2);
		lInfo() << log().arg("Migrating) Video Policy for version 7.");
	}

	config->setInt(SettingsModel::UiSection, Constants::RcVersionName, Constants::RcVersionCurrent);
}

void CoreModel::searchInMagicSearch(QString filter,
                                    int sourceFlags,
                                    LinphoneEnums::MagicSearchAggregation aggregation,
                                    int maxResults) {
	mMagicSearch->search(filter, sourceFlags, aggregation, maxResults);
}

void CoreModel::checkForUpdate(const std::string &applicationVersion, bool requestedByUser) {
	mCheckVersionRequestedByUser = requestedByUser;
	auto settingsModel = SettingsModel::getInstance();
	if (settingsModel->isCheckForUpdateEnabled()) {
		if (settingsModel->getVersionCheckUrl().isEmpty())
			settingsModel->setVersionCheckUrl(Constants::VersionCheckReleaseUrl);
		lInfo() << log().arg("Checking for update for version") << applicationVersion;
		getCore()->checkForUpdate(applicationVersion);
	} else {
		lWarning() << log().arg("Check for update settings is not set");
	}
}

bool CoreModel::isCheckVersionRequestedByUser() const {
	return mCheckVersionRequestedByUser;
}

//---------------------------------------------------------------------------------------------------------------------------

void CoreModel::onAccountAdded(const std::shared_ptr<linphone::Core> &core,
                               const std::shared_ptr<linphone::Account> &account) {
	emit accountAdded(core, account);
}
void CoreModel::onAccountRemoved(const std::shared_ptr<linphone::Core> &core,
                                 const std::shared_ptr<linphone::Account> &account) {
	if (core->getDefaultAccount() == nullptr && core->getAccountList().size() > 0)
		core->setDefaultAccount(core->getAccountList().front());
	emit accountRemoved(core, account);
}
void CoreModel::onAccountRegistrationStateChanged(const std::shared_ptr<linphone::Core> &core,
                                                  const std::shared_ptr<linphone::Account> &account,
                                                  linphone::RegistrationState state,
                                                  const std::string &message) {
	emit accountRegistrationStateChanged(core, account, state, message);
}
void CoreModel::onAuthenticationRequested(const std::shared_ptr<linphone::Core> &core,
                                          const std::shared_ptr<linphone::AuthInfo> &authInfo,
                                          linphone::AuthMethod method) {
	if (method == linphone::AuthMethod::Bearer) {
		auto serverUrl = Utils::coreStringToAppString(authInfo->getAuthorizationServer());
		auto username = Utils::coreStringToAppString(authInfo->getUsername());
		auto realm = Utils::coreStringToAppString(authInfo->getRealm());
		if (!serverUrl.isEmpty()) {
			qDebug() << "onAuthenticationRequested for Bearer. Initialize OpenID connection for " << username << "@"
			         << realm << " at " << serverUrl;
			QString key = username + '@' + realm + ' ' + serverUrl;
			if (mOpenIdConnections.contains(key)) mOpenIdConnections[key]->deleteLater();
			auto oidcModel = new OIDCModel(authInfo, this);
			mOpenIdConnections[key] = oidcModel;
			connect(oidcModel, &OIDCModel::timeoutTimerStarted, this, [this] {
				mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
				emit timeoutTimerStarted();
				qDebug() << "start refresh timer";
			});
			if (oidcModel->isTimerRunning()) {
				emit timeoutTimerStarted();
			}
			connect(oidcModel, &OIDCModel::timeoutTimerStopped, this, [this] { emit timeoutTimerStopped(); });
			connect(this, &CoreModel::forceOidcTimeout, oidcModel, [this, oidcModel] {
				if (oidcModel->isTimerRunning()) {
					oidcModel->forceTimeout();
				}
			});
		}
	}
	emit authenticationRequested(core, authInfo, method);
}
void CoreModel::onCallEncryptionChanged(const std::shared_ptr<linphone::Core> &core,
                                        const std::shared_ptr<linphone::Call> &call,
                                        bool on,
                                        const std::string &authenticationToken) {
	emit callEncryptionChanged(core, call, on, authenticationToken);
}
void CoreModel::onCallLogUpdated(const std::shared_ptr<linphone::Core> &core,
                                 const std::shared_ptr<linphone::CallLog> &callLog) {
	if (callLog && callLog->getStatus() == linphone::Call::Status::Missed) emit unreadNotificationsChanged();
	emit callLogUpdated(core, callLog);
}
void CoreModel::onCallStateChanged(const std::shared_ptr<linphone::Core> &core,
                                   const std::shared_ptr<linphone::Call> &call,
                                   linphone::Call::State state,
                                   const std::string &message) {
	if (state == linphone::Call::State::IncomingReceived) {
		if (App::getInstance()->getNotifier()) App::getInstance()->getNotifier()->notifyReceivedCall(call);
		if (!core->getConfig()->getBool(SettingsModel::UiSection, "disable_command_line", false) &&
		    !core->getConfig()->getString(SettingsModel::UiSection, "command_line", "").empty()) {
			QString command = Utils::coreStringToAppString(
			    core->getConfig()->getString(SettingsModel::UiSection, "command_line", ""));
			QString userName = Utils::coreStringToAppString(call->getRemoteAddress()->getUsername());
			QString displayName =
			    call->getCallLog() && call->getCallLog()->getConferenceInfo()
			        ? Utils::coreStringToAppString(call->getCallLog()->getConferenceInfo()->getSubject())
			        : Utils::coreStringToAppString(call->getRemoteAddress()->getDisplayName());
			command = command.replace("$1", userName);
			command = command.replace("$2", displayName);
			Utils::runCommandLine(command);
		}
	}
	if (state == linphone::Call::State::End && SettingsModel::dndEnabled(core->getConfig()) &&
	    core->getCallsNb() == 0) { // Disable tones in DND mode if no more calls are running.
		SettingsModel::getInstance()->setCallToneIndicationsEnabled(false);
	}
	App::postModelAsync([core]() {
		auto accounts = App::getInstance()->getAccountList();
		if (!accounts) return;
		for (int i = 0; i < accounts->rowCount(); ++i) {
			auto accountCore = App::getInstance()->getAccountList()->getAt<AccountCore>(i);
			emit accountCore->lSetPresence(core->getCallsNb() == 0 ? LinphoneEnums::Presence::Online
			                                                       : LinphoneEnums::Presence::Busy,
			                               false, false);
		}
	});
	emit callStateChanged(core, call, state, message);
}
void CoreModel::onCallStatsUpdated(const std::shared_ptr<linphone::Core> &core,
                                   const std::shared_ptr<linphone::Call> &call,
                                   const std::shared_ptr<const linphone::CallStats> &stats) {
	emit callStatsUpdated(core, call, stats);
}
void CoreModel::onCallCreated(const std::shared_ptr<linphone::Core> &lc, const std::shared_ptr<linphone::Call> &call) {
	emit callCreated(call);
}
void CoreModel::onChatRoomRead(const std::shared_ptr<linphone::Core> &core,
                               const std::shared_ptr<linphone::ChatRoom> &chatRoom) {
	emit chatRoomRead(core, chatRoom);
}
void CoreModel::onChatRoomStateChanged(const std::shared_ptr<linphone::Core> &core,
                                       const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                       linphone::ChatRoom::State state) {
	emit chatRoomStateChanged(core, chatRoom, state);
}
void CoreModel::onConferenceInfoReceived(const std::shared_ptr<linphone::Core> &core,
                                         const std::shared_ptr<const linphone::ConferenceInfo> &conferenceInfo) {
	emit conferenceInfoReceived(core, conferenceInfo);
}
void CoreModel::onConferenceStateChanged(const std::shared_ptr<linphone::Core> &core,
                                         const std::shared_ptr<linphone::Conference> &conference,
                                         linphone::Conference::State state) {
	emit conferenceStateChanged(core, conference, state);
}
void CoreModel::onConfiguringStatus(const std::shared_ptr<linphone::Core> &core,
                                    linphone::ConfiguringState status,
                                    const std::string &message) {
	mConfigStatus = status;
	mConfigMessage = Utils::coreStringToAppString(message);
	emit configuringStatus(core, status, message);
}
void CoreModel::onDefaultAccountChanged(const std::shared_ptr<linphone::Core> &core,
                                        const std::shared_ptr<linphone::Account> &account) {
	emit defaultAccountChanged(core, account);
}
void CoreModel::onDtmfReceived(const std::shared_ptr<linphone::Core> &lc,
                               const std::shared_ptr<linphone::Call> &call,
                               int dtmf) {
	emit dtmfReceived(lc, call, dtmf);
}
void CoreModel::onEcCalibrationResult(const std::shared_ptr<linphone::Core> &core,
                                      linphone::EcCalibratorStatus status,
                                      int delayMs) {
	emit ecCalibrationResult(core, status, delayMs);
}
void CoreModel::onFirstCallStarted(const std::shared_ptr<linphone::Core> &core) {
	emit firstCallStarted();
}
void CoreModel::onGlobalStateChanged(const std::shared_ptr<linphone::Core> &core,
                                     linphone::GlobalState gstate,
                                     const std::string &message) {
	emit globalStateChanged(core, gstate, message);
}
void CoreModel::onIsComposingReceived(const std::shared_ptr<linphone::Core> &core,
                                      const std::shared_ptr<linphone::ChatRoom> &room) {
	emit isComposingReceived(core, room);
}

void CoreModel::onLastCallEnded(const std::shared_ptr<linphone::Core> &core) {
	emit lastCallEnded();
}

void CoreModel::onLogCollectionUploadStateChanged(const std::shared_ptr<linphone::Core> &core,
                                                  linphone::Core::LogCollectionUploadState state,
                                                  const std::string &info) {
	emit logCollectionUploadStateChanged(core, state, info);
}
void CoreModel::onLogCollectionUploadProgressIndication(const std::shared_ptr<linphone::Core> &lc,
                                                        size_t offset,
                                                        size_t total) {
	emit logCollectionUploadProgressIndication(lc, offset, total);
}
void CoreModel::onMessageReceived(const std::shared_ptr<linphone::Core> &core,
                                  const std::shared_ptr<linphone::ChatRoom> &room,
                                  const std::shared_ptr<linphone::ChatMessage> &message) {
	if (SettingsModel::getInstance()->getDisableChatFeature()) return;
	if (message->isOutgoing()) return;
	emit unreadNotificationsChanged();
	std::list<std::shared_ptr<linphone::ChatMessage>> messages;
	messages.push_back(message);
	if (App::getInstance()->getNotifier()) {
		App::getInstance()->getNotifier()->notifyReceivedMessages(room, messages);
	}
	emit messageReceived(core, room, message);
}
void CoreModel::onMessagesReceived(const std::shared_ptr<linphone::Core> &core,
                                   const std::shared_ptr<linphone::ChatRoom> &room,
                                   const std::list<std::shared_ptr<linphone::ChatMessage>> &messages) {
	if (SettingsModel::getInstance()->getDisableChatFeature()) return;
	std::list<std::shared_ptr<linphone::ChatMessage>> finalMessages;
	for (auto &message : messages) {
		if (message->isOutgoing()) continue;
		finalMessages.push_back(message);
	}
	if (finalMessages.size() > 0) {
		emit unreadNotificationsChanged();
		emit messagesReceived(core, room, finalMessages);
	}
	if (App::getInstance()->getNotifier())
		App::getInstance()->getNotifier()->notifyReceivedMessages(room, finalMessages);
}

void CoreModel::onNewMessageReaction(const std::shared_ptr<linphone::Core> &core,
                                     const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                     const std::shared_ptr<linphone::ChatMessage> &message,
                                     const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) {
	if (SettingsModel::getInstance()->getDisableChatFeature()) return;
	emit newMessageReaction(core, chatRoom, message, reaction);
}
void CoreModel::onNotifyPresenceReceivedForUriOrTel(
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Friend> &linphoneFriend,
    const std::string &uriOrTel,
    const std::shared_ptr<const linphone::PresenceModel> &presenceModel) {
	emit notifyPresenceReceivedForUriOrTel(core, linphoneFriend, uriOrTel, presenceModel);
}
void CoreModel::onNotifyPresenceReceived(const std::shared_ptr<linphone::Core> &core,
                                         const std::shared_ptr<linphone::Friend> &linphoneFriend) {
	emit notifyPresenceReceived(core, linphoneFriend);
}
void CoreModel::onQrcodeFound(const std::shared_ptr<linphone::Core> &core, const std::string &result) {
	emit qrcodeFound(core, result);
}
void CoreModel::onReactionRemoved(const std::shared_ptr<linphone::Core> &core,
                                  const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                  const std::shared_ptr<linphone::ChatMessage> &message,
                                  const std::shared_ptr<const linphone::Address> &address) {
	if (SettingsModel::getInstance()->getDisableChatFeature()) return;
	emit reactionRemoved(core, chatRoom, message, address);
}
void CoreModel::onTransferStateChanged(const std::shared_ptr<linphone::Core> &core,
                                       const std::shared_ptr<linphone::Call> &call,
                                       linphone::Call::State state) {
	emit transferStateChanged(core, call, state);
}
void CoreModel::onVersionUpdateCheckResultReceived(const std::shared_ptr<linphone::Core> &core,
                                                   linphone::VersionUpdateCheckResult result,
                                                   const std::string &version,
                                                   const std::string &url) {
	emit versionUpdateCheckResultReceived(core, result, version, url, mCheckVersionRequestedByUser);
}

void CoreModel::onFriendListRemoved(const std::shared_ptr<linphone::Core> &core,
                                    const std::shared_ptr<linphone::FriendList> &friendList) {
	// Hack because of SDK bug. Wait some times before removing friends.
	// Note: shared pointers can be used with singleShot, they will be destroyed after removing lambda from timer.
	QTimer::singleShot(500, [this, core, friendList]() {
		emit friendListRemoved(core, friendList);
		for (auto f : friendList->getFriends()) {
			emit friendRemoved(f);
		}
	});
	/* TODO when SDK bug is fixed
	emit friendListRemoved(core, friendList);
	qDebug() << "List removed: " << friendList->getDisplayName();
	for (auto l : core->getFriendsLists()) {
	    qDebug() << "Still have " << l->getDisplayName();
	}
	for (auto f : friendList->getFriends()) {
	    auto linFriend = CoreModel::getInstance()->getCore()->findFriend(f->getAddress());
	    if (linFriend) qDebug() << "Friend still exist: " << linFriend->getFriendList()->getDisplayName();
	    emit friendRemoved(f);
	}
*/
}

void CoreModel::onAudioDevicesListUpdated(const std::shared_ptr<linphone::Core> &core) {
	emit audioDevicesListUpdated(core);
}

void CoreModel::onAudioDeviceChanged(const std::shared_ptr<linphone::Core> &core,
                                     const std::shared_ptr<linphone::AudioDevice> &device) {
	emit audioDeviceChanged(core, device);
}