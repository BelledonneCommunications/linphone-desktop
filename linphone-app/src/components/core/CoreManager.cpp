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
#include "components/chat/ChatModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"
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
	QObject::connect(coreHandlers, &CoreHandlers::callLogUpdated, this, &CoreManager::callLogsCountChanged);
	
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
	qInfo() << "Init CoreManager";
	mAccountSettingsModel = new AccountSettingsModel(this);
	mSettingsModel = new SettingsModel(this);
	mCallsListModel = new CallsListModel(this);
	mChatModel = new ChatModel(this);
	mContactsListModel = new ContactsListModel(this);
	mContactsImporterListModel = new ContactsImporterListModel(this);
	mLdapListModel = new LdapListModel(this);
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
		mInstance->stopIterate();
		auto core = mInstance->mCore;
		mInstance->lockVideoRender();// Stop do iterations. We have to protect GUI.
		mInstance->unlockVideoRender();
		delete mInstance;	// This will also remove stored Linphone objects.
		mInstance = nullptr;
		core->stop();
		if( core->getGlobalState() != linphone::GlobalState::Off)
			qWarning() << "Core is not off after stopping it. It may result to have multiple core instance.";
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

void CoreManager::stateChanged(Qt::ApplicationState pState){
	if(mCbsTimer){
		if(pState == Qt::ApplicationActive)
			mCbsTimer->setInterval(	Constants::CbsCallInterval);
		else
			mCbsTimer->setInterval(	Constants::CbsCallInterval * 2);// Reduce a little processes
	}
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
	linphone_core_set_call_logs_database_path(mCore->cPtr(), Paths::getCallHistoryFilePath().c_str());// Setting the message database let SDK to migrate data
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
	mCore->enableLimeX3Dh(mCore->limeX3DhAvailable());
	// Now see the CoreService.CreateGroupChatRoom to see how to create a secure chat room
	
	mCore->addListener(mHandlers);
	mCore->setVideoDisplayFilter("MSQOGL");
	mCore->usePreviewWindow(true);
	mCore->enableVideoPreview(false);
	// Force capture/display.
	// Useful if the app was built without video support.
	// (The capture/display attributes are reset by the core in this case.)
	shared_ptr<linphone::Config> config = mCore->getConfig();
	if (mCore->videoSupported()) {
		config->setInt("video", "capture", 1);
		config->setInt("video", "display", 1);
	}
	QString userAgent = Utils::computeUserAgent(config);
	mCore->setUserAgent(Utils::appStringToCoreString(userAgent), mCore->getVersion());
	mCore->start();
	setDatabasesPaths();
	setOtherPaths();
	mCore->enableFriendListSubscription(true);
	mCore->enableRecordAware(true);
	if(mCore->getAccountCreatorUrl() == "")
		mCore->setAccountCreatorUrl(Constants::DefaultFlexiAPIURL);
}

void CoreManager::updateUserAgent(){
	mCore->setUserAgent(Utils::appStringToCoreString(Utils::computeUserAgent(mCore->getConfig())), mCore->getVersion());
	forceRefreshRegisters(); 	// After setting a new device name, REGISTER need to take account it.
}

void CoreManager::handleChatRoomCreated(const QSharedPointer<ChatRoomModel> &chatRoomModel){
	emit chatRoomModelCreated(chatRoomModel);
}

