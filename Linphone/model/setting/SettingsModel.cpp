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

#include "SettingsModel.hpp"
#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/tool/ToolModel.hpp"
// #include "model/tool/VfsUtils.hpp"
#include "tool/Utils.hpp"

// =============================================================================

DEFINE_ABSTRACT_OBJECT(SettingsModel)

using namespace std;

const std::string SettingsModel::UiSection("ui");
const std::string SettingsModel::AppSection("app");
const std::string SettingsModel::CardDAVSection("carddav_0");
std::shared_ptr<SettingsModel> SettingsModel::gSettingsModel;

SettingsModel::SettingsModel() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	connect(CoreModel::getInstance()->thread(), &QThread::finished, this, [this]() {
		// Model thread
		gSettingsModel = nullptr;
	});
	auto core = CoreModel::getInstance()->getCore();
	mConfig = core->getConfig();
	CoreModel::getInstance()->getLogger()->applyConfig(mConfig);
	// Only activate on enabled. If not, we should keep old configuration.
	if (dndEnabled()) enableDnd(true);
	QObject::connect(
	    CoreModel::getInstance().get(), &CoreModel::globalStateChanged, this,
	    [this](const std::shared_ptr<linphone::Core> &core, linphone::GlobalState gstate, const std::string &message) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    if (gstate == linphone::GlobalState::On) { // reached when misc|config-uri is set in config and app starts
			                                           // and after config is fetched.
			    notifyConfigReady();
		    }
	    });
	QObject::connect(CoreModel::getInstance().get(), &CoreModel::configuringStatus, this,
	                 [this](const std::shared_ptr<linphone::Core> &core, linphone::ConfiguringState status,
	                        const std::string &message) {
		                 mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		                 if (status == linphone::ConfiguringState::Successful) {
			                 mConfig = core->getConfig();
			                 notifyConfigReady();
		                 }
	                 });
	QObject::connect(
	    CoreModel::getInstance().get(), &CoreModel::defaultAccountChanged, this,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> account) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    setDisableMeetingsFeature(account && !account->getParams()->getAudioVideoConferenceFactoryAddress());
	    });
	auto defaultAccount = core->getDefaultAccount();
	setDisableMeetingsFeature(defaultAccount && !defaultAccount->getParams()->getAudioVideoConferenceFactoryAddress());
	// Media cards must not be used twice (capture card + call) else we will get latencies issues and bad echo
	// calibrations in call.
	QObject::connect(CoreModel::getInstance().get(), &CoreModel::firstCallStarted, this,
	                 [this]() { deleteCaptureGraph(); });
	QObject::connect(CoreModel::getInstance().get(), &CoreModel::lastCallEnded, this, [this]() {
		if (mCaptureGraphListenerCount > 0) createCaptureGraph(); // Repair the capture graph
	});
	QObject::connect(CoreModel::getInstance().get(), &CoreModel::audioDevicesListUpdated, this,
	                 [this](const std::shared_ptr<linphone::Core> &core) {
		                 lInfo() << log().arg("audio device list updated");
		                 updateCallSettings();
	                 });
	QObject::connect(
	    CoreModel::getInstance().get(), &CoreModel::audioDeviceChanged, this,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::AudioDevice> &device) {
		    lInfo() << log().arg("audio device changed");
		    if (device) lInfo() << "device :" << device->getDeviceName();
		    // emit playbackDeviceChanged(getPlaybackDevice());
		    // emit captureDeviceChanged(getCaptureDevice());
		    // emit ringerDeviceChanged(getRingerDevice());
	    });
}

SettingsModel::~SettingsModel() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
}

shared_ptr<SettingsModel> SettingsModel::create() {
	// auto model = Utils::makeQObject_ptr<SettingsModel>();
	if (gSettingsModel) return gSettingsModel;
	auto model = make_shared<SettingsModel>();
	gSettingsModel = model;
	return model;
}

shared_ptr<SettingsModel> SettingsModel::getInstance() {
	return gSettingsModel;
}

bool SettingsModel::isReadOnly(const std::string &section, const std::string &name) const {
	return mConfig->hasEntry(section, name + "/readonly");
}

std::string SettingsModel::getEntryFullName(const std::string &section, const std::string &name) const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return isReadOnly(section, name) ? name + "/readonly" : name;
}

// =============================================================================
// Audio.
// =============================================================================

bool SettingsModel::getIsInCall() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->getCallsNb() != 0;
}

void SettingsModel::resetCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mSimpleCaptureGraph) {
		deleteCaptureGraph();
		createCaptureGraph();
	}
}

