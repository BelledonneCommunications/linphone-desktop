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

#include <QDir>
#include <QtDebug>
#include <QPluginLoader>
#include <QJsonDocument>

#include <cstdlib>
#include <cmath>

#include "config.h"

#include "app/App.hpp"
#include "app/logger/Logger.hpp"
#include "app/paths/Paths.hpp"

#include "components/assistant/AssistantModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/tunnel/TunnelModel.hpp"
#include "include/LinphoneApp/PluginNetworkHelper.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "utils/MediastreamerUtils.hpp"
#include "AccountSettingsModel.hpp"
#include "SettingsModel.hpp"


// =============================================================================

using namespace std;

const string SettingsModel::UiSection("ui");
const string SettingsModel::ContactsSection("contacts_import");

SettingsModel::SettingsModel (QObject *parent) : QObject(parent) {
	CoreManager *coreManager = CoreManager::getInstance();
	mConfig = coreManager->getCore()->getConfig();
	
	connect(this, &SettingsModel::dontAskAgainInfoEncryptionChanged, this, &SettingsModel::haveDontAskAgainChoicesChanged);
	connect(this, &SettingsModel::haveAtLeastOneVideoCodecChanged, this, &SettingsModel::videoAvailableChanged);

	QObject::connect(coreManager->getHandlers().get(), &CoreHandlers::callCreated,
			 this, &SettingsModel::handleCallCreated);
	QObject::connect(coreManager->getHandlers().get(), &CoreHandlers::callStateChanged,
			 this, &SettingsModel::handleCallStateChanged);
	QObject::connect(coreManager->getHandlers().get(), &CoreHandlers::ecCalibrationResult,
			 this, &SettingsModel::handleEcCalibrationResult);
			 
// Readonly state that can change from default account
	connect(coreManager->getAccountSettingsModel(), &AccountSettingsModel::defaultAccountChanged, this, &SettingsModel::groupChatEnabledChanged);
	connect(coreManager->getAccountSettingsModel(), &AccountSettingsModel::defaultAccountChanged, this, &SettingsModel::videoConferenceEnabledChanged);
	connect(coreManager->getAccountSettingsModel(), &AccountSettingsModel::defaultAccountChanged, this, &SettingsModel::secureChatEnabledChanged);
	connect(coreManager->getAccountSettingsModel(), &AccountSettingsModel::defaultAccountChanged, this, &SettingsModel::onDefaultAccountChanged);
	
	connect(coreManager->getAccountSettingsModel(), &AccountSettingsModel::accountSettingsUpdated, this, &SettingsModel::groupChatEnabledChanged);
	connect(coreManager->getAccountSettingsModel(), &AccountSettingsModel::accountSettingsUpdated, this, &SettingsModel::videoConferenceEnabledChanged);
	connect(coreManager->getAccountSettingsModel(), &AccountSettingsModel::accountSettingsUpdated, this, &SettingsModel::secureChatEnabledChanged);
#ifdef ENABLE_QT_KEYCHAIN
	connect(&mVfsUtils, &VfsUtils::keyRead, this, [&](const QString& key, const QString& value){
		if(key == mVfsUtils.getApplicationVfsEncryptionKey()){
			if(!getVfsEncrypted()){
				QSettings settings;
				settings.beginGroup("keychain");
				settings.setValue("enabled", true);
				emit vfsEncryptedChanged();
			}
		}
	});
	connect(&mVfsUtils, &VfsUtils::keyWritten, this, [&](const QString& key){
		if(key == mVfsUtils.getApplicationVfsEncryptionKey()){
			if(!getVfsEncrypted()){
				QSettings settings;
				settings.beginGroup("keychain");
				settings.setValue("enabled", true);
				emit vfsEncryptedChanged();
			}
		}
	});
	connect(&mVfsUtils, &VfsUtils::keyDeleted, this, [&](const QString& key){
		if(key == mVfsUtils.getApplicationVfsEncryptionKey()){
			QSettings settings;
			settings.beginGroup("keychain");
			settings.setValue("enabled", false);
			emit vfsEncryptedChanged();
			if(mVfsUtils.needToDeleteUserData())
				Utils::deleteAllUserData();
			else{
				qInfo() << "Exiting App from VFS settings";
				App::getInstance()->quit();
			}
		}
	});
	
	
	connect(&mVfsUtils, &VfsUtils::error, this, [&](){
		
	});
#endif
	updateRlsUri();
	shared_ptr<linphone::Factory> factory = linphone::Factory::get();
	factory->setDownloadDir(Utils::appStringToCoreString(getDownloadFolder()));
}

SettingsModel::~SettingsModel()
{
	if(mSimpleCaptureGraph ) {
		delete mSimpleCaptureGraph;
		mSimpleCaptureGraph = nullptr;
	}
}

void SettingsModel::settingsWindowClosing(void) {
	onSettingsTabChanged(-1);
}

void SettingsModel::reloadDevices(){
	CoreManager::getInstance()->getCore()->reloadSoundDevices();
	emit captureDevicesChanged(getCaptureDevices());
	emit playbackDevicesChanged(getPlaybackDevices());
	emit playbackDeviceChanged(getPlaybackDevice());
	emit captureDeviceChanged(getCaptureDevice());
	emit ringerDeviceChanged(getRingerDevice());
	CoreManager::getInstance()->getCore()->reloadVideoDevices();
	emit videoDevicesChanged(getVideoDevices());
}

//Provides tabbar per-tab setup/teardown mechanism for specific settings views
void SettingsModel::onSettingsTabChanged(int idx) {
	int prevIdx = mCurrentSettingsTab;
	mCurrentSettingsTab = idx;

	switch (prevIdx) {
	case 0://sip
		break;
	case 1://audio
		closeAudioSettings();
		break;
	case 2://video
		break;
	case 3://call
		break;
	case 4://ui
		break;
	case 5://advanced
		break;
	default:
		break;
	}
	switch (idx) {
	case 0://sip
		break;
	case 1://audio
		accessAudioSettings();
		break;
	case 2://video
		accessVideoSettings();
		break;
	case 3://call
		break;
	case 4://ui
		break;
	case 5://advanced
		accessAdvancedSettings();
		break;
	default:
		break;
	}
}

// =============================================================================
// Assistant.
// =============================================================================

bool SettingsModel::getUseAppSipAccountEnabled () const {
	return !!mConfig->getInt(UiSection, "use_app_sip_account_enabled", 1);
}

void SettingsModel::setUseAppSipAccountEnabled (bool status) {
	mConfig->setInt(UiSection, "use_app_sip_account_enabled", status);
	emit useAppSipAccountEnabledChanged(status);
}

bool SettingsModel::getUseOtherSipAccountEnabled () const {
	return !!mConfig->getInt(UiSection, "use_other_sip_account_enabled", 1);
}

void SettingsModel::setUseOtherSipAccountEnabled (bool status) {
	mConfig->setInt(UiSection, "use_other_sip_account_enabled", status);
	emit useOtherSipAccountEnabledChanged(status);
}

bool SettingsModel::getCreateAppSipAccountEnabled () const {
	return !!mConfig->getInt(UiSection, "create_app_sip_account_enabled", 1);
}

void SettingsModel::setCreateAppSipAccountEnabled (bool status) {
	mConfig->setInt(UiSection, "create_app_sip_account_enabled", status);
	emit createAppSipAccountEnabledChanged(status);
}

bool SettingsModel::getFetchRemoteConfigurationEnabled () const {
	return !!mConfig->getInt(UiSection, "fetch_remote_configuration_enabled", 1);
}

void SettingsModel::setFetchRemoteConfigurationEnabled (bool status) {
	mConfig->setInt(UiSection, "fetch_remote_configuration_enabled", status);
	emit fetchRemoteConfigurationEnabledChanged(status);
}

bool SettingsModel::getAutoApplyProvisioningConfigUriHandlerEnabled () const {
	return !!mConfig->getInt(UiSection, "auto_apply_provisioning_config_uri_handler", 0);
}

void SettingsModel::setAutoApplyProvisioningConfigUriHandlerEnabled (bool status) {
	mConfig->setInt(UiSection, "auto_apply_provisioning_config_uri_handler", status);
	emit autoApplyProvisioningConfigUriHandlerEnabledChanged();
}


// ---------------------------------------------------------------------------

bool SettingsModel::getAssistantSupportsPhoneNumbers () const {
	return !!mConfig->getInt(UiSection, getEntryFullName(UiSection, "assistant_supports_phone_numbers") , 1);
}

void SettingsModel::setAssistantSupportsPhoneNumbers (bool status) {
	if(!isReadOnly(UiSection, "assistant_supports_phone_numbers")) {
		mConfig->setInt(UiSection, "assistant_supports_phone_numbers", status);
		emit assistantSupportsPhoneNumbersChanged(status);
	}
}

bool SettingsModel::useWebview() const{
#ifdef ENABLE_APP_WEBVIEW
	return true;
#else
	return false;
#endif
}

