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
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include "model/tool/ToolModel.hpp"

// =============================================================================

DEFINE_ABSTRACT_OBJECT(SettingsModel)

using namespace std;

const std::string SettingsModel::UiSection("ui");

SettingsModel::SettingsModel(QObject *parent) : QObject(parent) {
	mustBeInLinphoneThread(getClassName());
	auto core = CoreModel::getInstance()->getCore();
	mConfig = core->getConfig();
}

SettingsModel::~SettingsModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

bool SettingsModel::isReadOnly(const std::string &section, const std::string &name) const {
	return mConfig->hasEntry(section, name + "/readonly");
}

std::string SettingsModel::getEntryFullName(const std::string &section, const std::string &name) const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return isReadOnly(section, name) ? name + "/readonly" : name;
}

QStringList SettingsModel::getVideoDevices() const {
	mustBeInLinphoneThread(getClassName());
	auto core = CoreModel::getInstance()->getCore();
	QStringList result;
	for (auto &device : core->getVideoDevicesList()) {
		result.append(Utils::coreStringToAppString(device));
	}
	return result;
}

QString SettingsModel::getVideoDevice () const {
	mustBeInLinphoneThread(getClassName());
	return Utils::coreStringToAppString(
						CoreModel::getInstance()->getCore()->getVideoDevice()
						);
}

void SettingsModel::setVideoDevice (const QString &device) {
	mustBeInLinphoneThread(getClassName());
	CoreModel::getInstance()->getCore()->setVideoDevice(
								  Utils::appStringToCoreString(device)
								  );
	emit videoDeviceChanged(device);
}

// =============================================================================
// Audio.
// =============================================================================

bool SettingsModel::getIsInCall() const {
	mustBeInLinphoneThread(getClassName());
	return CoreModel::getInstance()->getCore()->getCallsNb() != 0;
}

void SettingsModel::resetCaptureGraph() {
	mustBeInLinphoneThread(getClassName());
	deleteCaptureGraph();
	createCaptureGraph();
}
void SettingsModel::createCaptureGraph() {
	mustBeInLinphoneThread(getClassName());
	mSimpleCaptureGraph =
			new MediastreamerUtils::SimpleCaptureGraph(Utils::appStringToCoreString(getCaptureDevice()), Utils::appStringToCoreString(getPlaybackDevice()));
	mSimpleCaptureGraph->start();
	emit captureGraphRunningChanged(getCaptureGraphRunning());
}
void SettingsModel::startCaptureGraph() {
	mustBeInLinphoneThread(getClassName());
	if (!getIsInCall()) {
		if (!mSimpleCaptureGraph) {
			qDebug() << "Starting capture graph [" << mCaptureGraphListenerCount << "]";
			createCaptureGraph();
		}
		++mCaptureGraphListenerCount;
	}
}
void SettingsModel::stopCaptureGraph() {
	mustBeInLinphoneThread(getClassName());
	if (mCaptureGraphListenerCount > 0) {
		if (--mCaptureGraphListenerCount == 0) {
			qDebug() << "Stopping capture graph [" << mCaptureGraphListenerCount << "]";
			deleteCaptureGraph();
		}
	}
}
void SettingsModel::stopCaptureGraphs() {
	mustBeInLinphoneThread(getClassName());
	if (mCaptureGraphListenerCount > 0) {
		mCaptureGraphListenerCount = 0;
		deleteCaptureGraph();
	}
}
void SettingsModel::deleteCaptureGraph() {
	mustBeInLinphoneThread(getClassName());
	if (mSimpleCaptureGraph) {
		if (mSimpleCaptureGraph->isRunning()) {
			mSimpleCaptureGraph->stop();
		}
		delete mSimpleCaptureGraph;
		mSimpleCaptureGraph = nullptr;
	}
}
//Force a call on the 'detect' method of all audio filters, updating new or removed devices
void SettingsModel::accessCallSettings() {
	// Audio
	mustBeInLinphoneThread(getClassName());
	CoreModel::getInstance()->getCore()->reloadSoundDevices();
	emit captureDevicesChanged(getCaptureDevices());
	emit playbackDevicesChanged(getPlaybackDevices());
	emit playbackDeviceChanged(getPlaybackDevice());
	emit captureDeviceChanged(getCaptureDevice());
	emit ringerDeviceChanged(getRingerDevice());
	emit playbackGainChanged(getPlaybackGain());
	emit captureGainChanged(getCaptureGain());

	// Media cards must not be used twice (capture card + call) else we will get latencies issues and bad echo calibrations in call.
	if (!getIsInCall()) {
		qDebug() << "Starting capture graph from accessing audio panel";
		startCaptureGraph();
	}
	// Video
	CoreModel::getInstance()->getCore()->reloadVideoDevices();
	emit videoDevicesChanged(getVideoDevices());
}