void SettingsModel::createCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mSimpleCaptureGraph =
	    new MediastreamerUtils::SimpleCaptureGraph(Utils::appStringToCoreString(getCaptureDevice()["id"].toString()),
	                                               Utils::appStringToCoreString(getPlaybackDevice()["id"].toString()));
	mSimpleCaptureGraph->start();
	emit captureGraphRunningChanged(getCaptureGraphRunning());
}
void SettingsModel::deleteCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mSimpleCaptureGraph) {
		if (mSimpleCaptureGraph->isRunning()) {
			mSimpleCaptureGraph->stop();
		}
		delete mSimpleCaptureGraph;
		mSimpleCaptureGraph = nullptr;
	}
}
void SettingsModel::stopCaptureGraphs() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mCaptureGraphListenerCount > 0) {
		mCaptureGraphListenerCount = 0;
		deleteCaptureGraph();
	}
}

void SettingsModel::startCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	// Media cards must not be used twice (capture card + call) else we will get latencies issues and bad echo
	// calibrations in call.
	if (!getIsInCall() && !mSimpleCaptureGraph) {
		lDebug() << log().arg("Starting capture graph [%1]").arg(mCaptureGraphListenerCount);
		createCaptureGraph();
	} else lDebug() << log().arg("Adding capture graph reference [%1]").arg(mCaptureGraphListenerCount);
	++mCaptureGraphListenerCount;
}
void SettingsModel::stopCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (--mCaptureGraphListenerCount == 0) {
		lDebug() << log().arg("Stopping capture graph [%1]").arg(mCaptureGraphListenerCount);
		deleteCaptureGraph();
	} else if (mCaptureGraphListenerCount > 0)
		lDebug() << log().arg("Removing capture graph reference [%1]").arg(mCaptureGraphListenerCount);
	else qCritical() << log().arg("Removing too much capture graph reference [%1]").arg(mCaptureGraphListenerCount);
}

// Force a call on the 'detect' method of all audio filters, updating new or removed devices
void SettingsModel::accessCallSettings() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	startCaptureGraph();

	// Audio
	CoreModel::getInstance()->getCore()->reloadSoundDevices();
	emit captureDevicesChanged(getCaptureDevices());
	emit playbackDevicesChanged(getPlaybackDevices());
	emit playbackDeviceChanged(getPlaybackDevice());
	emit ringerDevicesChanged(getRingerDevices());
	emit ringerDeviceChanged(getRingerDevice());
	emit captureDeviceChanged(getCaptureDevice());
	emit playbackGainChanged(getPlaybackGain());
	emit captureGainChanged(getCaptureGain());

	// Video
	CoreModel::getInstance()->getCore()->reloadVideoDevices();
	emit videoDevicesChanged(getVideoDevices());
}

void SettingsModel::updateCallSettings() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));

	// Audio
	emit captureDevicesChanged(getCaptureDevices());
	emit playbackDevicesChanged(getPlaybackDevices());
	emit playbackDeviceChanged(getPlaybackDevice());
	emit ringerDevicesChanged(getRingerDevices());
	emit ringerDeviceChanged(getRingerDevice());
	emit captureDeviceChanged(getCaptureDevice());
	emit playbackGainChanged(getPlaybackGain());
	emit captureGainChanged(getCaptureGain());

	// Video
	emit videoDevicesChanged(getVideoDevices());
}

void SettingsModel::closeCallSettings() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	stopCaptureGraph();
	emit captureGraphRunningChanged(getCaptureGraphRunning());
}

bool SettingsModel::getCaptureGraphRunning() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning() && !getIsInCall();
}

float SettingsModel::getMicVolume() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	float v = 0.0;
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		v = mSimpleCaptureGraph->getCaptureVolume();
	} else {
		auto call = CoreModel::getInstance()->getCore()->getCurrentCall();
		if (call) {
			v = call->getRecordVolume();
		}
	}

	emit micVolumeChanged(v);
	return v;
}

float SettingsModel::getPlaybackGain() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		return mSimpleCaptureGraph->getPlaybackGain();
	} else {
		auto call = CoreModel::getInstance()->getCore()->getCurrentCall();
		if (call) return call->getSpeakerVolumeGain();
		else return 0.0;
	}
}

void SettingsModel::setPlaybackGain(float gain) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	float oldGain = getPlaybackGain();
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setPlaybackGain(gain);
	}
	auto currentCall = CoreModel::getInstance()->getCore()->getCurrentCall();
	if (currentCall) {
		currentCall->setSpeakerVolumeGain(gain);
	}
	if ((int)(oldGain * 1000) != (int)(gain * 1000)) emit playbackGainChanged(gain);
}

float SettingsModel::getCaptureGain() const {
	mustBeInLinphoneThread(getClassName());
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		return mSimpleCaptureGraph->getCaptureGain();
	} else {
		auto call = CoreModel::getInstance()->getCore()->getCurrentCall();
		if (call) return call->getMicrophoneVolumeGain();
		else return 0.0;
	}
}

void SettingsModel::setCaptureGain(float gain) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	float oldGain = getCaptureGain();
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setCaptureGain(gain);
	}
	auto currentCall = CoreModel::getInstance()->getCore()->getCurrentCall();
	if (currentCall) {
		currentCall->setMicrophoneVolumeGain(gain);
	}
	if ((int)(oldGain * 1000) != (int)(gain * 1000)) emit captureGainChanged(gain);
}