void CoreManager::migrate () {
	shared_ptr<linphone::Config> config = mCore->getConfig();
	auto oldLimeServerUrl = mCore->getLimeX3DhServerUrl();// core url is deprecated : If core url exists, it must be copied to all linphone accounts.
	int rcVersion = config->getInt(SettingsModel::UiSection, Constants::RcVersionName, 0);
	if (oldLimeServerUrl.empty() && rcVersion == Constants::RcVersionCurrent)
		return;
	if (rcVersion > Constants::RcVersionCurrent) {
		qWarning() << QStringLiteral("RC file version (%1) is more recent than app rc file version (%2)!!!")
					  .arg(rcVersion).arg(Constants::RcVersionCurrent);
		return;
	}
	
	qInfo() << QStringLiteral("Migrate from old rc file (%1 to %2).")
			   .arg(rcVersion).arg(Constants::RcVersionCurrent);
	
	bool setLimeServerUrl = false;
	for(const auto &account : getAccountList()){
		auto params = account->getParams();
		if( params->getDomain() == Constants::LinphoneDomain) {
			auto newParams = params->clone();
			QString accountIdentity = (newParams->getIdentityAddress() ? newParams->getIdentityAddress()->asString().c_str() : "no-identity");
			if( rcVersion < 1) {
				newParams->setContactParameters(Constants::DefaultContactParameters);
				newParams->setExpires(Constants::DefaultExpires);
				qInfo() << "Migrating" << accountIdentity << "for version 1. contact parameters =" << Constants::DefaultContactParameters << ", expires =" << Constants::DefaultExpires;
			}
			if( rcVersion < 2) {
				bool exists = newParams->getConferenceFactoryUri() != "";
				setLimeServerUrl = true;
				if(!exists )
					newParams->setConferenceFactoryUri(Constants::DefaultConferenceURI);
				qInfo() << "Migrating" << accountIdentity << "for version 2. Conference factory URI" << (exists ? std::string("unchanged") : std::string("= ") +Constants::DefaultConferenceURI).c_str();
				// note: using std::string.c_str() to avoid having double quotes in qInfo()
			}
			if( rcVersion < 3){
				newParams->enableCpimInBasicChatRoom(true);
				qInfo() << "Migrating" << accountIdentity << "for version 3. Enable Cpim in basic chat rooms";
			}
			if( rcVersion < 4){
				newParams->enableRtpBundle(true);
				qInfo() << "Migrating" << accountIdentity << "for version 4. Enable RTP bundle mode";
			}
			if( rcVersion < 5) {
				bool exists = !!newParams->getAudioVideoConferenceFactoryAddress();
				setLimeServerUrl = true;
				if( !exists)
					newParams->setAudioVideoConferenceFactoryAddress(Utils::interpretUrl(Constants::DefaultVideoConferenceURI));
				qInfo() << "Migrating" << accountIdentity << "for version 5. Video conference factory URI" << (exists ? std::string("unchanged") : std::string("= ") +Constants::DefaultVideoConferenceURI).c_str();
				// note: using std::string.c_str() to avoid having double quotes in qInfo()
			}
			
			if(!oldLimeServerUrl.empty())
				newParams->setLimeServerUrl(oldLimeServerUrl);
			else if( setLimeServerUrl)
				newParams->setLimeServerUrl(Constants::DefaultLimeServerURL);
			
			account->setParams(newParams);
		}
	}
	if( !oldLimeServerUrl.empty()) {
		mCore->setLimeX3DhServerUrl("");
		mCore->enableLimeX3Dh(true);
	}else if(setLimeServerUrl) {
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
int CoreManager::getCallLogsCount() const{
	return mCore->getCallLogs().size();
}
int CoreManager::getMissedCallCount(const QString &peerAddress, const QString &localAddress)const{
	return mEventCountNotifier ? mEventCountNotifier->getMissedCallCount(peerAddress, localAddress) : 0;
}
int CoreManager::getMissedCallCountFromLocal( const QString &localAddress)const{
	return mEventCountNotifier ? mEventCountNotifier->getMissedCallCountFromLocal(localAddress) : 0;
}

std::list<std::shared_ptr<linphone::Account>> CoreManager::getAccountList()const{
	std::list<std::shared_ptr<linphone::Account>> accounts;
	for(auto account : mCore->getAccountList())
		if( account->getCustomParam("hidden") != "1")
			accounts.push_back(account);
	return accounts;
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
