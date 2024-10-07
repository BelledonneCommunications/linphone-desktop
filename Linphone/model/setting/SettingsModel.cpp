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
#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

// =============================================================================

DEFINE_ABSTRACT_OBJECT(SettingsModel)

using namespace std;

const std::string SettingsModel::UiSection("ui");
std::shared_ptr<SettingsModel> SettingsModel::gCoreModel;

SettingsModel::SettingsModel() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	connect(CoreModel::getInstance()->thread(), &QThread::finished, this, [this]() {
		// Model thread
		gCoreModel = nullptr;
	});
	auto core = CoreModel::getInstance()->getCore();
	mConfig = core->getConfig();
	CoreModel::getInstance()->getLogger()->applyConfig(mConfig);
	if (mConfig->hasEntry(UiSection, "do_not_disturb") == 1) {
		enableDnd(dndEnabled());
	}
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
			                 notifyConfigReady();
		                 }
	                 });
}

SettingsModel::~SettingsModel() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
}

shared_ptr<SettingsModel> SettingsModel::create() {
	auto model = make_shared<SettingsModel>();
	gCoreModel = model;
	return model;
}

shared_ptr<SettingsModel> SettingsModel::getInstance() {
	return gCoreModel;
}

bool SettingsModel::isReadOnly(const std::string &section, const std::string &name) const {
	return mConfig->hasEntry(section, name + "/readonly");
}

std::string SettingsModel::getEntryFullName(const std::string &section, const std::string &name) const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return isReadOnly(section, name) ? name + "/readonly" : name;
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

QString SettingsModel::getVideoDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(CoreModel::getInstance()->getCore()->getVideoDevice());
}

void SettingsModel::setVideoDevice(const QString &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->setVideoDevice(Utils::appStringToCoreString(device));
	emit videoDeviceChanged(device);
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
	deleteCaptureGraph();
	createCaptureGraph();
}
void SettingsModel::createCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mSimpleCaptureGraph = new MediastreamerUtils::SimpleCaptureGraph(Utils::appStringToCoreString(getCaptureDevice()),
	                                                                 Utils::appStringToCoreString(getPlaybackDevice()));
	mSimpleCaptureGraph->start();
	emit captureGraphRunningChanged(getCaptureGraphRunning());
}
void SettingsModel::startCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (!getIsInCall()) {
		if (!mSimpleCaptureGraph) {
			qDebug() << "Starting capture graph [" << mCaptureGraphListenerCount << "]";
			createCaptureGraph();
		}
		++mCaptureGraphListenerCount;
	}
}
void SettingsModel::stopCaptureGraph() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mCaptureGraphListenerCount > 0) {
		if (--mCaptureGraphListenerCount == 0) {
			qDebug() << "Stopping capture graph [" << mCaptureGraphListenerCount << "]";
			deleteCaptureGraph();
		}
	}
}
void SettingsModel::stopCaptureGraphs() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mCaptureGraphListenerCount > 0) {
		mCaptureGraphListenerCount = 0;
		deleteCaptureGraph();
	}
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
// Force a call on the 'detect' method of all audio filters, updating new or removed devices
void SettingsModel::accessCallSettings() {
	// Audio
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->reloadSoundDevices();
	emit captureDevicesChanged(getCaptureDevices());
	emit playbackDevicesChanged(getPlaybackDevices());
	emit playbackDeviceChanged(getPlaybackDevice());
	emit ringerDevicesChanged(getRingerDevices());
	emit ringerDeviceChanged(getRingerDevice());
	emit captureDeviceChanged(getCaptureDevice());
	emit playbackGainChanged(getPlaybackGain());
	emit captureGainChanged(getCaptureGain());

	// Media cards must not be used twice (capture card + call) else we will get latencies issues and bad echo
	// calibrations in call.
	if (!getIsInCall()) {
		qDebug() << "Starting capture graph from accessing audio panel";
		startCaptureGraph();
	}
	// Video
	CoreModel::getInstance()->getCore()->reloadVideoDevices();
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
	}
	emit micVolumeChanged(v);
	return v;
}

float SettingsModel::getPlaybackGain() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	float dbGain = CoreModel::getInstance()->getCore()->getPlaybackGainDb();
	return MediastreamerUtils::dbToLinear(dbGain);
}