QVariantList SettingsModel::getCaptureDevices() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QVariantList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityRecord)) {
			list << ToolModel::createVariant(device);
		} else if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityAll)) {
			list << ToolModel::createVariant(device);
		}
	}
	return list;
}

QVariantList SettingsModel::getPlaybackDevices() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QVariantList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityPlay)) {
			list << ToolModel::createVariant(device);
		} else if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityAll)) {
			list << ToolModel::createVariant(device);
		}
	}

	return list;
}

QVariantList SettingsModel::getRingerDevices() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QVariantList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityPlay))
			list << ToolModel::createVariant(device);
	}

	return list;
}

QStringList SettingsModel::getVideoDevices() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	QStringList result;
	for (auto &device : core->getVideoDevicesList()) {
		result.append(Utils::coreStringToAppString(device));
	}
	return result;
}

// -----------------------------------------------------------------------------

QVariantMap SettingsModel::getCaptureDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto audioDevice = CoreModel::getInstance()->getCore()->getInputAudioDevice();
	if (!audioDevice) audioDevice = CoreModel::getInstance()->getCore()->getDefaultInputAudioDevice();
	return ToolModel::createVariant(audioDevice);
}

void SettingsModel::setCaptureDevice(const QVariantMap &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto audioDevice =
	    ToolModel::findAudioDevice(device["id"].toString(), linphone::AudioDevice::Capabilities::CapabilityRecord);
	if (audioDevice) {
		CoreModel::getInstance()->getCore()->setDefaultInputAudioDevice(audioDevice);
		CoreModel::getInstance()->getCore()->setInputAudioDevice(audioDevice);
		emit captureDeviceChanged(device);
		resetCaptureGraph();
	} else qWarning() << "Cannot set Capture device. The ID cannot be matched with an existant device : " << device;
}

linphone::Conference::Layout SettingsModel::getDefaultConferenceLayout() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->getDefaultConferenceLayout();
}

void SettingsModel::setDefaultConferenceLayout(const linphone::Conference::Layout layout) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->setDefaultConferenceLayout(layout);
	emit conferenceLayoutChanged();
}

linphone::MediaEncryption SettingsModel::getDefaultMediaEncryption() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->getMediaEncryption();
}

void SettingsModel::setDefaultMediaEncryption(const linphone::MediaEncryption encryption) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->setMediaEncryption(encryption);
	emit mediaEncryptionChanged();
}

bool SettingsModel::getMediaEncryptionMandatory() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->isMediaEncryptionMandatory();
}

void SettingsModel::setMediaEncryptionMandatory(bool mandatory) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->setMediaEncryptionMandatory(mandatory);
	emit mediaEncryptionMandatoryChanged();
}

bool SettingsModel::getCreateEndToEndEncryptedMeetingsAndGroupCalls() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return !!mConfig->getBool(SettingsModel::AppSection, "create_e2e_encrypted_conferences", false);
}

void SettingsModel::setCreateEndToEndEncryptedMeetingsAndGroupCalls(bool endtoend) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setBool(SettingsModel::AppSection, "create_e2e_encrypted_conferences", endtoend);
	emit createEndToEndEncryptedMeetingsAndGroupCallsChanged(endtoend);
}

// -----------------------------------------------------------------------------

QVariantMap SettingsModel::getPlaybackDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto audioDevice = CoreModel::getInstance()->getCore()->getOutputAudioDevice();
	if (!audioDevice) audioDevice = CoreModel::getInstance()->getCore()->getDefaultOutputAudioDevice();
	return ToolModel::createVariant(audioDevice);
}

void SettingsModel::setPlaybackDevice(const QVariantMap &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto audioDevice =
	    ToolModel::findAudioDevice(device["id"].toString(), linphone::AudioDevice::Capabilities::CapabilityPlay);
	if (audioDevice) {
		CoreModel::getInstance()->getCore()->setDefaultOutputAudioDevice(audioDevice);
		CoreModel::getInstance()->getCore()->setOutputAudioDevice(audioDevice);
		emit playbackDeviceChanged(device);
		resetCaptureGraph();
	} else qWarning() << "Cannot set Playback device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------

QVariantMap SettingsModel::getRingerDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto id = Utils::coreStringToAppString(CoreModel::getInstance()->getCore()->getRingerDevice());
	auto audioDevice = ToolModel::findAudioDevice(id, linphone::AudioDevice::Capabilities::CapabilityPlay);
	return ToolModel::createVariant(audioDevice);
}

void SettingsModel::setRingerDevice(QVariantMap device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->setRingerDevice(Utils::appStringToCoreString(device["id"].toString()));
	emit ringerDeviceChanged(device);
}

void SettingsModel::setRingtone(QString ringtonePath) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	QFileInfo ringtone(ringtonePath);
	if (ringtonePath.isEmpty() || !ringtone.exists()) {
	} else {
		CoreModel::getInstance()->getCore()->setRing(Utils::appStringToCoreString(ringtonePath));
		emit ringtoneChanged(ringtonePath);
	}
}