void SettingsModel::closeCallSettings() {
	mustBeInLinphoneThread(getClassName());
	stopCaptureGraph();
	emit captureGraphRunningChanged(getCaptureGraphRunning());
}

bool SettingsModel::getCaptureGraphRunning() {
	mustBeInLinphoneThread(getClassName());
	return mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning() && !getIsInCall();
}

float SettingsModel::getMicVolume() {
	mustBeInLinphoneThread(getClassName());
	float v = 0.0;

	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		v = mSimpleCaptureGraph->getCaptureVolume();
	}
	emit micVolumeChanged(v);
	return v;
}

float SettingsModel::getPlaybackGain() const {
	mustBeInLinphoneThread(getClassName());
	float dbGain = CoreModel::getInstance()->getCore()->getPlaybackGainDb();
	return MediastreamerUtils::dbToLinear(dbGain);
}

void SettingsModel::setPlaybackGain(float gain) {
	mustBeInLinphoneThread(getClassName());
	float oldGain = getPlaybackGain();
	CoreModel::getInstance()->getCore()->setPlaybackGainDb(MediastreamerUtils::linearToDb(gain));
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setPlaybackGain(gain);
	}
	if((int)(oldGain*1000) != (int)(gain*1000))
		emit playbackGainChanged(gain);
}

float SettingsModel::getCaptureGain() const {
	mustBeInLinphoneThread(getClassName());
	float dbGain = CoreModel::getInstance()->getCore()->getMicGainDb();
	return MediastreamerUtils::dbToLinear(dbGain);
}

void SettingsModel::setCaptureGain(float gain) {
	mustBeInLinphoneThread(getClassName());
	float oldGain = getCaptureGain();
	CoreModel::getInstance()->getCore()->setMicGainDb(MediastreamerUtils::linearToDb(gain));
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setCaptureGain(gain);
	}
	if((int)(oldGain *1000) != (int)(gain *1000))
		emit captureGainChanged(gain);
}

QStringList SettingsModel::getCaptureDevices () const {
	mustBeInLinphoneThread(getClassName());
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QStringList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityRecord))
			list << Utils::coreStringToAppString(device->getId());
	}
	return list;
}

QStringList SettingsModel::getPlaybackDevices () const {
	mustBeInLinphoneThread(getClassName());
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QStringList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityPlay))
			list << Utils::coreStringToAppString(device->getId());
	}

	return list;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getCaptureDevice () const {
	mustBeInLinphoneThread(getClassName());
	auto audioDevice = CoreModel::getInstance()->getCore()->getInputAudioDevice();
	return Utils::coreStringToAppString(audioDevice? audioDevice->getId() : CoreModel::getInstance()->getCore()->getCaptureDevice());
}

