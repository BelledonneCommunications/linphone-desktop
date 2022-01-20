/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include <QCoreApplication>
#include <QDir>
#include <QSysInfo>
#include <QtConcurrent>
#include <QTimer>
#include <QFile>
#include <QTest>
#include "config.h"

#include "app/paths/Paths.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"
#include "components/chat-room/ChatRoomListModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/contacts/ContactsImporterListModel.hpp"
#include "components/history/HistoryModel.hpp"
#include "components/ldap/LdapListModel.hpp"
#include "components/recorder/RecorderManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "components/timeline/TimelineListModel.hpp"

#include "utils/Utils.hpp"
#include "utils/Constants.hpp"

#if defined(Q_OS_MACOS)
#include "event-count-notifier/EventCountNotifierMacOs.hpp"
#else
#include "event-count-notifier/EventCountNotifierSystemTrayIcon.hpp"
#endif // if defined(Q_OS_MACOS)

#include "CoreHandlers.hpp"
#include "CoreManager.hpp"
#include <linphone/core.h>

#include <linphone/core.h>

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

CoreManager *CoreManager::mInstance=nullptr;

CoreManager::CoreManager (QObject *parent, const QString &configPath) :
	QObject(parent), mHandlers(make_shared<CoreHandlers>(this)) {
	mCore = nullptr;
	mLastRemoteProvisioningState = linphone::ConfiguringState::Skipped;
	CoreHandlers *coreHandlers = mHandlers.get();
	QObject::connect(coreHandlers, &CoreHandlers::coreStarting, this, &CoreManager::startIterate, Qt::QueuedConnection);
	QObject::connect(coreHandlers, &CoreHandlers::setLastRemoteProvisioningState, this, &CoreManager::setLastRemoteProvisioningState);
	QObject::connect(coreHandlers, &CoreHandlers::coreStarted, this, &CoreManager::initCoreManager, Qt::QueuedConnection);
	QObject::connect(coreHandlers, &CoreHandlers::coreStopped, this, &CoreManager::stopIterate, Qt::QueuedConnection);
	QObject::connect(coreHandlers, &CoreHandlers::logsUploadStateChanged, this, &CoreManager::handleLogsUploadStateChanged);
	QTimer::singleShot(10, [this, configPath](){// Delay the creation in order to have the CoreManager instance set before
		createLinphoneCore(configPath);
	});
}

CoreManager::~CoreManager(){
	mCore->removeListener(mHandlers);
	mHandlers = nullptr;// Ordering Call destructor just to be sure (removeListener should be enough)
	mCore = nullptr;
}

// -----------------------------------------------------------------------------

void CoreManager::initCoreManager(){
	mCallsListModel = new CallsListModel(this);
	mChatRoomListModel = new ChatRoomListModel(this);
	mContactsListModel = new ContactsListModel(this);
	mContactsImporterListModel = new ContactsImporterListModel(this);
	mAccountSettingsModel = new AccountSettingsModel(this);
	mLdapListModel = new LdapListModel(this);
	mSettingsModel = new SettingsModel(this);
	mSipAddressesModel = new SipAddressesModel(this);
	mEventCountNotifier = new EventCountNotifier(this);
	mTimelineListModel = new TimelineListModel(this);
	mEventCountNotifier->updateUnreadMessageCount();
	QObject::connect(mEventCountNotifier, &EventCountNotifier::eventCountChanged,this, &CoreManager::eventCountChanged);
	migrate();
	mStarted = true;
	
	qInfo() << QStringLiteral("CoreManager initialized");
	emit coreManagerInitialized();
}

AbstractEventCountNotifier * CoreManager::getEventCountNotifier(){
	return mEventCountNotifier;
}

CoreManager *CoreManager::getInstance (){
	return mInstance;
}


HistoryModel* CoreManager::getHistoryModel(){
	if(!mHistoryModel){
		mHistoryModel = new HistoryModel(this);
		emit historyModelCreated(mHistoryModel);
	}
	return mHistoryModel;
}