QString SettingsModel::getRingtone() const {
	return Utils::coreStringToAppString(CoreModel::getInstance()->getCore()->getRing());
}

// -----------------------------------------------------------------------------

QString SettingsModel::getVideoDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(CoreModel::getInstance()->getCore()->getVideoDevice());
}

void SettingsModel::setVideoDevice(QString device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->setVideoDevice(Utils::appStringToCoreString(device));
	emit videoDeviceChanged(device);
}

bool SettingsModel::getVideoEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->videoEnabled();
}

void SettingsModel::setVideoEnabled(const bool enabled) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	core->enableVideoCapture(enabled);
	core->enableVideoDisplay(enabled);
	emit videoEnabledChanged(enabled);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAutoDownloadReceivedFiles() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->getMaxSizeForAutoDownloadIncomingFiles() != -1;
}

void SettingsModel::setAutoDownloadReceivedFiles(bool status) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->setMaxSizeForAutoDownloadIncomingFiles(status ? 0 : -1);
	emit autoDownloadReceivedFilesChanged(status);
}

bool SettingsModel::getEchoCancellationEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->echoCancellationEnabled();
}

void SettingsModel::setEchoCancellationEnabled(bool status) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->enableEchoCancellation(status);
	emit echoCancellationEnabledChanged(status);
}

void SettingsModel::startEchoCancellerCalibration() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->startEchoCancellerCalibration();
}

int SettingsModel::getEchoCancellationCalibration() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->getEchoCancellationCalibration();
}

bool SettingsModel::getAutomaticallyRecordCallsEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return !!mConfig->getInt(UiSection, "automatically_record_calls", 0);
}

void SettingsModel::setAutomaticallyRecordCallsEnabled(bool enabled) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setInt(UiSection, "automatically_record_calls", enabled);
	emit automaticallyRecordCallsEnabledChanged(enabled);
}

bool SettingsModel::getCallToneIndicationsEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->callToneIndicationsEnabled();
}

void SettingsModel::setCallToneIndicationsEnabled(bool enabled) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (enabled != getCallToneIndicationsEnabled()) {
		CoreModel::getInstance()->getCore()->enableCallToneIndications(enabled);
		emit callToneIndicationsEnabledChanged(enabled);
	}
}

// =============================================================================
// VFS.
// =============================================================================

bool SettingsModel::getVfsEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return !!mConfig->getInt(UiSection, "vfs_enabled", 0);
}

void SettingsModel::setVfsEnabled(bool enabled) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setInt(UiSection, "vfs_enabled", enabled);
	emit vfsEnabledChanged(enabled);
}

bool SettingsModel::getVfsEncrypted() const {
	return false;
	// mAppSettings.beginGroup("keychain");
	// return mAppSettings.value("enabled", false).toBool();
}

// void SettingsModel::setVfsEncrypted(bool encrypted, const bool deleteUserData) {
// #ifdef ENABLE_QT_KEYCHAIN
// 	if (getVfsEncrypted() != encrypted) {
// 		if (encrypted) {
// 			mVfsUtils.newEncryptionKeyAsync();
// 			shared_ptr<linphone::Factory> factory = linphone::Factory::get();
// 			factory->setDownloadDir(Utils::appStringToCoreString(getDownloadFolder()));
// 		} else { // Remove key, stop core, delete data and initiate reboot
// 			mVfsUtils.needToDeleteUserData(deleteUserData);
// 			mVfsUtils.deleteKey(mVfsUtils.getApplicationVfsEncryptionKey());
// 		}
// 	}
// #endif
// }
// =============================================================================
// Logs.
// =============================================================================

bool SettingsModel::getLogsEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return getLogsEnabled(mConfig);
}

void SettingsModel::setLogsEnabled(bool status) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setInt(UiSection, "logs_enabled", status);
	CoreModel::getInstance()->getLogger()->enable(status);
	emit logsEnabledChanged(status);
}

bool SettingsModel::getFullLogsEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return getFullLogsEnabled(mConfig);
}

void SettingsModel::setFullLogsEnabled(bool status) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setInt(UiSection, "full_logs_enabled", status);
	CoreModel::getInstance()->getLogger()->enableFullLogs(status);
	emit fullLogsEnabledChanged(status);
}

bool SettingsModel::getLogsEnabled(const shared_ptr<linphone::Config> &config) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	return config ? config->getInt(UiSection, "logs_enabled", false) : true;
}

bool SettingsModel::getFullLogsEnabled(const shared_ptr<linphone::Config> &config) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	return config ? config->getInt(UiSection, "full_logs_enabled", false) : false;
}

QString SettingsModel::getLogsFolder() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return getLogsFolder(mConfig);
}

QString SettingsModel::getLogsFolder(const shared_ptr<linphone::Config> &config) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	return config ? Utils::coreStringToAppString(config->getString(
	                    UiSection, "logs_folder", Utils::appStringToCoreString(Paths::getLogsDirPath())))
	              : Paths::getLogsDirPath();
}

