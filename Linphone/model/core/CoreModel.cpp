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
#include "tool/Utils.hpp"

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
	auto model = std::make_shared<CoreModel>(configPath, parent);
	model->setSelf(model);
	gCoreModel = model;
	return model;
}

void CoreModel::start() {
	mIterateTimer = new QTimer(this);
	mIterateTimer->setInterval(30);
	connect(mIterateTimer, &QTimer::timeout, [this]() {
		static int iterateCount = 0;
		if (iterateCount != 0) lCritical() << log().arg("Multi Iterate ! ");
		++iterateCount;
		mCore->iterate();
		--iterateCount;
	});
	setPathBeforeCreation();
	mCore =
	    linphone::Factory::get()->createCore(Utils::appStringToCoreString(Paths::getConfigFilePath(mConfigPath)),
	                                         Utils::appStringToCoreString(Paths::getFactoryConfigFilePath()), nullptr);
	setMonitor(mCore);
	setPathsAfterCreation();
	mCore->enableRecordAware(true);
	mCore->setVideoDisplayFilter("MSQOGL");
	mCore->usePreviewWindow(true);
	// Force capture/display.
	// Useful if the app was built without video support.
	// (The capture/display attributes are reset by the core in this case.)
	auto config = mCore->getConfig();
	if (mCore->videoSupported()) {
		config->setInt("video", "capture", 1);
		config->setInt("video", "display", 1);
	}
	mCore->enableVideoPreview(false);         // SDK doesn't write the state in configuration if not ready.
	config->setInt("video", "show_local", 0); // So : write ourself to turn off camera before starting the core.
	mCore->start();
	setPathAfterStart();
	mCore->enableFriendListSubscription(true);
	// TODO : get this from settings
	auto videoPolicy = mCore->getVideoActivationPolicy()->clone();
	videoPolicy->setAutomaticallyAccept(true);
	videoPolicy->setAutomaticallyInitiate(false);
	mCore->setVideoActivationPolicy(videoPolicy);
	mIterateTimer->start();
}
// -----------------------------------------------------------------------------

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
	SET_FACTORY_PATH(SoundResources, Paths::getPackageSoundsResourcesDirPath());
	SET_FACTORY_PATH(DataResources, Paths::getPackageDataDirPath());
	SET_FACTORY_PATH(Data, Paths::getAppLocalDirPath());
	SET_FACTORY_PATH(Download, Paths::getDownloadDirPath());
	SET_FACTORY_PATH(Config, Paths::getConfigDirPath(true));
}

void CoreModel::setPathsAfterCreation() {
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
	if (mCore->getRootCa().empty() || !Paths::filePathExists(Utils::coreStringToAppString(mCore->getRootCa())))
		mCore->setRootCa(Utils::appStringToCoreString(Paths::getRootCaFilePath()));
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
			qWarning() << "Remote provisionning cannot be retrieved. Command have been cleaned";
			*error = true;
		}
	}
	return filePath;
}

void CoreModel::useFetchConfig(QString filePath) {
	bool error = false;
	filePath = getFetchConfig(filePath, &error);
	if (!error && !filePath.isEmpty()) {

		if (mCore && mCore->getGlobalState() == linphone::GlobalState::On) {
			// TODO
			// if (mSettings->getAutoApplyProvisioningConfigUriHandlerEnabled()) setFetchConfig(filePath); else
			emit requestFetchConfig(filePath);
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
			fetched = mCore->setProvisioningUri(Utils::appStringToCoreString(filePath)) == 0;
		}
	}
	if (!fetched) {
		qWarning() << "Remote provisionning cannot be retrieved. Command have been cleaned";
	} else emit requestRestart();
	return fetched;
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
		auto serverUrl = authInfo->getAuthorizationServer();
		auto username = authInfo->getUsername();
		auto realm = authInfo->getRealm();
		if (!serverUrl.empty()) {
			qDebug() << "onAuthenticationRequested for Bearer. Initialize OpenID connection for " << username.c_str()
			         << " at " << serverUrl.c_str();
			QString key = Utils::coreStringToAppString(username) + '@' + Utils::coreStringToAppString(realm) + ' ' +
			              Utils::coreStringToAppString(serverUrl);
			if (mOpenIdConnections.contains(key)) mOpenIdConnections[key]->deleteLater();
			mOpenIdConnections[key] = new OIDCModel(authInfo, this);
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
		App::getInstance()->getNotifier()->notifyReceivedCall(call);
	}
	if (state == linphone::Call::State::End && SettingsModel::dndEnabled(core->getConfig()) &&
	    core->getCallsNb() == 0) { // Disable tones in DND mode if no more calls are running.
		SettingsModel::enableTones(core->getConfig(), false);
	}
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
	emit unreadNotificationsChanged();
	emit messageReceived(core, room, message);
}
void CoreModel::onMessagesReceived(const std::shared_ptr<linphone::Core> &core,
                                   const std::shared_ptr<linphone::ChatRoom> &room,
                                   const std::list<std::shared_ptr<linphone::ChatMessage>> &messages) {
	emit unreadNotificationsChanged();
	emit messagesReceived(core, room, messages);
}

void CoreModel::onNewMessageReaction(const std::shared_ptr<linphone::Core> &core,
                                     const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                     const std::shared_ptr<linphone::ChatMessage> &message,
                                     const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) {
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
	emit versionUpdateCheckResultReceived(core, result, version, url);
}
void CoreModel::onFriendListRemoved(const std::shared_ptr<linphone::Core> &core,
                                    const std::shared_ptr<linphone::FriendList> &friendList) {
	emit friendListRemoved(core, friendList);
}