RecorderManager* CoreManager::getRecorderManager(){
	if(!mRecorderManager){
		mRecorderManager = new RecorderManager(this);
		emit recorderManagerCreated(mRecorderManager);
	}
	return mRecorderManager;
}
// -----------------------------------------------------------------------------

void CoreManager::init (QObject *parent, const QString &configPath) {
	if (mInstance)
		return;
	mInstance = new CoreManager(parent, configPath);
}

void CoreManager::uninit () {
	if (mInstance) {
		connect(mInstance, &QObject::destroyed, []()mutable{
			mInstance = nullptr;
			qInfo() << "Core is correctly destroyed";
		});
		QObject::connect(mInstance->getHandlers().get(), &CoreHandlers::coreStopped, mInstance, &QObject::deleteLater); // Delete data only when the core is Off
		
		mInstance->lockVideoRender();// Stop do iterations. We have to protect GUI.
		mInstance->mCore->stop();
		mInstance->unlockVideoRender();
		QTest::qWaitFor([&]() {return mInstance == nullptr;},10000);
		if( mInstance){
			qWarning() << "Core couldn't destroy in time. It may lead to have multiple session of Core";
			mInstance = nullptr;
		}
	}
}

// -----------------------------------------------------------------------------

VcardModel *CoreManager::createDetachedVcardModel () const {
	VcardModel *vcardModel = new VcardModel(linphone::Factory::get()->createVcard(), false);
	qInfo() << QStringLiteral("Create detached vcard:") << vcardModel;
	return vcardModel;
}

void CoreManager::forceRefreshRegisters () {
	Q_CHECK_PTR(mCore);
	
	qInfo() << QStringLiteral("Refresh registers.");
	mCore->refreshRegisters();
}
void CoreManager::updateUnreadMessageCount(){
	mEventCountNotifier->updateUnreadMessageCount();
}
// -----------------------------------------------------------------------------

void CoreManager::sendLogs () const {
	Q_CHECK_PTR(mCore);
	
	qInfo() << QStringLiteral("Send logs to: `%1` from `%2`.")
			   .arg(Utils::coreStringToAppString(mCore->getLogCollectionUploadServerUrl()))
			   .arg(Utils::coreStringToAppString(mCore->getLogCollectionPath()));
	mCore->uploadLogCollection();
}

void CoreManager::cleanLogs () const {
	Q_CHECK_PTR(mCore);
	
	mCore->resetLogCollection();
}
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------