static inline std::string getLegacySavedCallsFolder(const shared_ptr<linphone::Config> &config) {
	auto path = config->getString(SettingsModel::UiSection, "saved_videos_folder", "");
	if (path == "") path = Utils::appStringToCoreString(Paths::getCapturesDirPath());
	return path;
}

QString SettingsModel::getSavedCallsFolder() const {
	auto path = mConfig->getString(UiSection, "saved_calls_folder", ""); // Avoid to call default function if exist.
	if (path == "") path = getLegacySavedCallsFolder(mConfig);
	return QDir::cleanPath(Utils::coreStringToAppString(path)) + QDir::separator();
}

QString SettingsModel::getLogsUploadUrl() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	return Utils::coreStringToAppString(core->getLogCollectionUploadServerUrl());
}

void SettingsModel::setLogsUploadUrl(const QString &serverUrl) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (serverUrl != getLogsUploadUrl()) {
		auto core = CoreModel::getInstance()->getCore();
		core->setLogCollectionUploadServerUrl(Utils::appStringToCoreString(serverUrl));
		emit logsUploadUrlChanged();
	}
}

void SettingsModel::cleanLogs() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->resetLogCollection();
}

void SettingsModel::sendLogs() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	qInfo() << QStringLiteral("Send logs to: `%1` from `%2`.")
	               .arg(Utils::coreStringToAppString(core->getLogCollectionUploadServerUrl()))
	               .arg(Utils::coreStringToAppString(core->getLogCollectionPath()));
	core->uploadLogCollection();
}

QString SettingsModel::getLogsEmail() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "logs_email", Constants::DefaultLogsEmail));
}

// =============================================================================
// Do not disturb
// =============================================================================

bool SettingsModel::dndEnabled(const shared_ptr<linphone::Config> &config) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	return config ? config->getInt(UiSection, "do_not_disturb", false) : false;
}

bool SettingsModel::dndEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return dndEnabled(mConfig);
}

void SettingsModel::enableRinging(bool enable) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setInt("sound", "disable_ringing", !enable); // Ringing
}

void SettingsModel::enableDnd(bool enableDnd) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	setCallToneIndicationsEnabled(!enableDnd);
	enableRinging(!enableDnd);
	mConfig->setInt(UiSection, "do_not_disturb", enableDnd);
	emit dndChanged(enableDnd);
}

bool SettingsModel::getIpv6Enabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->ipv6Enabled();
}

void SettingsModel::setIpv6Enabled(const bool &status) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (getIpv6Enabled() != status) {
		CoreModel::getInstance()->getCore()->enableIpv6(status);
		emit ipv6EnabledChanged(status);
	}
}

// =============================================================================
// Carddav storage list
// =============================================================================

const std::shared_ptr<linphone::FriendList> SettingsModel::getCardDAVListForNewFriends() {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	if (core) {
		auto config = core->getConfig();
		auto listName = config->getString(UiSection, "friend_list_to_store_newly_created_contacts", "");
		if (!listName.empty()) return core->getFriendListByName(listName);
		else return nullptr;
	} else return nullptr;
}

void SettingsModel::setCardDAVListForNewFriends(std::string name) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	if (core) {
		auto config = core->getConfig();
		config->setString(UiSection, "friend_list_to_store_newly_created_contacts", name);
	}
}

// CardDAV min characters for research

int SettingsModel::getCardDAVMinCharResearch() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mConfig->getInt(SettingsModel::CardDAVSection, "min_characters", 0);
}

void SettingsModel::setCardDAVMinCharResearch(int min) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setInt(SettingsModel::CardDAVSection, "min_characters", min);
	emit cardDAVMinCharResearchChanged(min);
}

// =============================================================================
// Device name.
// =============================================================================

QString SettingsModel::getDeviceName(const std::shared_ptr<linphone::Config> &config) {
	return Utils::coreStringToAppString(
	    config->getString(UiSection, "device_name", Utils::appStringToCoreString(QSysInfo::machineHostName())));
}

// ==============================================================================
// Clears the local "ldap_friends" friend list upon startup (Ldap contacts cache)
// ==============================================================================

bool SettingsModel::clearLocalLdapFriendsUponStartup(const shared_ptr<linphone::Config> &config) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	return config ? config->getBool(UiSection, "clear_local_ldap_friends_upon_startup", false) : false;
}

// =============================================================================
// Ui.
// =============================================================================
/*
bool SettingsModel::getShowChats() const {
    return mConfig->getBool(UiSection, "disable_chat_feature", false);
}*/

QVariantList SettingsModel::getShortcuts() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	QVariantList shortcuts;
	auto sections = mConfig->getSectionsNamesList();
	for (auto section : sections) {
		auto sectionTokens = Utils::coreStringToAppString(section).split('_');
		if (sectionTokens.size() > 1 && sectionTokens[0].compare("shortcut", Qt::CaseInsensitive) == 0) {
			QVariantMap shortcut;
			shortcut["id"] = sectionTokens[1].toInt();
			shortcut["name"] = Utils::coreStringToAppString(mConfig->getString(section, "name", ""));
			shortcut["link"] = Utils::coreStringToAppString(mConfig->getString(section, "link", ""));
			shortcut["icon"] = Utils::coreStringToAppString(mConfig->getString(section, "icon", ""));
			shortcuts << shortcut;
		}
	}
	return shortcuts;
}