QString SettingsModel::getAssistantRegistrationUrl () const {
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "assistant_registration_url", Constants::DefaultAssistantRegistrationUrl));
}

void SettingsModel::setAssistantRegistrationUrl (QString url) {
	mConfig->setString(UiSection, "assistant_registration_url", Utils::appStringToCoreString(url));
	emit assistantRegistrationUrlChanged(url);
}

QString SettingsModel::getAssistantLoginUrl () const {
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "assistant_login_url", Constants::DefaultAssistantLoginUrl));
}

void SettingsModel::setAssistantLoginUrl (QString url) {
	mConfig->setString(UiSection, "assistant_login_url", Utils::appStringToCoreString(url));
	emit assistantLoginUrlChanged(url);
}

QString SettingsModel::getAssistantLogoutUrl () const {
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "assistant_logout_url", Constants::DefaultAssistantLogoutUrl));
}

void SettingsModel::setAssistantLogoutUrl (QString url) {
	mConfig->setString(UiSection, "assistant_logout_url", Utils::appStringToCoreString(url));
	emit assistantLogoutUrlChanged(url);
}

bool SettingsModel::isCguAccepted () const{
#ifdef APPLICATION_VENDOR
	QString applicationVendor = APPLICATION_VENDOR;
#else
	QString applicationVendor;
#endif
	return !!mConfig->getInt(UiSection, "read_and_agree_terms_and_privacy", ( applicationVendor != "" && Constants::CguUrl != QString("") && Constants::PrivatePolicyUrl != QString("") ? 0 : 1));
}

void SettingsModel::acceptCgu(const bool accept){
	bool oldAccept = isCguAccepted();
	if( oldAccept != accept){
		mConfig->setInt(UiSection, "read_and_agree_terms_and_privacy", accept);
		emit cguAcceptedChanged(accept);
	}
}

// =============================================================================
// SIP Accounts.
// =============================================================================

QString SettingsModel::getDeviceName(const std::shared_ptr<linphone::Config>& config){
	return Utils::coreStringToAppString(config->getString(UiSection, "device_name", Utils::appStringToCoreString(QSysInfo::machineHostName())));
}

QString SettingsModel::getDeviceName() const{
	return getDeviceName(mConfig);
}

void SettingsModel::setDeviceName(const QString& deviceName){
	mConfig->setString(UiSection, "device_name", Utils::appStringToCoreString(deviceName));
	emit deviceNameChanged();
	CoreManager::getInstance()->updateUserAgent();
}

// =============================================================================
// Audio.
// =============================================================================

void SettingsModel::resetCaptureGraph() {
	deleteCaptureGraph();
	createCaptureGraph();
}
void SettingsModel::createCaptureGraph() {
	mSimpleCaptureGraph =
			new MediastreamerUtils::SimpleCaptureGraph(Utils::appStringToCoreString(getCaptureDevice()), Utils::appStringToCoreString(getPlaybackDevice()));
	mSimpleCaptureGraph->start();
	emit captureGraphRunningChanged(getCaptureGraphRunning());
}
void SettingsModel::startCaptureGraph(){
	if(!mSimpleCaptureGraph)
		createCaptureGraph();
	++mCaptureGraphListenerCount;
}
void SettingsModel::stopCaptureGraph(){
	if(mCaptureGraphListenerCount > 0 ){
		if(--mCaptureGraphListenerCount == 0)
			deleteCaptureGraph();
	}
}
void SettingsModel::deleteCaptureGraph(){
	if (mSimpleCaptureGraph) {
		if (mSimpleCaptureGraph->isRunning()) {
			mSimpleCaptureGraph->stop();
		}
		delete mSimpleCaptureGraph;
		mSimpleCaptureGraph = nullptr;
	}
}
//Force a call on the 'detect' method of all audio filters, updating new or removed devices
void SettingsModel::accessAudioSettings() {	
	CoreManager::getInstance()->getCore()->reloadSoundDevices();
	emit captureDevicesChanged(getCaptureDevices());
	emit playbackDevicesChanged(getPlaybackDevices());
	emit playbackDeviceChanged(getPlaybackDevice());
	emit captureDeviceChanged(getCaptureDevice());
	emit ringerDeviceChanged(getRingerDevice());
	emit playbackGainChanged(getPlaybackGain());
	emit captureGainChanged(getCaptureGain());

	//if (!getIsInCall()) {
		startCaptureGraph();
	//}
}

void SettingsModel::closeAudioSettings() {
	stopCaptureGraph();
	emit captureGraphRunningChanged(getCaptureGraphRunning());
}

bool SettingsModel::getCaptureGraphRunning() {
	return mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning() && !getIsInCall();
}

float SettingsModel::getMicVolume() {
	float v = 0.0;

	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		v = mSimpleCaptureGraph->getCaptureVolume();
	}
	return v;
}

float SettingsModel::getPlaybackGain() const {
	float dbGain = CoreManager::getInstance()->getCore()->getPlaybackGainDb();
	return MediastreamerUtils::dbToLinear(dbGain);
}

void SettingsModel::setPlaybackGain(float gain) {
	float oldGain = getPlaybackGain();
	CoreManager::getInstance()->getCore()->setPlaybackGainDb(MediastreamerUtils::linearToDb(gain));
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setPlaybackGain(gain);
	}
	if((int)(oldGain*1000) != (int)(gain*1000))
		emit playbackGainChanged(gain);
}

float SettingsModel::getCaptureGain() const {
	float dbGain = CoreManager::getInstance()->getCore()->getMicGainDb();
	return MediastreamerUtils::dbToLinear(dbGain);
}

void SettingsModel::setCaptureGain(float gain) {
	float oldGain = getCaptureGain();
	CoreManager::getInstance()->getCore()->setMicGainDb(MediastreamerUtils::linearToDb(gain));
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setCaptureGain(gain);
	}
	if((int)(oldGain *1000) != (int)(gain *1000))
		emit captureGainChanged(gain);
}

QStringList SettingsModel::getCaptureDevices () const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	QStringList list;

	for (const auto &device : core->getSoundDevicesList()) {
		if (core->soundDeviceCanCapture(device))
			list << Utils::coreStringToAppString(device);
	}
	return list;
}

QStringList SettingsModel::getPlaybackDevices () const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	QStringList list;

	for (const auto &device : core->getSoundDevicesList()) {
		if (core->soundDeviceCanPlayback(device)) {
			list << Utils::coreStringToAppString(device);
		}
	}

	return list;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getCaptureDevice () const {
	auto audioDevice = CoreManager::getInstance()->getCore()->getInputAudioDevice();
	return Utils::coreStringToAppString(audioDevice? audioDevice->getId() : CoreManager::getInstance()->getCore()->getCaptureDevice());
}

void SettingsModel::setCaptureDevice (const QString &device) {
	std::string devId = Utils::appStringToCoreString(device);
	auto list = CoreManager::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice = find_if(list.cbegin(), list.cend(), [&] ( const std::shared_ptr<linphone::AudioDevice> & audioItem) {
	   return audioItem->getId() == devId;
	});
	if(audioDevice != list.cend()){
		CoreManager::getInstance()->getCore()->setCaptureDevice(devId);
		CoreManager::getInstance()->getCore()->setInputAudioDevice(*audioDevice);
		emit captureDeviceChanged(device);
		resetCaptureGraph();
	}else
		qWarning() << "Cannot set Capture device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getPlaybackDevice () const {
	auto audioDevice = CoreManager::getInstance()->getCore()->getOutputAudioDevice();
	return Utils::coreStringToAppString(audioDevice? audioDevice->getId() : CoreManager::getInstance()->getCore()->getPlaybackDevice());
}

void SettingsModel::setPlaybackDevice (const QString &device) {
	std::string devId = Utils::appStringToCoreString(device);

	auto list = CoreManager::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice = find_if(list.cbegin(), list.cend(), [&] ( const std::shared_ptr<linphone::AudioDevice> & audioItem) {
	   return audioItem->getId() == devId;
	});
	if(audioDevice != list.cend()){

		CoreManager::getInstance()->getCore()->setPlaybackDevice(devId);
		CoreManager::getInstance()->getCore()->setOutputAudioDevice(*audioDevice);
		emit playbackDeviceChanged(device);
		resetCaptureGraph();
	}else
		qWarning() << "Cannot set Playback device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRingerDevice () const {
	return Utils::coreStringToAppString(
					    CoreManager::getInstance()->getCore()->getRingerDevice()
					    );
}