void SettingsModel::setPlaybackGain(float gain) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	float oldGain = getPlaybackGain();
	CoreModel::getInstance()->getCore()->setPlaybackGainDb(MediastreamerUtils::linearToDb(gain));
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setPlaybackGain(gain);
	}
	if ((int)(oldGain * 1000) != (int)(gain * 1000)) emit playbackGainChanged(gain);
}

float SettingsModel::getCaptureGain() const {
	mustBeInLinphoneThread(getClassName());
	float dbGain = CoreModel::getInstance()->getCore()->getMicGainDb();
	return MediastreamerUtils::dbToLinear(dbGain);
}

void SettingsModel::setCaptureGain(float gain) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	float oldGain = getCaptureGain();
	CoreModel::getInstance()->getCore()->setMicGainDb(MediastreamerUtils::linearToDb(gain));
	if (mSimpleCaptureGraph && mSimpleCaptureGraph->isRunning()) {
		mSimpleCaptureGraph->setCaptureGain(gain);
	}
	if ((int)(oldGain * 1000) != (int)(gain * 1000)) emit captureGainChanged(gain);
}

QStringList SettingsModel::getCaptureDevices() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QStringList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityRecord))
			list << Utils::coreStringToAppString(device->getId());
	}
	return list;
}

QStringList SettingsModel::getPlaybackDevices() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QStringList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityPlay))
			list << Utils::coreStringToAppString(device->getId());
	}

	return list;
}

QStringList SettingsModel::getRingerDevices() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();
	QStringList list;

	for (const auto &device : core->getExtendedAudioDevices()) {
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityPlay))
			list << Utils::coreStringToAppString(device->getId());
	}

	return list;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getCaptureDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto audioDevice = CoreModel::getInstance()->getCore()->getInputAudioDevice();
	if (!audioDevice) audioDevice = CoreModel::getInstance()->getCore()->getDefaultInputAudioDevice();
	return Utils::coreStringToAppString(audioDevice ? audioDevice->getId() : "");
}

void SettingsModel::setCaptureDevice(const QString &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	std::string devId = Utils::appStringToCoreString(device);
	auto list = CoreModel::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice =
	    find_if(list.cbegin(), list.cend(),
	            [&](const std::shared_ptr<linphone::AudioDevice> &audioItem) { return audioItem->getId() == devId; });
	if (audioDevice != list.cend()) {
		CoreModel::getInstance()->getCore()->setDefaultInputAudioDevice(*audioDevice);
		CoreModel::getInstance()->getCore()->setInputAudioDevice(*audioDevice);
		emit captureDeviceChanged(device);
		resetCaptureGraph();
	} else qWarning() << "Cannot set Capture device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getPlaybackDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto audioDevice = CoreModel::getInstance()->getCore()->getOutputAudioDevice();
	if (!audioDevice) audioDevice = CoreModel::getInstance()->getCore()->getDefaultOutputAudioDevice();
	return Utils::coreStringToAppString(audioDevice ? audioDevice->getId() : "");
}

void SettingsModel::setPlaybackDevice(const QString &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	std::string devId = Utils::appStringToCoreString(device);

	auto list = CoreModel::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice =
	    find_if(list.cbegin(), list.cend(),
	            [&](const std::shared_ptr<linphone::AudioDevice> &audioItem) { return audioItem->getId() == devId; });
	if (audioDevice != list.cend()) {
		CoreModel::getInstance()->getCore()->setDefaultOutputAudioDevice(*audioDevice);
		CoreModel::getInstance()->getCore()->setOutputAudioDevice(*audioDevice);
		emit playbackDeviceChanged(device);
		resetCaptureGraph();
	} else qWarning() << "Cannot set Playback device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRingerDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(CoreModel::getInstance()->getCore()->getRingerDevice());
}

void SettingsModel::setRingerDevice(const QString &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	std::string devId = Utils::appStringToCoreString(device);

	auto list = CoreModel::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice =
	    find_if(list.cbegin(), list.cend(),
	            [&](const std::shared_ptr<linphone::AudioDevice> &audioItem) { return audioItem->getId() == devId; });
	if (audioDevice != list.cend()) {
		CoreModel::getInstance()->getCore()->setRingerDevice(devId);
		emit ringerDeviceChanged(device);
	} else qWarning() << "Cannot set Ringer device. The ID cannot be matched with an existant device : " << device;
}