void SettingsModel::setShortcuts(const QVariantList &data) {
	if (getShortcuts() != data) {
		// clean
		auto sections = mConfig->getSectionsNamesList();
		for (auto section : sections) {
			auto sectionTokens = Utils::coreStringToAppString(section).split('_');
			if (sectionTokens.size() > 1 && sectionTokens[0].compare("shortcut", Qt::CaseInsensitive) == 0) {
				mConfig->cleanSection(section);
			}
		}
		int count = 0;
		for (auto shortcut : data) {
			auto mShortcut = shortcut.toMap();
			auto key = Utils::appStringToCoreString("shortcut_" + QString::number(count++));
			mConfig->setString(key, "name", Utils::appStringToCoreString(mShortcut["name"].toString()));
			mConfig->setString(key, "link", Utils::appStringToCoreString(mShortcut["link"].toString()));
			mConfig->setString(key, "icon", Utils::appStringToCoreString(mShortcut["icon"].toString()));
		}

		emit shortcutsChanged(data);
	}
}

QString SettingsModel::getDefaultDomain() const {
	return Utils::coreStringToAppString(
	    mConfig->getString(SettingsModel::AppSection, "default_domain", "sip.linphone.org"));
}

void SettingsModel::enableCallForward(QString destination) {
	// TODO implement business logic to activate call forward to destination on PBX via external API (contains voicemail
	// or a destination).
	mConfig->setString(UiSection, "call_forward_to_address", Utils::appStringToCoreString(destination));
	emit callForwardToAddressChanged(getCallForwardToAddress());
}

void SettingsModel::disableCallForward() {
	// TODO implement business logic to de-activate call forward on PBX via external API
	mConfig->setString(UiSection, "call_forward_to_address", "");
}

QString SettingsModel::getCallForwardToAddress() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "call_forward_to_address", ""));
}

void SettingsModel::setCallForwardToAddress(const QString &data) {
	if (data == "") disableCallForward();
	else enableCallForward(data);
	emit(callForwardToAddressChanged(data));
}

bool SettingsModel::isSystrayNotificationBlinkEnabled() const {
	return !!mConfig->getInt(UiSection, "systray_notification_blink", 1);
}

bool SettingsModel::isSystrayNotificationGlobal() const {
	return !!mConfig->getInt(UiSection, "systray_notification_global", 1);
}

bool SettingsModel::isSystrayNotificationFiltered() const {
	return !!mConfig->getInt(UiSection, "systray_notification_filtered", 0);
}

bool SettingsModel::getStandardChatEnabled() const {
	return !getDisableChatFeature() &&
	       !!mConfig->getInt(UiSection, getEntryFullName(UiSection, "standard_chat_enabled"), 1);
}

bool SettingsModel::getSecureChatEnabled() const {
	auto core = CoreModel::getInstance()->getCore();
	return !getDisableChatFeature() &&
	       !!mConfig->getInt(UiSection, getEntryFullName(UiSection, "secure_chat_enabled"), 1) &&
	       getLimeIsSupported() && core->getDefaultAccount() &&
	       !core->getDefaultAccount()->getParams()->getLimeServerUrl().empty() && getGroupChatEnabled();
}

bool SettingsModel::getGroupChatEnabled() const {
	return CoreModel::getInstance()->getCore()->getDefaultAccount() &&
	       !CoreModel::getInstance()->getCore()->getDefaultAccount()->getParams()->getConferenceFactoryUri().empty();
}

QString SettingsModel::getChatNotificationSoundPath() const {
	static const string defaultFile = linphone::Factory::get()->getSoundResourcesDir() + "/incoming_chat.wav";
	return Utils::coreStringToAppString(mConfig->getString(UiSection, "chat_sound_notification_file", defaultFile));
}

bool SettingsModel::getLimeIsSupported() const {
	return CoreModel::getInstance()->getCore()->limeX3DhAvailable();
}

void SettingsModel::setDisableMeetingsFeature(bool value) {
	mConfig->setBool(UiSection, "disable_meetings_feature", value);
	emit disableMeetingsFeatureChanged(value);
}

bool SettingsModel::getDisableMeetingsFeature() const {
	return !!mConfig->getInt(UiSection, "disable_meetings_feature", 0);
}

bool SettingsModel::isCheckForUpdateAvailable() const {
#ifdef ENABLE_UPDATE_CHECK
	return true;
#else
	return false;
#endif
}

bool SettingsModel::isCheckForUpdateEnabled() const {
	return !!mConfig->getInt(UiSection, "check_for_update_enabled", isCheckForUpdateAvailable());
}