void SettingsModel::setCaptureDevice (const QString &device) {
	mustBeInLinphoneThread(getClassName());
	std::string devId = Utils::appStringToCoreString(device);
	auto list = CoreModel::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice = find_if(list.cbegin(), list.cend(), [&] ( const std::shared_ptr<linphone::AudioDevice> & audioItem) {
	   return audioItem->getId() == devId;
	});
	if(audioDevice != list.cend()){
		CoreModel::getInstance()->getCore()->setCaptureDevice(devId);
		CoreModel::getInstance()->getCore()->setInputAudioDevice(*audioDevice);
		emit captureDeviceChanged(device);
		resetCaptureGraph();
	}else
		qWarning() << "Cannot set Capture device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getPlaybackDevice () const {
	mustBeInLinphoneThread(getClassName());
	auto audioDevice = CoreModel::getInstance()->getCore()->getOutputAudioDevice();
	return Utils::coreStringToAppString(audioDevice? audioDevice->getId() : CoreModel::getInstance()->getCore()->getPlaybackDevice());
}

void SettingsModel::setPlaybackDevice (const QString &device) {
	mustBeInLinphoneThread(getClassName());
	std::string devId = Utils::appStringToCoreString(device);

	auto list = CoreModel::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice = find_if(list.cbegin(), list.cend(), [&] ( const std::shared_ptr<linphone::AudioDevice> & audioItem) {
	   return audioItem->getId() == devId;
	});
	if(audioDevice != list.cend()){

		CoreModel::getInstance()->getCore()->setPlaybackDevice(devId);
		CoreModel::getInstance()->getCore()->setOutputAudioDevice(*audioDevice);
		emit playbackDeviceChanged(device);
		resetCaptureGraph();
	}else
		qWarning() << "Cannot set Playback device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRingerDevice () const {
	mustBeInLinphoneThread(getClassName());
	return Utils::coreStringToAppString(
						CoreModel::getInstance()->getCore()->getRingerDevice()
						);
}

void SettingsModel::setRingerDevice (const QString &device) {
	mustBeInLinphoneThread(getClassName());
	CoreModel::getInstance()->getCore()->setRingerDevice(
								   Utils::appStringToCoreString(device)
								   );
	emit ringerDeviceChanged(device);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getVideoEnabled() const {
	mustBeInLinphoneThread(getClassName());
	return  CoreModel::getInstance()->getCore()->videoEnabled();
}

void SettingsModel::setVideoEnabled(const bool enabled) {
	mustBeInLinphoneThread(getClassName());
	auto core = CoreModel::getInstance()->getCore();
	core->enableVideoCapture(enabled);
	core->enableVideoDisplay(enabled);
	emit videoEnabledChanged(enabled);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getEchoCancellationEnabled () const {
	mustBeInLinphoneThread(getClassName());
	return CoreModel::getInstance()->getCore()->echoCancellationEnabled();
}

void SettingsModel::setEchoCancellationEnabled (bool status) {
	mustBeInLinphoneThread(getClassName());
	CoreModel::getInstance()->getCore()->enableEchoCancellation(status);
	emit echoCancellationEnabledChanged(status);
}

void SettingsModel::startEchoCancellerCalibration(){
	mustBeInLinphoneThread(getClassName());
	CoreModel::getInstance()->getCore()->startEchoCancellerCalibration();
}

int SettingsModel::getEchoCancellationCalibration()const {
	mustBeInLinphoneThread(getClassName());
	return CoreModel::getInstance()->getCore()->getEchoCancellationCalibration();
}

bool SettingsModel::getAutomaticallyRecordCallsEnabled () const {
	mustBeInLinphoneThread(getClassName());
	return !!mConfig->getInt(UiSection, "automatically_record_calls", 0);
}

void SettingsModel::setAutomaticallyRecordCallsEnabled (bool enabled) {
	mustBeInLinphoneThread(getClassName());
	mConfig->setInt(UiSection, "automatically_record_calls", enabled);
	emit automaticallyRecordCallsEnabledChanged(enabled);
}

// =============================================================================
// VFS.
// =============================================================================

bool SettingsModel::getVfsEnabled () const {
	mustBeInLinphoneThread(getClassName());
	return !!mConfig->getInt(UiSection, "vfs_enabled", 0);
}

void SettingsModel::setVfsEnabled (bool enabled) {
	mustBeInLinphoneThread(getClassName());
	mConfig->setInt(UiSection, "vfs_enabled", enabled);
	emit vfsEnabledChanged(enabled);
}