// -----------------------------------------------------------------------------
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

void SettingsModel::enableTones(const shared_ptr<linphone::Config> &config, bool enable) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	config->setInt("sound", "tone_indications", enable); // General tones
	config->setInt("misc", "tone_indications", enable);  // Call tones
}

void SettingsModel::enableRinging(bool enable) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mConfig->setInt("sound", "disable_ringing", !enable); // Ringing
}

void SettingsModel::enableDnd(bool enableDnd) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	enableTones(mConfig, !enableDnd);
	enableRinging(!enableDnd);
	mConfig->setInt(UiSection, "do_not_disturb", enableDnd);
	emit dndChanged(enableDnd);
}

bool SettingsModel::getIpv6Enabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return CoreModel::getInstance()->getCore()->ipv6Enabled();
}

void SettingsModel::setIpv6Enabled(bool status) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (getIpv6Enabled() != status) {
		CoreModel::getInstance()->getCore()->enableIpv6(status);
		emit ipv6EnabledChanged(status);
	}
}

// =============================================================================
// Carddav storage list
// =============================================================================

const std::shared_ptr<linphone::FriendList> SettingsModel::getCarddavListForNewFriends() {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	if (core) {
		auto config = core->getConfig();
		auto listName = config->getString(UiSection, "friend_list_to_store_newly_created_contacts", "");
		if (!listName.empty()) return core->getFriendListByName(listName);
		else return nullptr;
	} else return nullptr;
}

void SettingsModel::setCarddavListForNewFriends(std::string name) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	if (core) {
		auto config = core->getConfig();
		config->setString(UiSection, "friend_list_to_store_newly_created_contacts", name);
	}
}

// =============================================================================
// Ui.
// =============================================================================
/*
bool SettingsModel::getShowChats() const {
    return mConfig->getBool(UiSection, "disable_chat_feature", false);
}*/

// clang-format off
void SettingsModel::notifyConfigReady(){
	DEFINE_NOTIFY_CONFIG_READY(disableChatFeature, DisableChatFeature)
	DEFINE_NOTIFY_CONFIG_READY(disableMeetingsFeature, DisableMeetingsFeature)
	DEFINE_NOTIFY_CONFIG_READY(hideSettings,HideSettings)
	DEFINE_NOTIFY_CONFIG_READY(hideAccountSettings, HideAccountSettings)
	DEFINE_NOTIFY_CONFIG_READY(disableCallRecordings, DisableCallRecordings)
	DEFINE_NOTIFY_CONFIG_READY(assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_NOTIFY_CONFIG_READY(assistantDisableQrCode, AssistantDisableQrCode)
	DEFINE_NOTIFY_CONFIG_READY(assistantHideThirdPartyAccount, AssistantHideThirdPartyAccount)
	DEFINE_NOTIFY_CONFIG_READY(onlyDisplaySipUriUsername, OnlyDisplaySipUriUsername)
	DEFINE_NOTIFY_CONFIG_READY(darkModeAllowed, DarkModeAllowed)
    DEFINE_NOTIFY_CONFIG_READY(assistantGoDirectlyToThirdPartySipAccountLogin,
                               AssistantGoDirectlyToThirdPartySipAccountLogin)
	DEFINE_NOTIFY_CONFIG_READY(assistantThirdPartySipAccountDomain, AssistantThirdPartySipAccountDomain)
	DEFINE_NOTIFY_CONFIG_READY(assistantThirdPartySipAccountTransport, AssistantThirdPartySipAccountTransport)
	DEFINE_NOTIFY_CONFIG_READY(autoStart, AutoStart)
	DEFINE_NOTIFY_CONFIG_READY(exitOnClose, ExitOnClose)
	DEFINE_NOTIFY_CONFIG_READY(syncLdapContacts, SyncLdapContacts)
}

DEFINE_GETSET_CONFIG(SettingsModel, bool, Bool, disableChatFeature, DisableChatFeature, "disable_chat_feature", true)
DEFINE_GETSET_CONFIG(
	SettingsModel, bool, Bool, disableMeetingsFeature, DisableMeetingsFeature, "disable_meetings_feature", false)
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
						onlyDisplaySipUriUsername,
						OnlyDisplaySipUriUsername,
						"only_display_sip_uri_username",
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
    // clang-format on