void SettingsModel::setCheckForUpdateEnabled(bool enable) {
	mConfig->setInt(UiSection, "check_for_update_enabled", enable);
	emit checkForUpdateEnabledChanged();
}

QString SettingsModel::getVersionCheckUrl() {
	auto url = mConfig->getString("misc", "version_check_url_root", "");
	if (url == "") {
		url = Constants::VersionCheckReleaseUrl;
		if (url != "") mConfig->setString("misc", "version_check_url_root", url);
	}
	return Utils::coreStringToAppString(url);
}

void SettingsModel::setVersionCheckUrl(const QString &url) {
	if (url != getVersionCheckUrl()) {
		// Do not trim the url before because we want to update GUI from potential auto fix.
		mConfig->setString("misc", "version_check_url_root", Utils::appStringToCoreString(url.trimmed()));
		emit versionCheckUrlChanged();
	}
}

void SettingsModel::setChatNotificationSoundPath(const QString &path) {
	QString cleanedPath = QDir::cleanPath(path);
	mConfig->setString(UiSection, "chat_sound_notification_file", Utils::appStringToCoreString(cleanedPath));
	emit chatNotificationSoundPathChanged(cleanedPath);
}

QFont SettingsModel::getEmojiFont() const {
	QString family = Utils::coreStringToAppString(mConfig->getString(
	    UiSection, "emoji_font", Utils::appStringToCoreString(QFont(Constants::DefaultEmojiFont).family())));
	int pointSize = getEmojiFontSize();
	return QFont(family, pointSize);
}

int SettingsModel::getEmojiFontSize() const {
	return mConfig->getInt(UiSection, "emoji_font_size", Constants::DefaultEmojiFontPointSize);
}

QFont SettingsModel::getTextMessageFont() const {
	QString family = Utils::coreStringToAppString(mConfig->getString(
	    UiSection, "text_message_font", Utils::appStringToCoreString(App::getInstance()->font().family())));
	int pointSize = getTextMessageFontSize();
	return QFont(family, pointSize);
}

int SettingsModel::getTextMessageFontSize() const {
	return mConfig->getInt(UiSection, "text_message_font_size", Constants::DefaultFontPointSize);
}

// clang-format off
void SettingsModel::notifyConfigReady(){
	DEFINE_NOTIFY_CONFIG_READY(disableChatFeature, DisableChatFeature)
	DEFINE_NOTIFY_CONFIG_READY(disableMeetingsFeature, DisableMeetingsFeature)
	DEFINE_NOTIFY_CONFIG_READY(hideSettings,HideSettings)
	DEFINE_NOTIFY_CONFIG_READY(hideAccountSettings, HideAccountSettings)
	DEFINE_NOTIFY_CONFIG_READY(hideFps, HideFps)
	DEFINE_NOTIFY_CONFIG_READY(disableCallRecordings, DisableCallRecordings)
	DEFINE_NOTIFY_CONFIG_READY(assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_NOTIFY_CONFIG_READY(assistantDisableQrCode, AssistantDisableQrCode)
	DEFINE_NOTIFY_CONFIG_READY(assistantHideThirdPartyAccount, AssistantHideThirdPartyAccount)
	DEFINE_NOTIFY_CONFIG_READY(hideSipAddresses, HideSipAddresses)
	DEFINE_NOTIFY_CONFIG_READY(darkModeAllowed, DarkModeAllowed)
    DEFINE_NOTIFY_CONFIG_READY(assistantGoDirectlyToThirdPartySipAccountLogin,
                               AssistantGoDirectlyToThirdPartySipAccountLogin)
	DEFINE_NOTIFY_CONFIG_READY(assistantThirdPartySipAccountDomain, AssistantThirdPartySipAccountDomain)
	DEFINE_NOTIFY_CONFIG_READY(assistantThirdPartySipAccountTransport, AssistantThirdPartySipAccountTransport)
	DEFINE_NOTIFY_CONFIG_READY(autoStart, AutoStart)
	DEFINE_NOTIFY_CONFIG_READY(exitOnClose, ExitOnClose)
	DEFINE_NOTIFY_CONFIG_READY(syncLdapContacts, SyncLdapContacts)
	DEFINE_NOTIFY_CONFIG_READY(configLocale, ConfigLocale)
	DEFINE_NOTIFY_CONFIG_READY(downloadFolder, DownloadFolder)
	DEFINE_NOTIFY_CONFIG_READY(shortcutCount, ShortcutCount)
	DEFINE_NOTIFY_CONFIG_READY(shortcuts, Shortcuts)
	DEFINE_NOTIFY_CONFIG_READY(usernameOnlyForLdapLookupsInCalls, UsernameOnlyForLdapLookupsInCalls)
	DEFINE_NOTIFY_CONFIG_READY(usernameOnlyForCardDAVLookupsInCalls, UsernameOnlyForCardDAVLookupsInCalls)
	DEFINE_NOTIFY_CONFIG_READY(commandLine, CommandLine)
	DEFINE_NOTIFY_CONFIG_READY(disableCommandLine, DisableCommandLine)
	DEFINE_NOTIFY_CONFIG_READY(themeMainColor, ThemeMainColor)
	DEFINE_NOTIFY_CONFIG_READY(themeAboutPictureUrl, ThemeAboutPictureUrl)

}

DEFINE_GETSET_CONFIG(SettingsModel, bool, Bool, disableChatFeature, DisableChatFeature, "disable_chat_feature", false)
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						disableBroadcastFeature,
						DisableBroadcastFeature,
						"disable_broadcast_feature",
						true)