void SettingsModel::setRingerDevice (const QString &device) {
	CoreManager::getInstance()->getCore()->setRingerDevice(
							       Utils::appStringToCoreString(device)
							       );
	emit ringerDeviceChanged(device);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRingPath () const {
	return Utils::coreStringToAppString(CoreManager::getInstance()->getCore()->getRing());
}

void SettingsModel::setRingPath (const QString &path) {
	QString cleanedPath = QDir::cleanPath(path);

	CoreManager::getInstance()->getCore()->setRing(
						       Utils::appStringToCoreString(cleanedPath)
						       );

	emit ringPathChanged(cleanedPath);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getEchoCancellationEnabled () const {
	return CoreManager::getInstance()->getCore()->echoCancellationEnabled();
}

void SettingsModel::setEchoCancellationEnabled (bool status) {
	CoreManager::getInstance()->getCore()->enableEchoCancellation(status);
	emit echoCancellationEnabledChanged(status);
}

void SettingsModel::startEchoCancellerCalibration(){
	CoreManager::getInstance()->getCore()->startEchoCancellerCalibration();

}
// -----------------------------------------------------------------------------

bool SettingsModel::getShowAudioCodecs () const {
	return !!mConfig->getInt(UiSection, "show_audio_codecs", 1);
}

void SettingsModel::setShowAudioCodecs (bool status) {
	mConfig->setInt(UiSection, "show_audio_codecs", status);
	emit showAudioCodecsChanged(status);
}


// =============================================================================
// Video.
// =============================================================================

//Force a call on the 'detect' method of all video filters, updating new or removed devices
void SettingsModel::accessVideoSettings() {
	//if(!getIsInCall())// TODO : This is a workaround to a crash when reloading video devices while in call. Spotted on Macos.
		CoreManager::getInstance()->getCore()->reloadVideoDevices();
	emit videoDevicesChanged(getVideoDevices());
}

QStringList SettingsModel::getVideoDevices () const {
	QStringList list;

	for (const auto &device : CoreManager::getInstance()->getCore()->getVideoDevicesList())
		list << Utils::coreStringToAppString(device);

	return list;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getVideoDevice () const {
	return Utils::coreStringToAppString(
					    CoreManager::getInstance()->getCore()->getVideoDevice()
					    );
}

void SettingsModel::setVideoDevice (const QString &device) {
	CoreManager::getInstance()->getCore()->setVideoDevice(
							      Utils::appStringToCoreString(device)
							      );
	emit videoDeviceChanged(device);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getVideoPreset () const {
	return Utils::coreStringToAppString(
					    CoreManager::getInstance()->getCore()->getVideoPreset()
					    );
}

void SettingsModel::setVideoPreset (const QString &preset) {
	CoreManager::getInstance()->getCore()->setVideoPreset(
							      Utils::appStringToCoreString(preset)
							      );
	emit videoPresetChanged(preset);
}

// -----------------------------------------------------------------------------

int SettingsModel::getVideoFramerate () const {
	return int(CoreManager::getInstance()->getCore()->getPreferredFramerate());
}

void SettingsModel::setVideoFramerate (int framerate) {
	CoreManager::getInstance()->getCore()->setPreferredFramerate(float(framerate));
	emit videoFramerateChanged(framerate);
}

// -----------------------------------------------------------------------------

static inline QVariantMap createMapFromVideoDefinition (const shared_ptr<const linphone::VideoDefinition> &definition) {
	QVariantMap map;

	if (!definition) {
		map["name"] = QStringLiteral("Bad EGG");
		map["width"] = QStringLiteral("?????");
		map["height"] = QStringLiteral("?????");
		return map;
	}

	map["name"] = Utils::coreStringToAppString(definition->getName());
	map["width"] = definition->getWidth();
	map["height"] = definition->getHeight();
	map["__definition"] = QVariant::fromValue(definition);

	return map;
}

QVariantList SettingsModel::getSupportedVideoDefinitions () const {
	QVariantList list;
	for (const auto &definition : linphone::Factory::get()->getSupportedVideoDefinitions())
		list << createMapFromVideoDefinition(definition);
	return list;
}

QVariantMap SettingsModel::getVideoDefinition () const {
	return createMapFromVideoDefinition(CoreManager::getInstance()->getCore()->getPreferredVideoDefinition());
}

QVariantMap SettingsModel::getCurrentPreviewVideoDefinition () const {
	if(CoreManager::getInstance()->getCore()->videoPreviewEnabled()){
		auto definition = CoreManager::getInstance()->getCore()->getCurrentPreviewVideoDefinition();
		if(definition)
			return createMapFromVideoDefinition(definition);
	}
	QVariantMap map;
	map["width"] = 0;
	map["height"] = 0;
	return map;
}

void SettingsModel::setVideoDefinition (const QVariantMap &definition) {
	CoreManager::getInstance()->getCore()->setPreferredVideoDefinition(
									   definition.value("__definition").value<shared_ptr<const linphone::VideoDefinition>>()->clone()
									   );

	emit videoDefinitionChanged(definition);
}

bool SettingsModel::getVideoEnabled() const {
	return CoreManager::getInstance()->getCore()->videoSupported() && !!mConfig->getInt(UiSection, "video_enabled", 1);
}

void SettingsModel::setVideoEnabled(const bool& enable){
	if( CoreManager::getInstance()->getCore()->videoSupported()){
		mConfig->setInt(UiSection, "video_enabled", enable);
		emit videoEnabledChanged();
	}
}

void SettingsModel::setHighMosaicQuality(){
	mConfig->setString("video", "max_mosaic_size", "");
}
void SettingsModel::setLimitedMosaicQuality(){
	mConfig->setString("video", "max_mosaic_size", "vga");
}
// -----------------------------------------------------------------------------

bool SettingsModel::getShowVideoCodecs () const {
	return !!mConfig->getInt(UiSection, "show_video_codecs", 1);
}

void SettingsModel::setShowVideoCodecs (bool status) {
	mConfig->setInt(UiSection, "show_video_codecs", status);
	emit showVideoCodecsChanged(status);
}

bool SettingsModel::getVideoAvailable() const{
	return getVideoEnabled() && haveAtLeastOneVideoCodec();
}

bool SettingsModel::haveAtLeastOneVideoCodec() const{
	auto codecs = CoreManager::getInstance()->getCore()->getVideoPayloadTypes();
	for (auto &codec : codecs){
		if(codec->enabled() && codec->isUsable())
			return true;
	}
	return false;
}

// =============================================================================
void SettingsModel::updateCameraMode(){
	auto mode = mConfig->getString("video", "main_display_mode", "OccupyAllSpace");	
	mConfig->setString("video", "main_display_mode", mode);
	mConfig->setString("video", "other_display_mode", mode);
}

SettingsModel::CameraMode SettingsModel::cameraModefromString(const std::string& mode){
	if( mode == "Hybrid")
		return CameraMode::CameraMode_Hybrid;
	else if( mode == "BlackBars")
		return CameraMode::CameraMode_BlackBars;
	else
		return CameraMode::CameraMode_OccupyAllSpace;
}
std::string SettingsModel::toString(const CameraMode& mode){
	std::string modeStr;
	switch(mode){
		case CameraMode::CameraMode_Hybrid : modeStr = "Hybrid";break;
		case CameraMode::CameraMode_BlackBars: modeStr = "BlackBars";break;
		default: modeStr = "OccupyAllSpace";
	}
	return modeStr;
}
SettingsModel::CameraMode SettingsModel::getCameraMode() const{
	return cameraModefromString(mConfig->getString("video", "main_display_mode", "OccupyAllSpace"));
}

void SettingsModel::setCameraMode(CameraMode mode){
	std::string modeToSet;
	switch(mode){
		case CameraMode::CameraMode_Hybrid : modeToSet = "Hybrid";break;
		case CameraMode::CameraMode_BlackBars: modeToSet = "BlackBars";break;
		default: modeToSet = "OccupyAllSpace";
	}
	mConfig->setString("video", "main_display_mode", modeToSet);
	mConfig->setString("video", "other_display_mode", modeToSet);
	emit cameraModeChanged();
}

SettingsModel::CameraMode SettingsModel::getGridCameraMode() const{
	return cameraModefromString(mConfig->getString(UiSection, "main_grid_display_mode", "OccupyAllSpace"));
}
void SettingsModel::setGridCameraMode(CameraMode mode){
	auto modeStd = toString(mode);
	mConfig->setString(UiSection, "main_grid_display_mode", modeStd);
	emit gridCameraModeChanged();
}
SettingsModel::CameraMode SettingsModel::getActiveSpeakerCameraMode() const{
	return cameraModefromString(mConfig->getString(UiSection, "main_active_speaker_display_mode", "Hybrid"));
}
void SettingsModel::setActiveSpeakerCameraMode(CameraMode mode){
	auto modeStd = toString(mode);
	mConfig->setString(UiSection, "main_active_speaker_display_mode", modeStd);
	emit activeSpeakerCameraModeChanged();
}
SettingsModel::CameraMode SettingsModel::getCallCameraMode() const{
	return cameraModefromString(mConfig->getString(UiSection, "main_call_display_mode", "Hybrid"));
}
void SettingsModel::setCallCameraMode(CameraMode mode){
	auto modeStd = toString(mode);
	mConfig->setString(UiSection, "main_call_display_mode", modeStd);
	emit callCameraModeChanged();
}

LinphoneEnums::ConferenceLayout SettingsModel::getVideoConferenceLayout() const{
	return (LinphoneEnums::ConferenceLayout) mConfig->getInt(UiSection, "video_conference_layout", (int)LinphoneEnums::ConferenceLayoutActiveSpeaker);
}

void SettingsModel::setVideoConferenceLayout(LinphoneEnums::ConferenceLayout layout){
	mConfig->setInt(UiSection, "video_conference_layout", (int)layout);
	emit videoConferenceLayoutChanged();
}

// =============================================================================
// Chat & calls.
// =============================================================================

bool SettingsModel::getAutoAnswerStatus () const {
	return !!mConfig->getInt(UiSection, "auto_answer", 0);
}

void SettingsModel::setAutoAnswerStatus (bool status) {
	mConfig->setInt(UiSection, "auto_answer", status);
	emit autoAnswerStatusChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAutoAnswerVideoStatus () const {
	return !!mConfig->getInt(UiSection, "auto_answer_with_video", 0);
}

void SettingsModel::setAutoAnswerVideoStatus (bool status) {
	mConfig->setInt(UiSection, "auto_answer_with_video", status);
	emit autoAnswerVideoStatusChanged(status);
}

// -----------------------------------------------------------------------------

int SettingsModel::getAutoAnswerDelay () const {
	return mConfig->getInt(UiSection, "auto_answer_delay", 0);
}

void SettingsModel::setAutoAnswerDelay (int delay) {
	mConfig->setInt(UiSection, "auto_answer_delay", delay);
	emit autoAnswerDelayChanged(delay);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getShowTelKeypadAutomatically () const {
	return !!mConfig->getInt(UiSection, "show_tel_keypad_automatically", 0);
}

void SettingsModel::setShowTelKeypadAutomatically (bool status) {
	mConfig->setInt(UiSection, "show_tel_keypad_automatically", status);
	emit showTelKeypadAutomaticallyChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getKeepCallsWindowInBackground () const {
	return !!mConfig->getInt(UiSection, "keep_calls_window_in_background", 0);
}

void SettingsModel::setKeepCallsWindowInBackground (bool status) {
	mConfig->setInt(UiSection, "keep_calls_window_in_background", status);
	emit keepCallsWindowInBackgroundChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getOutgoingCallsEnabled () const {
	return !!mConfig->getInt(UiSection, "outgoing_calls_enabled", 1);
}

void SettingsModel::setOutgoingCallsEnabled (bool status) {
	mConfig->setInt(UiSection, "outgoing_calls_enabled", status);
	emit outgoingCallsEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getCallRecorderEnabled () const {
	return !!mConfig->getInt(UiSection, "call_recorder_enabled", 1);
}

void SettingsModel::setCallRecorderEnabled (bool status) {
	mConfig->setInt(UiSection, "call_recorder_enabled", status);
	emit callRecorderEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAutomaticallyRecordCalls () const {
	return !!mConfig->getInt(UiSection, "automatically_record_calls", 0);
}

void SettingsModel::setAutomaticallyRecordCalls (bool status) {
	mConfig->setInt(UiSection, "automatically_record_calls", status);
	emit automaticallyRecordCallsChanged(status);
}

int SettingsModel::getAutoDownloadMaxSize() const{
	return CoreManager::getInstance()->getCore()->getMaxSizeForAutoDownloadIncomingFiles();
}

void SettingsModel::setAutoDownloadMaxSize(int maxSize){
	if(maxSize != getAutoDownloadMaxSize()){
		CoreManager::getInstance()->getCore()->setMaxSizeForAutoDownloadIncomingFiles(maxSize);
		emit autoDownloadMaxSizeChanged(maxSize);
	}
}
	
// -----------------------------------------------------------------------------

bool SettingsModel::getCallPauseEnabled () const {
	return !!mConfig->getInt(UiSection, "call_pause_enabled", 1);
}

void SettingsModel::setCallPauseEnabled (bool status) {
	mConfig->setInt(UiSection, "call_pause_enabled", status);
	emit callPauseEnabledChanged(status);
}

bool SettingsModel::getMuteMicrophoneEnabled () const {
	return !!mConfig->getInt(UiSection, "mute_microphone_enabled", 1);
}

void SettingsModel::setMuteMicrophoneEnabled (bool status) {
	mConfig->setInt(UiSection, "mute_microphone_enabled", status);
	emit muteMicrophoneEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getStandardChatEnabled () const {
	return !!mConfig->getInt(UiSection, getEntryFullName(UiSection,"standard_chat_enabled"), 1);
}

void SettingsModel::setStandardChatEnabled (bool status) {
	if(!isReadOnly(UiSection, "standard_chat_enabled"))
		mConfig->setInt(UiSection, "standard_chat_enabled", status);
	emit standardChatEnabledChanged(getStandardChatEnabled ());
}

bool SettingsModel::getSecureChatEnabled () const {
	return !!mConfig->getInt(UiSection, getEntryFullName(UiSection, "secure_chat_enabled"), 1)
		&& getLimeIsSupported()
		&& CoreManager::getInstance()->getCore()->getDefaultAccount() && !CoreManager::getInstance()->getCore()->getDefaultAccount()->getParams()->getLimeServerUrl().empty()
		//&& !CoreManager::getInstance()->getCore()->getLimeX3DhServerUrl().empty()
		&& getGroupChatEnabled();
	;
}

void SettingsModel::setSecureChatEnabled (bool status) {
	if(!isReadOnly(UiSection, "secure_chat_enabled"))
		mConfig->setInt(UiSection, "secure_chat_enabled", status);
	emit secureChatEnabledChanged();
}

bool SettingsModel::getGroupChatEnabled() const{
	return CoreManager::getInstance()->getCore()->getDefaultAccount() && !CoreManager::getInstance()->getCore()->getDefaultAccount()->getParams()->getConferenceFactoryUri().empty();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getHideEmptyChatRooms() const{
	int defaultValue = 0;
	if(!mConfig->hasEntry("misc", "hide_empty_chat_rooms"))// This step should be removed when this option comes from API and not directly from config file
		mConfig->setInt("misc", "hide_empty_chat_rooms", defaultValue);
	return !!mConfig->getInt("misc", "hide_empty_chat_rooms", defaultValue);
}

void SettingsModel::setHideEmptyChatRooms(const bool& status){
	mConfig->setInt("misc", "hide_empty_chat_rooms", status);
	emit hideEmptyChatRoomsChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getWaitRegistrationForCall() const{
	return !!mConfig->getInt(UiSection, "call_wait_registration", 0);
}

void SettingsModel::setWaitRegistrationForCall(const bool& status){
	mConfig->setInt(UiSection, "call_wait_registration", status);
	emit waitRegistrationForCallChanged(status);
}

bool SettingsModel::getIncallScreenshotEnabled() const{
	return !!mConfig->getInt(UiSection, "show_take_screenshot_button_in_call", 0);
}

void SettingsModel::setIncallScreenshotEnabled(const bool& status){
	mConfig->setInt(UiSection, "show_take_screenshot_button_in_call", status);
	emit incallScreenshotEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getConferenceEnabled () const {
	return !!mConfig->getInt(UiSection, "conference_enabled", 1);
}

void SettingsModel::setConferenceEnabled (bool status) {
	mConfig->setInt(UiSection, "conference_enabled", status);
	emit conferenceEnabledChanged(status);
}

bool SettingsModel::getVideoConferenceEnabled() const{
	return CoreManager::getInstance()->getCore()->getDefaultAccount() && !!CoreManager::getInstance()->getCore()->getDefaultAccount()->getParams()->getAudioVideoConferenceFactoryAddress();
}
// -----------------------------------------------------------------------------

bool SettingsModel::getChatNotificationsEnabled () const {
	return !!mConfig->getInt(UiSection, "chat_notifications_enabled", 1);
}

void SettingsModel::setChatNotificationsEnabled (bool status) {
	mConfig->setInt(UiSection, "chat_notifications_enabled", status);
	emit chatNotificationsEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getChatNotificationSoundEnabled () const {
	return !!mConfig->getInt(UiSection, "chat_sound_notification_enabled", 1);
}

void SettingsModel::setChatNotificationSoundEnabled (bool status) {
	mConfig->setInt(UiSection, "chat_sound_notification_enabled", status);
	emit chatNotificationSoundEnabledChanged(status);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getChatNotificationSoundPath () const {
	static const string defaultFile = linphone::Factory::get()->getSoundResourcesDir() + "/incoming_chat.wav";
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "chat_sound_notification_file", defaultFile));
}

void SettingsModel::setChatNotificationSoundPath (const QString &path) {
	QString cleanedPath = QDir::cleanPath(path);
	mConfig->setString(UiSection, "chat_sound_notification_file", Utils::appStringToCoreString(cleanedPath));
	emit chatNotificationSoundPathChanged(cleanedPath);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getFileTransferUrl () const {
	return Utils::coreStringToAppString(
					    CoreManager::getInstance()->getCore()->getFileTransferServer()
					    );
}

void SettingsModel::setFileTransferUrl (const QString &url) {
	CoreManager::getInstance()->getCore()->setFileTransferServer(
								     Utils::appStringToCoreString(url)
								     );
	emit fileTransferUrlChanged(url);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getLimeIsSupported () const {
    return CoreManager::getInstance()->getCore()->limeX3DhAvailable();
}

// -----------------------------------------------------------------------------

static inline QVariant buildEncryptionDescription (SettingsModel::MediaEncryption encryption, const char *description) {
	QVariantMap m;
	m["key"] = description;
	m["value"] = encryption;
	return m;
}

QVariantList SettingsModel::getSupportedMediaEncryptions () const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	QVariantList list;

	if (core->mediaEncryptionSupported(linphone::MediaEncryption::SRTP))
		list << buildEncryptionDescription(MediaEncryptionSrtp, "SRTP");

	if (core->mediaEncryptionSupported(linphone::MediaEncryption::ZRTP)){
		if( core->getPostQuantumAvailable())
			list << buildEncryptionDescription(MediaEncryptionZrtp, "Post Quantum ZRTP");
		else
			list << buildEncryptionDescription(MediaEncryptionZrtp, "ZRTP");
	}
	
	if (core->mediaEncryptionSupported(linphone::MediaEncryption::DTLS))
		list << buildEncryptionDescription(MediaEncryptionDtls, "DTLS");

	return list;
}

// -----------------------------------------------------------------------------

SettingsModel::MediaEncryption SettingsModel::getMediaEncryption () const {
	return static_cast<SettingsModel::MediaEncryption>(
							   CoreManager::getInstance()->getCore()->getMediaEncryption()
							   );
}

void SettingsModel::setMediaEncryption (MediaEncryption encryption) {
	if (encryption == getMediaEncryption())
		return;

	CoreManager::getInstance()->getCore()->setMediaEncryption(
								  static_cast<linphone::MediaEncryption>(encryption)
								  );
	if (mandatoryMediaEncryptionEnabled() && encryption == SettingsModel::MediaEncryptionNone) {
		//Disable mandatory encryption if none is selected
		enableMandatoryMediaEncryption(false);
	}

	emit mediaEncryptionChanged(encryption);
}

bool SettingsModel::mandatoryMediaEncryptionEnabled () const {
	return CoreManager::getInstance()->getCore()->isMediaEncryptionMandatory();
}

void SettingsModel::enableMandatoryMediaEncryption(bool mandatory) {
	if (mandatoryMediaEncryptionEnabled() == mandatory) {
		return;
	}
	CoreManager::getInstance()->getCore()->setMediaEncryptionMandatory(mandatory);
	if (mandatory && getMediaEncryption() == SettingsModel::MediaEncryptionNone) {
		//Force	to SRTP if mandatory but 'none' was selected
		setMediaEncryption(SettingsModel::MediaEncryptionSrtp);
	} else {
		emit mediaEncryptionChanged(getMediaEncryption());
	}
}

bool SettingsModel::getPostQuantumAvailable() const{
	return CoreManager::getInstance()->getCore() && CoreManager::getInstance()->getCore()->getPostQuantumAvailable();
}

bool SettingsModel::getDontAskAgainInfoEncryption() const{
	return mConfig->getBool(UiSection, "dont_ask_again_info_encryption", false);
}

void SettingsModel::setDontAskAgainInfoEncryption(bool show){
	if(show != getDontAskAgainInfoEncryption()) {
		mConfig->setBool(UiSection, "dont_ask_again_info_encryption", show);
		emit dontAskAgainInfoEncryptionChanged();
	}
}

bool SettingsModel::getHaveDontAskAgainChoices() const {
	return getDontAskAgainInfoEncryption();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getLimeState () const {
    return  CoreManager::getInstance()->getCore()->limeX3DhEnabled();
}

void SettingsModel::setLimeState (const bool& state) {
	if (state == getLimeState())
		return;

    CoreManager::getInstance()->getCore()->enableLimeX3Dh(state);

	emit limeStateChanged(state);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getContactsEnabled () const {
	return !!mConfig->getInt(UiSection, getEntryFullName(UiSection, "contacts_enabled"), 1);
}

void SettingsModel::setContactsEnabled (bool status) {
	if(!isReadOnly(UiSection, "contacts_enabled"))
		mConfig->setInt(UiSection, "contacts_enabled", status);
	emit contactsEnabledChanged(getContactsEnabled ());
}

int SettingsModel::getIncomingCallTimeout() const {
	return CoreManager::getInstance()->getCore()->getIncTimeout();
}

int SettingsModel::getCreateEphemeralChatRooms() const{
	return mConfig->getInt(UiSection, "create_ephemeral_chat_rooms", 0);
}

void SettingsModel::setCreateEphemeralChatRooms(int seconds) {
	if(!isReadOnly(UiSection, "create_ephemeral_chat_rooms"))
		mConfig->setInt(UiSection, "create_ephemeral_chat_rooms", seconds);
	emit createEphemeralsChatRoomsChanged();
}

// =============================================================================
// Network.
// =============================================================================

bool SettingsModel::getShowNetworkSettings () const {
	return !!mConfig->getInt(UiSection, "show_network_settings", 1);
}

void SettingsModel::setShowNetworkSettings (bool status) {
	mConfig->setInt(UiSection, "show_network_settings", status);
	emit showNetworkSettingsChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getUseSipInfoForDtmfs () const {
	return CoreManager::getInstance()->getCore()->getUseInfoForDtmf();
}

void SettingsModel::setUseSipInfoForDtmfs (bool status) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

	if (status) {
		core->setUseRfc2833ForDtmf(false);
		core->setUseInfoForDtmf(true);
	} else {
		core->setUseInfoForDtmf(false);
		core->setUseRfc2833ForDtmf(true);
	}

	emit dtmfsProtocolChanged();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getUseRfc2833ForDtmfs () const {
	return CoreManager::getInstance()->getCore()->getUseRfc2833ForDtmf();
}

void SettingsModel::setUseRfc2833ForDtmfs (bool status) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

	if (status) {
		core->setUseInfoForDtmf(false);
		core->setUseRfc2833ForDtmf(true);
	} else {
		core->setUseRfc2833ForDtmf(false);
		core->setUseInfoForDtmf(true);
	}

	emit dtmfsProtocolChanged();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getIpv6Enabled () const {
	return CoreManager::getInstance()->getCore()->ipv6Enabled();
}

void SettingsModel::setIpv6Enabled (bool status) {
	CoreManager::getInstance()->getCore()->enableIpv6(status);
	emit ipv6EnabledChanged(status);
}

// -----------------------------------------------------------------------------

int SettingsModel::getDownloadBandwidth () const {
	return CoreManager::getInstance()->getCore()->getDownloadBandwidth();
}

void SettingsModel::setDownloadBandwidth (int bandwidth) {
	CoreManager::getInstance()->getCore()->setDownloadBandwidth(bandwidth);
	emit downloadBandWidthChanged(getDownloadBandwidth());
}

// -----------------------------------------------------------------------------

int SettingsModel::getUploadBandwidth () const {
	return CoreManager::getInstance()->getCore()->getUploadBandwidth();
}

void SettingsModel::setUploadBandwidth (int bandwidth) {
	CoreManager::getInstance()->getCore()->setUploadBandwidth(bandwidth);
	emit uploadBandWidthChanged(getUploadBandwidth());
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAdaptiveRateControlEnabled () const {
	return CoreManager::getInstance()->getCore()->adaptiveRateControlEnabled();
}

void SettingsModel::setAdaptiveRateControlEnabled (bool status) {
	CoreManager::getInstance()->getCore()->enableAdaptiveRateControl(status);
	emit adaptiveRateControlEnabledChanged(status);
}

// -----------------------------------------------------------------------------

int SettingsModel::getTcpPort () const {
	return CoreManager::getInstance()->getCore()->getTransports()->getTcpPort();
}

void SettingsModel::setTcpPort (int port) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Transports> transports = core->getTransports();

	transports->setTcpPort(port);
	core->setTransports(transports);

	emit tcpPortChanged(port);
}

// -----------------------------------------------------------------------------

int SettingsModel::getUdpPort () const {
	return CoreManager::getInstance()->getCore()->getTransports()->getUdpPort();
}

void SettingsModel::setUdpPort (int port) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Transports> transports = core->getTransports();

	transports->setUdpPort(port);
	core->setTransports(transports);

	emit udpPortChanged(port);
}

// -----------------------------------------------------------------------------

QList<int> SettingsModel::getAudioPortRange () const {
	shared_ptr<linphone::Range> range = CoreManager::getInstance()->getCore()->getAudioPortsRange();
	return QList<int>() << range->getMin() << range->getMax();
}

void SettingsModel::setAudioPortRange (const QList<int> &range) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	int a = range[0];
	int b = range[1];

	if (b == -1)
		core->setAudioPort(a);
	else
		core->setAudioPortRange(a, b);

	emit audioPortRangeChanged(a, b);
}

// -----------------------------------------------------------------------------

QList<int> SettingsModel::getVideoPortRange () const {
	shared_ptr<linphone::Range> range = CoreManager::getInstance()->getCore()->getVideoPortsRange();
	return QList<int>() << range->getMin() << range->getMax();
}

void SettingsModel::setVideoPortRange (const QList<int> &range) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	int a = range[0];
	int b = range[1];

	if (b == -1)
		core->setVideoPort(a);
	else
		core->setVideoPortRange(a, b);

	emit videoPortRangeChanged(a, b);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getIceEnabled () const {
	return CoreManager::getInstance()->getCore()->getNatPolicy()->iceEnabled();
}

void SettingsModel::setIceEnabled (bool status) {
	shared_ptr<linphone::NatPolicy> natPolicy = CoreManager::getInstance()->getCore()->getNatPolicy();

	natPolicy->enableIce(status);
	natPolicy->enableStun(status);

	emit iceEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getTurnEnabled () const {
	return CoreManager::getInstance()->getCore()->getNatPolicy()->turnEnabled();
}

void SettingsModel::setTurnEnabled (bool status) {
	CoreManager::getInstance()->getCore()->getNatPolicy()->enableTurn(status);
	emit turnEnabledChanged(status);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getStunServer () const {
	return Utils::coreStringToAppString(
					    CoreManager::getInstance()->getCore()->getNatPolicy()->getStunServer()
					    );
}

void SettingsModel::setStunServer (const QString &stunServer) {
	CoreManager::getInstance()->getCore()->getNatPolicy()->setStunServer(
									     Utils::appStringToCoreString(stunServer)
									     );
}

// -----------------------------------------------------------------------------

QString SettingsModel::getTurnUser () const {
	return Utils::coreStringToAppString(
					    CoreManager::getInstance()->getCore()->getNatPolicy()->getStunServerUsername()
					    );
}

void SettingsModel::setTurnUser (const QString &user) {
	CoreManager::getInstance()->getCore()->getNatPolicy()->setStunServerUsername(
										     Utils::appStringToCoreString(user)
										     );

	emit turnUserChanged(user);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getTurnPassword () const {
	shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());
	shared_ptr<linphone::NatPolicy> natPolicy(core->getNatPolicy());
	shared_ptr<const linphone::AuthInfo> authInfo(core->findAuthInfo(
									 "",
									 natPolicy->getStunServerUsername(),
									 natPolicy->getStunServer()
									 ));
	return authInfo ? Utils::coreStringToAppString(authInfo->getPassword()) : QString("");
}

void SettingsModel::setTurnPassword (const QString &password) {
	shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());
	shared_ptr<linphone::NatPolicy> natPolicy(core->getNatPolicy());

	const string &turnUser(natPolicy->getStunServerUsername());
	shared_ptr<const linphone::AuthInfo> authInfo(core->findAuthInfo("", turnUser, natPolicy->getStunServer()));
	if (authInfo) {
		shared_ptr<linphone::AuthInfo> clonedAuthInfo(authInfo->clone());
		clonedAuthInfo->setPassword(Utils::appStringToCoreString(password));

		core->addAuthInfo(clonedAuthInfo);
		core->removeAuthInfo(authInfo);
	} else
		core->addAuthInfo(linphone::Factory::get()->createAuthInfo(
									   turnUser,
									   turnUser,
									   Utils::appStringToCoreString(password),
									   "",
									   "",
									   ""
									   ));

	emit turnPasswordChanged(password);
}

// -----------------------------------------------------------------------------

int SettingsModel::getDscpSip () const {
	return CoreManager::getInstance()->getCore()->getSipDscp();
}

void SettingsModel::setDscpSip (int dscp) {
	CoreManager::getInstance()->getCore()->setSipDscp(dscp);
	emit dscpSipChanged(dscp);
}

int SettingsModel::getDscpAudio () const {
	return CoreManager::getInstance()->getCore()->getAudioDscp();
}

void SettingsModel::setDscpAudio (int dscp) {
	CoreManager::getInstance()->getCore()->setAudioDscp(dscp);
	emit dscpAudioChanged(dscp);
}

int SettingsModel::getDscpVideo () const {
	return CoreManager::getInstance()->getCore()->getVideoDscp();
}

void SettingsModel::setDscpVideo (int dscp) {
	CoreManager::getInstance()->getCore()->setVideoDscp(dscp);
	emit dscpVideoChanged(dscp);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getRlsUriEnabled () const {
	return !!mConfig->getInt(UiSection, "rls_uri_enabled", true);
}

void SettingsModel::setRlsUriEnabled (bool status) {
	if(getRlsUriEnabled () != status){
		mConfig->setInt(UiSection, "rls_uri_enabled", status);
		emit rlsUriEnabledChanged(status);
	}
}

QString SettingsModel::getRlsUri() const{
	return Utils::coreStringToAppString(mConfig->getString("sip", "rls_uri", ""));
}

void SettingsModel::setRlsUri (const QString& rlsUri){
	bool status = !rlsUri.isEmpty();
	mConfig->setInt(UiSection, "rls_uri_enabled", status);
	mConfig->setString("sip", "rls_uri", Utils::appStringToCoreString(rlsUri));
	emit rlsUriChanged();
	emit rlsUriEnabledChanged(status);
}

void SettingsModel::updateRlsUri(){
	if( getRlsUriEnabled() && getRlsUri().isEmpty()){// if enabled, uri should not be empty : set default. This allow to take account of old configuration.
		setRlsUri(Constants::DefaultRlsUri);
	}
}

//------------------------------------------------------------------------------

bool SettingsModel::tunnelAvailable() const{
	return CoreManager::getInstance()->getCore()->tunnelAvailable();
}

TunnelModel* SettingsModel::getTunnel() const{
	return new TunnelModel(CoreManager::getInstance()->getCore()->getTunnel());
}

// =============================================================================
// UI.
// =============================================================================

QFont SettingsModel::getTextMessageFont() const{
	QString family = Utils::coreStringToAppString(mConfig->getString(UiSection, "text_message_font", Utils::appStringToCoreString(App::getInstance()->font().family())));
	int pointSize = getTextMessageFontSize();
	return QFont(family,pointSize);
}

void SettingsModel::setTextMessageFont(const QFont& font){
	QString family;
	int pointSize;
	if(font == QFont()){
		family = Constants::DefaultFont;
		pointSize = Constants::DefaultFontPointSize;
	}else{
		family = font.family();
		pointSize = font.pointSize();
	}
	mConfig->setString(UiSection, "text_message_font", Utils::appStringToCoreString(family));
	setTextMessageFontSize(pointSize);
	emit textMessageFontChanged(font);
}

int SettingsModel::getTextMessageFontSize() const{
	return mConfig->getInt(UiSection, "text_message_font_size", Constants::DefaultFontPointSize);
}

void SettingsModel::setTextMessageFontSize(const int& size){
	mConfig->setInt(UiSection, "text_message_font_size", size);
	emit textMessageFontSizeChanged(size);
}

QFont SettingsModel::getEmojiFont() const{
	QString family = Utils::coreStringToAppString(mConfig->getString(UiSection, "emoji_font", Utils::appStringToCoreString(QFont(Constants::DefaultEmojiFont).family())));
	int pointSize = getEmojiFontSize();
	return QFont(family,pointSize);
}

void SettingsModel::setEmojiFont(const QFont& font){
	QString family;
	int pointSize;
	if(font == QFont()){
		family = Constants::DefaultEmojiFont;
		pointSize = Constants::DefaultEmojiFontPointSize;
	}else{
		family = font.family();
		pointSize = font.pointSize();
	}
	mConfig->setString(UiSection, "emoji_font", Utils::appStringToCoreString(family));
	setEmojiFontSize(pointSize);
	emit emojiFontChanged(font);
}

int SettingsModel::getEmojiFontSize() const{
	return mConfig->getInt(UiSection, "emoji_font_size", Constants::DefaultEmojiFontPointSize);
}

void SettingsModel::setEmojiFontSize(const int& size){
	mConfig->setInt(UiSection, "emoji_font_size", size);
	emit emojiFontSizeChanged(size);
}
	
QString SettingsModel::getSavedScreenshotsFolder () const {
	auto path = mConfig->getString(UiSection, "saved_screenshots_folder", "");
	if(path == "")
		path = Paths::getCapturesDirPath();
	return QDir::cleanPath(Utils::coreStringToAppString(path)) + QDir::separator();
}

void SettingsModel::setSavedScreenshotsFolder (const QString &folder) {
	QString cleanedFolder = QDir::cleanPath(folder) + QDir::separator();
	mConfig->setString(UiSection, "saved_screenshots_folder", Utils::appStringToCoreString(cleanedFolder));
	emit savedScreenshotsFolderChanged(cleanedFolder);
}

QString SettingsModel::getSpellCheckerOverrideLocale() const{
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "spell_checker_override_locale", ""));
}

void SettingsModel::setSpellCheckerOverrideLocale (const QString &locale) {
	CoreManager::getInstance()->getCore()->getConfig()->setString(
				SettingsModel::UiSection, "spell_checker_override_locale", Utils::appStringToCoreString(locale)
				);
	
	emit spellCheckerOverrideLocaleChanged();
}

bool SettingsModel::getSpellCheckerEnabled() const{
	return mConfig->getBool(UiSection, "spell_checker_enabled", false);
}

void SettingsModel::setSpellCheckerEnabled(bool enable){
	mConfig->setBool(UiSection, "spell_checker_enabled", enable);
	emit spellCheckerEnabledChanged();
}

// -----------------------------------------------------------------------------

static inline string getLegacySavedCallsFolder (const shared_ptr<linphone::Config> &config) {
	auto path = config->getString(SettingsModel::UiSection, "saved_videos_folder", "");
	if(path == "")// Avoid to call default function if exist because calling Path:: will create a folder to be writable.
		path = Paths::getCapturesDirPath();
	return path;
}

QString SettingsModel::getSavedCallsFolder () const {
	auto path = mConfig->getString(UiSection, "saved_calls_folder", "");// Avoid to call default function if exist.
	if(path == "")
		path = getLegacySavedCallsFolder(mConfig);
	return QDir::cleanPath(Utils::coreStringToAppString(path)) + QDir::separator();
}

void SettingsModel::setSavedCallsFolder (const QString &folder) {
	QString cleanedFolder = QDir::cleanPath(folder) + QDir::separator();
	mConfig->setString(UiSection, "saved_calls_folder", Utils::appStringToCoreString(cleanedFolder));
	emit savedCallsFolderChanged(cleanedFolder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getDownloadFolder () const {
	auto path = mConfig->getString(UiSection, "download_folder", "");// Avoid to call default function if exist because calling Path:: will create a folder to be writable.
	if(path == "" )
		path = Paths::getDownloadDirPath();
	return QDir::cleanPath(Utils::coreStringToAppString(path)) + QDir::separator();
}

void SettingsModel::setDownloadFolder (const QString &folder) {
	QString cleanedFolder = QDir::cleanPath(folder) + QDir::separator();
	auto lFolder = Utils::appStringToCoreString(cleanedFolder);
	mConfig->setString(UiSection, "download_folder", lFolder);
	shared_ptr<linphone::Factory> factory = linphone::Factory::get();
	factory->setDownloadDir(lFolder);
	emit downloadFolderChanged(cleanedFolder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRemoteProvisioningRootUrl() const{
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "remote_provisioning_root", Constants::RemoteProvisioningURL));
}

QString SettingsModel::getRemoteProvisioning () const {
	return Utils::coreStringToAppString(CoreManager::getInstance()->getCore()->getProvisioningUri());
}

void SettingsModel::setRemoteProvisioning (const QString &remoteProvisioning) {
	QString urlRemoteProvisioning = remoteProvisioning;
	if( QUrl(urlRemoteProvisioning).isRelative()) {
		urlRemoteProvisioning = getRemoteProvisioningRootUrl() +"/"+ remoteProvisioning;
	}
	if (!CoreManager::getInstance()->getCore()->setProvisioningUri(Utils::appStringToCoreString(urlRemoteProvisioning)))
		emit remoteProvisioningChanged(urlRemoteProvisioning);
	else
		emit remoteProvisioningNotChanged(urlRemoteProvisioning);
}

bool SettingsModel::isQRCodeAvailable() const{
	return linphone::Factory::get()->isQrcodeAvailable() && !!mConfig->getInt(UiSection, "use_qrcode", 1);
}

QString SettingsModel::getFlexiAPIUrl() const{
	return Utils::coreStringToAppString(CoreManager::getInstance()->getCore()->getAccountCreatorUrl());
}
void SettingsModel::setFlexiAPIUrl (const QString &url){
	CoreManager::getInstance()->getCore()->setAccountCreatorUrl(Utils::appStringToCoreString(url));
	emit flexiAPIUrlChanged(url);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getExitOnClose () const {
	return !!mConfig->getInt(UiSection, "exit_on_close", 0);
}

void SettingsModel::setExitOnClose (bool value) {
	mConfig->setInt(UiSection, "exit_on_close", value);
	emit exitOnCloseChanged(value);
}

bool SettingsModel::isCheckForUpdateAvailable(){
#ifdef ENABLE_UPDATE_CHECK
	return true;
#else
	return false;
#endif
}
bool SettingsModel::isCheckForUpdateEnabled() const{
	return !!mConfig->getInt(UiSection, "check_for_update_enabled", isCheckForUpdateAvailable());
}

void SettingsModel::setCheckForUpdateEnabled(bool enable){
	mConfig->setInt(UiSection, "check_for_update_enabled", enable);
	emit checkForUpdateEnabledChanged();
}

QString SettingsModel::getVersionCheckUrl(){
	auto url = mConfig->getString("misc", "version_check_url_root", "");
	if( url == "" ){
		url = Constants::VersionCheckReleaseUrl;
		if( url != "")
			mConfig->setString("misc", "version_check_url_root", url);
	}
	return Utils::coreStringToAppString(url);
}

void SettingsModel::setVersionCheckUrl(const QString& url){
	if( url != getVersionCheckUrl()){
	// Do not trim the url before because we want to update GUI from potential auto fix.
		mConfig->setString("misc", "version_check_url_root", Utils::appStringToCoreString(url.trimmed()));
		if( url == Constants::VersionCheckReleaseUrl)
			setVersionCheckType(VersionCheckType_Release);
		else if( url == Constants::VersionCheckNightlyUrl)
			setVersionCheckType(VersionCheckType_Nightly);
		else
			setVersionCheckType(VersionCheckType_Custom);
		emit versionCheckUrlChanged();
	}
}

QString SettingsModel::getLastRunningVersionOfApp(){
	auto version = mConfig->getString("app_version", "last_running", "unknown");
	return Utils::coreStringToAppString(version);
}

void SettingsModel::setLastRunningVersionOfApp(const QString& version){
	mConfig->setString("app_version", "last_running", Utils::appStringToCoreString(version));
}

SettingsModel::VersionCheckType SettingsModel::getVersionCheckType() const{
	return (SettingsModel::VersionCheckType) mConfig->getInt(UiSection, "version_check_type", (int)VersionCheckType_Release);
}

void SettingsModel::setVersionCheckType(const VersionCheckType& type){
	if( type != getVersionCheckType()){
		mConfig->setInt(UiSection, "version_check_type", (int)type);
		switch(type){
			case VersionCheckType_Release : setVersionCheckUrl(Constants::VersionCheckReleaseUrl); break;
			case VersionCheckType_Nightly : setVersionCheckUrl(Constants::VersionCheckNightlyUrl);break;
			case VersionCheckType_Custom : break;// Do not override URL
		}
		emit versionCheckTypeChanged();
	}
}

bool SettingsModel::haveVersionNightlyUrl()const{
	return QString(Constants::VersionCheckNightlyUrl) != "";
}

// -----------------------------------------------------------------------------

bool SettingsModel::getShowLocalSipAccount()const{
	return !!mConfig->getInt(UiSection, "show_local_sip_account", 1);
}

bool SettingsModel::getShowStartChatButton ()const{
	return !!mConfig->getInt(UiSection, "show_start_chat_button", 1);
}

bool SettingsModel::getShowStartVideoCallButton ()const{
	return !!mConfig->getInt(UiSection, "show_start_video_button", 1);
}

int SettingsModel::getShowDefaultPage() const {
    return mConfig->getInt(UiSection, "show_default_page", -1);
}

int SettingsModel::getShowForcedAssistantPage() const {
    return mConfig->getInt(UiSection, "show_forced_assistant_page", -1);
}

bool SettingsModel::getShowHomePage() const {
    return !!mConfig->getInt(UiSection, "show_home_page", true);
}

bool SettingsModel::getShowHomeInviteButton() const {
	return !!mConfig->getInt(UiSection, "show_home_invite_button", true);
}

QString SettingsModel::getDefaultOtherSipAccountDomain() const {
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "default_other_sip_account_domain", ""));
}

bool SettingsModel::isMipmapEnabled() const{
	return !!mConfig->getInt(UiSection, "mipmap_enabled", 0);
}

void SettingsModel::setMipmapEnabled(const bool& enabled){
	mConfig->setInt(UiSection, "mipmap_enabled", enabled);
	emit mipmapEnabledChanged();
}

bool SettingsModel::useMinimalTimelineFilter() const{
	return !!mConfig->getInt(UiSection, "use_minimal_timeline_filter", 1);
}

void SettingsModel::setUseMinimalTimelineFilter(const bool& useMinimal) {
	mConfig->setInt(UiSection, "use_minimal_timeline_filter", useMinimal);
	emit useMinimalTimelineFilterChanged();
}

Utils::SipDisplayMode SettingsModel::getSipDisplayMode() const{
	return static_cast<Utils::SipDisplayMode>(mConfig->getInt(UiSection, getEntryFullName(UiSection, "sip_display_mode"), (int)Utils::SipDisplayMode::SIP_DISPLAY_ALL));
}

void SettingsModel::setSipDisplayMode(Utils::SipDisplayMode mode){
	if(!isReadOnly(UiSection, "sip_display_mode")) {
		mConfig->setInt(UiSection, "sip_display_mode", (int)mode);
		emit sipDisplayModeChanged();
	}
}

int SettingsModel::getMagicSearchMaxResults() const {
	return mConfig->getInt(UiSection, "magic_search_max_results", 30);
}

void SettingsModel::setMagicSearchMaxResults(int maxResults) {
	if(getMagicSearchMaxResults() != maxResults){
		mConfig->setInt(UiSection, "magic_search_max_results", maxResults);
		emit magicSearchMaxResultsChanged();
	}
}

void SettingsModel::resetDontAskAgainChoices(){
	setDontAskAgainInfoEncryption(false);
}

// =============================================================================
// Advanced.
// =============================================================================

void SettingsModel::accessAdvancedSettings() {
	emit contactImporterChanged();
}

//------------------------------------------------------------------------------

QString SettingsModel::getLogText()const{
	return Logger::getInstance()->getLogText();
}

QString SettingsModel::getLogsFolder () const {
	return getLogsFolder(mConfig);
}

void SettingsModel::setLogsFolder (const QString &folder) {
// Copy all logs files in the new folder path to keep trace of old logs
	std::string logPath = Utils::appStringToCoreString(folder);
	QDir oldDirectory(Utils::coreStringToAppString(CoreManager::getInstance()->getCore()->getLogCollectionPath()));
	QFileInfoList logsFiles = oldDirectory.entryInfoList(QStringList("*.log"));// Get all log files
	for(int i = 0 ; i < logsFiles.size() ; ++i){
		int count = 0;
		QString fileName = logsFiles[i].fileName();
		while( QFile::exists(folder+QDir::separator()+fileName))// assure unicity of backup files
			fileName = logsFiles[i].baseName()+"_"+QString::number(++count)+"."+logsFiles[i].completeSuffix();
		if(QFile::copy(logsFiles[i].filePath(), folder+QDir::separator()+fileName))
			QFile::remove(logsFiles[i].filePath());
	}
	mConfig->setString(UiSection, "logs_folder", logPath);			// Update configuration file
	CoreManager::getInstance()->getCore()->setLogCollectionPath(logPath);	// Update Core to the new path. Liblinphone should update it.
	emit logsFolderChanged(folder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getLogsUploadUrl () const {
	return Utils::coreStringToAppString(
					    CoreManager::getInstance()->getCore()->getLogCollectionUploadServerUrl()
					    );
}

void SettingsModel::setLogsUploadUrl (const QString &url) {
	CoreManager::getInstance()->getCore()->setLogCollectionUploadServerUrl(
									       Utils::appStringToCoreString(url)
									       );

	emit logsUploadUrlChanged(getLogsUploadUrl());
}

// -----------------------------------------------------------------------------

bool SettingsModel::getLogsEnabled () const {
	return getLogsEnabled(mConfig);
}

void SettingsModel::setLogsEnabled (bool status) {
	mConfig->setInt(UiSection, "logs_enabled", status);
	Logger::getInstance()->enable(status);
	emit logsEnabledChanged(status);
}

bool SettingsModel::getFullLogsEnabled () const {
	return getFullLogsEnabled(mConfig);
}

void SettingsModel::setFullLogsEnabled (bool status) {
	mConfig->setInt(UiSection, "full_logs_enabled", status);
	Logger::getInstance()->enableFullLogs(status);
	emit fullLogsEnabledChanged();
}

// ---------------------------------------------------------------------------

QString SettingsModel::getLogsEmail () const {
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "logs_email", Constants::DefaultLogsEmail)
					    );
}

void SettingsModel::setLogsEmail (const QString &email) {
	mConfig->setString(UiSection, "logs_email", Utils::appStringToCoreString(email));
	emit logsEmailChanged(email);
}

bool SettingsModel::isLdapAvailable(){
	return CoreManager::getInstance()->getCore()->ldapAvailable();
}

bool SettingsModel::isOAuth2Available(){
	return AssistantModel::isOAuth2Available();
}

QString SettingsModel::getOAuth2AuthorizationUrl()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_authorization_url", Constants::OAuth2AuthorizationUrl)
					    );
}

QString SettingsModel::getOAuth2AccessTokenUrl()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_access_token_url", Constants::OAuth2AccessTokenUrl)
					    );
}

QString SettingsModel::getOAuth2RedirectUri()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_redirect_uri", Constants::OAuth2RedirectUri)
					    );
}

QString SettingsModel::getOAuth2Identifier()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_identifier", Constants::OAuth2Identifier)
					    );
}

QString SettingsModel::getOAuth2Password()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_password", Constants::OAuth2Password)
					    );
}

QString SettingsModel::getOAuth2Scope()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_scope", Constants::OAuth2Scope)
					    );
}

QString SettingsModel::getOAuth2RemoteProvisioningBasicAuth()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_remote_provisioning_basic_auth", Constants::RemoteProvisioningBasicAuth)
					    );
}

QString SettingsModel::getOAuth2RemoteProvisioningHeader()const{
	return Utils::coreStringToAppString(
					    mConfig->getString(UiSection, "oauth2_remote_provisioning_header", Constants::DefaultOAuth2RemoteProvisioningHeader)
					    );
}

// ---------------------------------------------------------------------------

QString SettingsModel::getLogsFolder (const shared_ptr<linphone::Config> &config) {
	return Utils::coreStringToAppString(config
					    ? config->getString(UiSection, "logs_folder", Paths::getLogsDirPath())
					    : Paths::getLogsDirPath());
}

bool SettingsModel::getLogsEnabled (const shared_ptr<linphone::Config> &config) {
	return config ? config->getInt(UiSection, "logs_enabled", false) : true;
}

bool SettingsModel::getFullLogsEnabled (const shared_ptr<linphone::Config> &config) {
	return config ? config->getInt(UiSection, "full_logs_enabled", false) : false;
}
// ---------------------------------------------------------------------------

bool SettingsModel::getVfsEncrypted (){
	QSettings settings;
	settings.beginGroup("keychain");
	return settings.value("enabled", false).toBool();
}

void SettingsModel::setVfsEncrypted (bool encrypted, const bool deleteUserData){
#ifdef ENABLE_QT_KEYCHAIN
	if(getVfsEncrypted() != encrypted){
		if(encrypted) {
			mVfsUtils.newEncryptionKeyAsync();
		}else{// Remove key, stop core, delete data and initiate reboot
			mVfsUtils.needToDeleteUserData(deleteUserData);
			mVfsUtils.deleteKey(mVfsUtils.getApplicationVfsEncryptionKey());
		}
	}
#endif
}

// ---------------------------------------------------------------------------

bool SettingsModel::isDeveloperSettingsAvailable() const {
#ifdef DEBUG
	return true;
#else
	return false;
#endif
}
bool SettingsModel::getDeveloperSettingsEnabled () const {
#ifdef DEBUG
	return !!mConfig->getInt(UiSection, "developer_settings", 0);
#else
	return false;
#endif // ifdef DEBUG
}

void SettingsModel::setDeveloperSettingsEnabled (bool status) {
#ifdef DEBUG
	mConfig->setInt(UiSection, "developer_settings", status);
	emit developerSettingsEnabledChanged(status);
#else
    Q_UNUSED(status)
	qWarning() << QStringLiteral("Unable to change developer settings mode in release version.");
#endif // ifdef DEBUG
}

void SettingsModel::handleCallCreated(const shared_ptr<linphone::Call> &) {
	emit isInCallChanged(getIsInCall());
}

void SettingsModel::handleCallStateChanged(const shared_ptr<linphone::Call> &, linphone::Call::State) {
	emit isInCallChanged(getIsInCall());
}
void SettingsModel::handleEcCalibrationResult(linphone::EcCalibratorStatus status, int delayMs){
	emit echoCancellationStatus((int)status, delayMs);
}
bool SettingsModel::getIsInCall() const {
	return CoreManager::getInstance()->getCore()->getCallsNb() != 0;
}

bool SettingsModel::isReadOnly(const std::string& section, const std::string& name) const {
	return mConfig->hasEntry(section, name+"/readonly");
}

std::string SettingsModel::getEntryFullName(const std::string& section, const std::string& name) const {
	return isReadOnly(section, name)?name+"/readonly" : name;
}

void SettingsModel::onDefaultAccountChanged(){
	mConfig->setInt("misc", "hide_chat_rooms_from_removed_proxies", CoreManager::getInstance()->getCore()->getDefaultAccount() != nullptr);
}