#define SET_DATABASE_PATH(DATABASE, PATH) \
	do { \
	qInfo() << QStringLiteral("Set `%1` path: `%2`") \
	.arg( # DATABASE) \
	.arg(Utils::coreStringToAppString(PATH)); \
	mCore->set ## DATABASE ## DatabasePath(PATH); \
	} while (0);

void CoreManager::setDatabasesPaths () {
	SET_DATABASE_PATH(Friends, Paths::getFriendsListFilePath());
	SET_DATABASE_PATH(CallLogs, Paths::getCallHistoryFilePath());
	if(QFile::exists(Utils::coreStringToAppString(Paths::getMessageHistoryFilePath()))){
		linphone_core_set_chat_database_path(mCore->cPtr(), Paths::getMessageHistoryFilePath().c_str());// Setting the message database let SDK to migrate data
		QFile::remove(Utils::coreStringToAppString(Paths::getMessageHistoryFilePath()));
	}
}

#undef SET_DATABASE_PATH

// -----------------------------------------------------------------------------

void CoreManager::setOtherPaths () {
	if (mCore->getZrtpSecretsFile().empty() || !Paths::filePathExists(mCore->getZrtpSecretsFile(), true))
		mCore->setZrtpSecretsFile(Paths::getZrtpSecretsFilePath());// Use application path if Linphone default is not available
	qInfo() << "Using ZrtpSecrets path : " << QString::fromStdString(mCore->getZrtpSecretsFile());
	if (mCore->getUserCertificatesPath().empty() || !Paths::filePathExists(mCore->getUserCertificatesPath(), true))
		mCore->setUserCertificatesPath(Paths::getUserCertificatesDirPath());// Use application path if Linphone default is not available
	qInfo() << "Using UserCertificate path : " << QString::fromStdString(mCore->getUserCertificatesPath());
	if (mCore->getRootCa().empty() || !Paths::filePathExists(mCore->getRootCa()))
		mCore->setRootCa(Paths::getRootCaFilePath());// Use application path if Linphone default is not available
	qInfo() << "Using RootCa path : " << QString::fromStdString(mCore->getRootCa());
}

void CoreManager::setResourcesPaths () {
	shared_ptr<linphone::Factory> factory = linphone::Factory::get();
	factory->setMspluginsDir(Paths::getPackageMsPluginsDirPath());
	factory->setTopResourcesDir(Paths::getPackageTopDirPath());
	factory->setSoundResourcesDir(Paths::getPackageSoundsResourcesDirPath());
	factory->setDataResourcesDir(Paths::getPackageDataDirPath());
	factory->setDataDir(Paths::getAppLocalDirPath());
	factory->setDownloadDir(Paths::getDownloadDirPath());
	factory->setConfigDir(Paths::getConfigDirPath(true));
}

// -----------------------------------------------------------------------------

void CoreManager::createLinphoneCore (const QString &configPath) {
	qInfo() << QStringLiteral("Launch async core creation.");
	
	// Migration of configuration and database files from GTK version of Linphone.
	Paths::migrate();
	setResourcesPaths();
	mCore = linphone::Factory::get()->createCore(
				Paths::getConfigFilePath(configPath),
				Paths::getFactoryConfigFilePath(),
				nullptr
				);
	// Enable LIME on your core to use encryption.
	mCore->enableLimeX3Dh(mCore->getLimeX3DhServerUrl() != "");
	// Now see the CoreService.CreateGroupChatRoom to see how to create a secure chat room
	
	mCore->addListener(mHandlers);
	mCore->setVideoDisplayFilter("MSQOGL");
	mCore->usePreviewWindow(true);
	mCore->enableVideoPreview(false);
	mCore->setUserAgent(
				Utils::appStringToCoreString(
					QStringLiteral(APPLICATION_NAME" Desktop/%1 (%2, Qt %3) LinphoneCore")
					.arg(QCoreApplication::applicationVersion())
					.arg(QSysInfo::prettyProductName())
					.arg(qVersion())
					),
				mCore->getVersion()
				);
	// Force capture/display.
	// Useful if the app was built without video support.
	// (The capture/display attributes are reset by the core in this case.)
	shared_ptr<linphone::Config> config = mCore->getConfig();
	if (mCore->videoSupported()) {
		config->setInt("video", "capture", 1);
		config->setInt("video", "display", 1);
	}
	mCore->start();
	setDatabasesPaths();
	setOtherPaths();
	mCore->enableFriendListSubscription(true);
}

void CoreManager::handleChatRoomCreated(const std::shared_ptr<ChatRoomModel> &chatRoomModel){
	emit chatRoomModelCreated(chatRoomModel);
}

void CoreManager::migrate () {
	shared_ptr<linphone::Config> config = mCore->getConfig();
	int rcVersion = config->getInt(SettingsModel::UiSection, Constants::RcVersionName, 0);
	if (rcVersion == Constants::RcVersionCurrent)
		return;
	if (rcVersion > Constants::RcVersionCurrent) {
		qWarning() << QStringLiteral("RC file version (%1) is more recent than app rc file version (%2)!!!")
					  .arg(rcVersion).arg(Constants::RcVersionCurrent);
		return;
	}
	
	qInfo() << QStringLiteral("Migrate from old rc file (%1 to %2).")
			   .arg(rcVersion).arg(Constants::RcVersionCurrent);
	
	// Add message_expires param on old proxy configs.
	/*
  for (const auto &proxyConfig : mCore->getProxyConfigList()) {
	if (proxyConfig->getDomain() == Constants::LinphoneDomain) {
	  proxyConfig->setContactParameters(Constants::DefaultContactParameters);
	  proxyConfig->setExpires(Constants::DefaultExpires);
	  proxyConfig->done();
	}
  }*/
	bool setlimeServerUrl = false;
	for(const auto &account : mCore->getAccountList()){
		auto params = account->getParams();
		if( params->getDomain() == Constants::LinphoneDomain) {
			auto newParams = params->clone();
			QString accountIdentity = (newParams->getIdentityAddress() ? newParams->getIdentityAddress()->asString().c_str() : "no-identity");
			if( rcVersion < 1) {
				newParams->setContactParameters(Constants::DefaultContactParameters);
				newParams->setExpires(Constants::DefaultExpires);
				qInfo() << "Migrating " << accountIdentity << " for version 1. contact parameters = " << Constants::DefaultContactParameters << ", expires = " << Constants::DefaultExpires;
			}
			if( rcVersion < 2) {
				newParams->setConferenceFactoryUri(Constants::DefaultConferenceURI);
				setlimeServerUrl = true;
				qInfo() << "Migrating " << accountIdentity << " for version 2. conference factory URI = " << Constants::DefaultConferenceURI;
			}
			if( rcVersion < 3){
				newParams->enableCpimInBasicChatRoom(true);
				qInfo() << "Migrating " << accountIdentity << " for version 3. enable Cpim in basic chat rooms";
			}
			account->setParams(newParams);
		}
	}
	if(setlimeServerUrl) {
		mCore->setLimeX3DhServerUrl(Constants::DefaultLimeServerURL);
		mCore->enableLimeX3Dh(true);
	}
	
	
	config->setInt(SettingsModel::UiSection, Constants::RcVersionName, Constants::RcVersionCurrent);
}

// -----------------------------------------------------------------------------

QString CoreManager::getVersion () const {
	return Utils::coreStringToAppString(mCore->getVersion());
}

// -----------------------------------------------------------------------------

int CoreManager::getEventCount () const {
	return mEventCountNotifier ? mEventCountNotifier->getEventCount() : 0;
}
int CoreManager::getMissedCallCount(const QString &peerAddress, const QString &localAddress)const{
	return mEventCountNotifier ? mEventCountNotifier->getMissedCallCount(peerAddress, localAddress) : 0;
}
int CoreManager::getMissedCallCountFromLocal( const QString &localAddress)const{
	return mEventCountNotifier ? mEventCountNotifier->getMissedCallCountFromLocal(localAddress) : 0;
}

// -----------------------------------------------------------------------------

void CoreManager::startIterate(){
	mCbsTimer = new QTimer(this);
	mCbsTimer->setInterval(Constants::CbsCallInterval);
	QObject::connect(mCbsTimer, &QTimer::timeout, this, &CoreManager::iterate);
	qInfo() << QStringLiteral("Start iterate");
	mCbsTimer->start();
}

void CoreManager::stopIterate(){
	qInfo() << QStringLiteral("Stop iterate");
	mCbsTimer->stop();
	mCbsTimer->deleteLater();// allow the timer to continue its stuff
	mCbsTimer = nullptr;
}

void CoreManager::iterate () {
	lockVideoRender();
	if(mCore)
		mCore->iterate();
	unlockVideoRender();
}

// -----------------------------------------------------------------------------

void CoreManager::handleLogsUploadStateChanged (linphone::Core::LogCollectionUploadState state, const string &info) {
	switch (state) {
		case linphone::Core::LogCollectionUploadState::InProgress:
			break;
			
		case linphone::Core::LogCollectionUploadState::Delivered:
		case linphone::Core::LogCollectionUploadState::NotDelivered:
			emit logsUploaded(Utils::coreStringToAppString(info));
			break;
	}
}

// -----------------------------------------------------------------------------

QString CoreManager::getDownloadUrl () {
	return Constants::DownloadUrl;
}

void CoreManager::setLastRemoteProvisioningState(const linphone::ConfiguringState& state){
	mLastRemoteProvisioningState = state;
}

bool CoreManager::isLastRemoteProvisioningGood(){
	return mLastRemoteProvisioningState != linphone::ConfiguringState::Failed;
}

QString CoreManager::getUserAgent()const {
	if(mCore)
		return Utils::coreStringToAppString(mCore->getUserAgent());
	else
		return EXECUTABLE_NAME " Desktop";// Just in case
}