DEFINE_GETSET_CONFIG(SettingsModel, bool, Bool, hideSettings, HideSettings, "hide_settings", false)
DEFINE_GETSET_CONFIG(
	SettingsModel, bool, Bool, hideAccountSettings, HideAccountSettings, "hide_account_settings", false)
DEFINE_GETSET_CONFIG(SettingsModel, bool, Bool, hideFps, HideFps, "hide_fps", true )
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						disableCallRecordings,
						DisableCallRecordings,
						"disable_call_recordings_feature",
						false) 
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						assistantHideCreateAccount,
						AssistantHideCreateAccount,
						"assistant_hide_create_account",
						false)
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						assistantDisableQrCode,
						AssistantDisableQrCode,
						"assistant_disable_qr_code",
						true) 
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						assistantHideThirdPartyAccount,
						AssistantHideThirdPartyAccount,
						"assistant_hide_third_party_account",
						false)
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						hideSipAddresses,
						HideSipAddresses,
						"hide_sip_addresses",
						false) 
DEFINE_GETSET_CONFIG(SettingsModel,
							bool,
							Bool,
							darkModeAllowed,
							DarkModeAllowed,
							"dark_mode_allowed",
							false)
DEFINE_GETSET_CONFIG(SettingsModel, int, Int, maxAccount, MaxAccount, "max_account", 0)
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						assistantGoDirectlyToThirdPartySipAccountLogin,
						AssistantGoDirectlyToThirdPartySipAccountLogin,
						"assistant_go_directly_to_third_party_sip_account_login",
						false)
DEFINE_GETSET_CONFIG_STRING(SettingsModel,
							assistantThirdPartySipAccountDomain,
							AssistantThirdPartySipAccountDomain,
							"assistant_third_party_sip_account_domain",
							"")
DEFINE_GETSET_CONFIG_STRING(SettingsModel,
							assistantThirdPartySipAccountTransport,
							AssistantThirdPartySipAccountTransport,
							"assistant_third_party_sip_account_transport",
							"TLS") 
DEFINE_GETSET_CONFIG(SettingsModel,
							bool,
							Bool,
							autoStart,
							AutoStart,
							"auto_start",
							false)
DEFINE_GETSET_CONFIG(SettingsModel,
							bool,
							Bool,
							exitOnClose,
							ExitOnClose,
							"exit_on_close",
							false)
DEFINE_GETSET_CONFIG(SettingsModel,
						bool,
						Bool,
						syncLdapContacts,
						SyncLdapContacts,
						"sync_ldap_contacts",
						false)
DEFINE_GETSET_CONFIG_STRING(SettingsModel,
							configLocale,
							ConfigLocale,
							"locale",
							"")
DEFINE_GETSET_CONFIG_STRING(SettingsModel,
							downloadFolder,
							DownloadFolder,
							"download_folder",
							"")
DEFINE_GETSET_CONFIG(SettingsModel,
						int,
						Int,
						shortcutCount,
						ShortcutCount,
						"shortcut_count",
						0)
DEFINE_GETSET_CONFIG(SettingsModel,
							bool,
							Bool,
							usernameOnlyForLdapLookupsInCalls,
							UsernameOnlyForLdapLookupsInCalls,
							"username_only_for_ldap_lookups_in_calls",
							false)
DEFINE_GETSET_CONFIG(SettingsModel,
							bool,
							Bool,
							usernameOnlyForCardDAVLookupsInCalls,
							UsernameOnlyForCardDAVLookupsInCalls,
							"username_only_for_carddav_lookups_in_calls",
							false)
DEFINE_GETSET_CONFIG_STRING(SettingsModel,
							commandLine,
							CommandLine,
							"command_line",
							"")
DEFINE_GETSET_CONFIG(SettingsModel,
							bool,
							Bool,
							disableCommandLine,
					 		DisableCommandLine,
							"disable_command_line",
							false)
DEFINE_GETSET_CONFIG(SettingsModel,
							bool,
							Bool,
					 		disableCallForward,
					 		DisableCallForward,
							"disable_call_forward",
							true)
DEFINE_GETSET_CONFIG_STRING(SettingsModel,
							themeMainColor,
							ThemeMainColor,
							"theme_main_color",
							"orange")
DEFINE_GETSET_CONFIG_STRING(SettingsModel,
							themeAboutPictureUrl,
							ThemeAboutPictureUrl,
							"theme_about_picture_url",
							"")
    // clang-format on
