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

#include "SettingsCore.hpp"
#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

#include <QUrl>
#include <QVariant>

DEFINE_ABSTRACT_OBJECT(SettingsCore)

// =============================================================================

QSharedPointer<SettingsCore> SettingsCore::create() {
	auto sharedPointer = QSharedPointer<SettingsCore>(new SettingsCore(), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

SettingsCore::SettingsCore(QObject *parent) : QObject(parent) {
	mustBeInLinphoneThread(getClassName());
	auto settingsModel = SettingsModel::getInstance();
	assert(settingsModel);

	// Security
	mVfsEnabled = settingsModel->getVfsEnabled();

	// Call
	mVideoEnabled = settingsModel->getVideoEnabled();
	mEchoCancellationEnabled = settingsModel->getEchoCancellationEnabled();
	mAutomaticallyRecordCallsEnabled = settingsModel->getAutomaticallyRecordCallsEnabled();

	// Audio
	mCaptureDevices = settingsModel->getCaptureDevices();
	mPlaybackDevices = settingsModel->getPlaybackDevices();
	mRingerDevices = settingsModel->getRingerDevices();
	mCaptureDevice = settingsModel->getCaptureDevice();
	mPlaybackDevice = settingsModel->getPlaybackDevice();

	mCaptureGain = settingsModel->getCaptureGain();
	mPlaybackGain = settingsModel->getPlaybackGain();

	// Video
	mVideoDevice = settingsModel->getVideoDevice();
	mVideoDevices = settingsModel->getVideoDevices();

	// Logs
	mLogsEnabled = settingsModel->getLogsEnabled();
	mFullLogsEnabled = settingsModel->getFullLogsEnabled();
	mLogsFolder = settingsModel->getLogsFolder();
	mLogsEmail = settingsModel->getLogsEmail();

	// DND
	mDndEnabled = settingsModel->dndEnabled();

	// Ui
	INIT_CORE_MEMBER(DisableChatFeature, settingsModel)
	INIT_CORE_MEMBER(DisableMeetingsFeature, settingsModel)
	INIT_CORE_MEMBER(DisableBroadcastFeature, settingsModel)
	INIT_CORE_MEMBER(HideSettings, settingsModel)
	INIT_CORE_MEMBER(HideAccountSettings, settingsModel)
	INIT_CORE_MEMBER(DisableCallRecordings, settingsModel)
	INIT_CORE_MEMBER(AssistantHideCreateAccount, settingsModel)
	INIT_CORE_MEMBER(AssistantHideCreateAccount, settingsModel)
	INIT_CORE_MEMBER(AssistantDisableQrCode, settingsModel)

	INIT_CORE_MEMBER(AssistantHideThirdPartyAccount, settingsModel)
	INIT_CORE_MEMBER(OnlyDisplaySipUriUsername, settingsModel)
	INIT_CORE_MEMBER(DarkModeAllowed, settingsModel)
	INIT_CORE_MEMBER(MaxAccount, settingsModel)
	INIT_CORE_MEMBER(AssistantGoDirectlyToThirdPartySipAccountLogin, settingsModel)
	INIT_CORE_MEMBER(AssistantThirdPartySipAccountDomain, settingsModel)
	INIT_CORE_MEMBER(AssistantThirdPartySipAccountTransport, settingsModel)
	INIT_CORE_MEMBER(AutoStart, settingsModel)
	INIT_CORE_MEMBER(ExitOnClose, settingsModel)
	INIT_CORE_MEMBER(SyncLdapContacts, settingsModel)
	INIT_CORE_MEMBER(Ipv6Enabled, settingsModel)
}

SettingsCore::~SettingsCore() {
}

void SettingsCore::setSelf(QSharedPointer<SettingsCore> me) {
	mustBeInLinphoneThread(getClassName());
	mSettingsModelConnection = QSharedPointer<SafeConnection<SettingsCore, SettingsModel>>(
	    new SafeConnection<SettingsCore, SettingsModel>(me, SettingsModel::getInstance()), &QObject::deleteLater);

	// VFS
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setVfsEnabled, [this](const bool enabled) {
		mSettingsModelConnection->invokeToModel(
		    [this, enabled]() { SettingsModel::getInstance()->setVfsEnabled(enabled); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::vfsEnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() {
			mVfsEnabled = enabled;
			emit vfsEnabledChanged();
		});
	});

	// Video Calls
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setVideoEnabled, [this](const bool enabled) {
		mSettingsModelConnection->invokeToModel(
		    [this, enabled]() { SettingsModel::getInstance()->setVideoEnabled(enabled); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::videoEnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() {
			mVideoEnabled = enabled;
			emit videoEnabledChanged();
		});
	});

	// Echo cancelling
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setEchoCancellationEnabled, [this](const bool enabled) {
		mSettingsModelConnection->invokeToModel(
		    [this, enabled]() { SettingsModel::getInstance()->setEchoCancellationEnabled(enabled); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::echoCancellationEnabledChanged,
	                                             [this](const bool enabled) {
		                                             mSettingsModelConnection->invokeToCore([this, enabled]() {
			                                             mEchoCancellationEnabled = enabled;
			                                             emit echoCancellationEnabledChanged();
		                                             });
	                                             });

	// Auto recording
	mSettingsModelConnection->makeConnectToCore(
	    &SettingsCore::setAutomaticallyRecordCallsEnabled, [this](const bool enabled) {
		    mSettingsModelConnection->invokeToModel(
		        [this, enabled]() { SettingsModel::getInstance()->setAutomaticallyRecordCallsEnabled(enabled); });
	    });
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::automaticallyRecordCallsEnabledChanged,
	                                             [this](const bool enabled) {
		                                             mSettingsModelConnection->invokeToCore([this, enabled]() {
			                                             mAutomaticallyRecordCallsEnabled = enabled;
			                                             emit automaticallyRecordCallsEnabledChanged();
		                                             });
	                                             });

	// Audio device(s)
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetCaptureDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { SettingsModel::getInstance()->setCaptureDevice(id); });
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mCaptureDevice = device;
			emit captureDeviceChanged(device);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetPlaybackDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { SettingsModel::getInstance()->setPlaybackDevice(id); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mPlaybackDevice = device;
			emit playbackDeviceChanged(device);
		});
	});
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetRingerDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { SettingsModel::getInstance()->setRingerDevice(id); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::ringerDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mRingerDevice = device;
			emit ringerDeviceChanged(device);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetPlaybackGain, [this](const float value) {
		mSettingsModelConnection->invokeToModel(
		    [this, value]() { SettingsModel::getInstance()->setPlaybackGain(value); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackGainChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() {
			mPlaybackGain = value;
			emit playbackGainChanged(value);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetCaptureGain, [this](const float value) {
		mSettingsModelConnection->invokeToModel(
		    [this, value]() { SettingsModel::getInstance()->setCaptureGain(value); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureGainChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() {
			mCaptureGain = value;
			emit captureGainChanged(value);
		});
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::micVolumeChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() { emit micVolumeChanged(value); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureDevicesChanged,
	                                             [this](const QStringList devices) {
		                                             mSettingsModelConnection->invokeToCore([this, devices]() {
			                                             mCaptureDevices = devices;
			                                             emit captureDevicesChanged(devices);
		                                             });
	                                             });

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackDevicesChanged,
	                                             [this](const QStringList devices) {
		                                             mSettingsModelConnection->invokeToCore([this, devices]() {
			                                             mPlaybackDevices = devices;
			                                             emit playbackDevicesChanged(devices);
		                                             });
	                                             });
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::ringerDevicesChanged,
	                                             [this](const QStringList devices) {
		                                             mSettingsModelConnection->invokeToCore([this, devices]() {
			                                             mRingerDevices = devices;
			                                             emit ringerDevicesChanged(devices);
		                                             });
	                                             });

	// Video device(s)
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetVideoDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { SettingsModel::getInstance()->setVideoDevice(id); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::videoDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mVideoDevice = device;
			emit videoDeviceChanged();
		});
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::videoDevicesChanged,
	                                             [this](const QStringList devices) {
		                                             mSettingsModelConnection->invokeToCore([this, devices]() {
			                                             mVideoDevices = devices;
			                                             emit videoDevicesChanged();
		                                             });
	                                             });

	// Logs
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setLogsEnabled, [this](const bool status) {
		mSettingsModelConnection->invokeToModel(
		    [this, status]() { SettingsModel::getInstance()->setLogsEnabled(status); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::logsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() {
			mLogsEnabled = status;
			emit logsEnabledChanged();
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setFullLogsEnabled, [this](const bool status) {
		mSettingsModelConnection->invokeToModel(
		    [this, status]() { SettingsModel::getInstance()->setFullLogsEnabled(status); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::fullLogsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() {
			mFullLogsEnabled = status;
			emit fullLogsEnabledChanged();
		});
	});

	// DND
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lEnableDnd, [this](const bool value) {
		mSettingsModelConnection->invokeToModel([this, value]() { SettingsModel::getInstance()->enableDnd(value); });
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::dndChanged, [this](const bool value) {
		mSettingsModelConnection->invokeToCore([this, value]() {
			mDndEnabled = value;
			emit dndChanged();
		});
	});

	auto settingsModel = SettingsModel::getInstance();

	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableChatFeature, DisableChatFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableMeetingsFeature, DisableMeetingsFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableBroadcastFeature, DisableBroadcastFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, hideSettings,
	                           HideSettings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           hideAccountSettings, HideAccountSettings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableCallRecordings, DisableCallRecordings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantDisableQrCode, AssistantDisableQrCode)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantHideThirdPartyAccount, AssistantHideThirdPartyAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           onlyDisplaySipUriUsername, OnlyDisplaySipUriUsername)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           darkModeAllowed, DarkModeAllowed)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, int, maxAccount,
	                           MaxAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantGoDirectlyToThirdPartySipAccountLogin,
	                           AssistantGoDirectlyToThirdPartySipAccountLogin)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           assistantThirdPartySipAccountDomain, AssistantThirdPartySipAccountDomain)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           assistantThirdPartySipAccountTransport, AssistantThirdPartySipAccountTransport)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, autoStart,
	                           AutoStart)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, exitOnClose,
	                           ExitOnClose)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           syncLdapContacts, SyncLdapContacts)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, ipv6Enabled,
	                           Ipv6Enabled)

	auto coreModelConnection = QSharedPointer<SafeConnection<SettingsCore, CoreModel>>(
	    new SafeConnection<SettingsCore, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);

	coreModelConnection->makeConnectToModel(
	    &CoreModel::logCollectionUploadStateChanged, [this](auto core, auto state, auto info) {
		    mSettingsModelConnection->invokeToCore([this, state, info]() {
			    if (state == linphone::Core::LogCollectionUploadState::Delivered ||
			        state == linphone::Core::LogCollectionUploadState::NotDelivered) {
				    emit logsUploadTerminated(state == linphone::Core::LogCollectionUploadState::Delivered,
				                              Utils::coreStringToAppString(info));
			    }
		    });
	    });
}

QString SettingsCore::getConfigPath(const QCommandLineParser &parser) {
	QString filePath = parser.isSet("config") ? parser.value("config") : "";
	QString configPath;
	if (!QUrl(filePath).isRelative()) {
		// configPath = FileDownloader::synchronousDownload(filePath,
		// Utils::coreStringToAppString(Paths::getConfigDirPath(false)), true));
	}
	if (configPath == "") configPath = Paths::getConfigFilePath(filePath, false);
	if (configPath == "" && !filePath.isEmpty()) configPath = Paths::getConfigFilePath("", false);
	return configPath;
}

QStringList SettingsCore::getCaptureDevices() const {
	return mCaptureDevices;
}

QStringList SettingsCore::getPlaybackDevices() const {
	return mPlaybackDevices;
}

QStringList SettingsCore::getRingerDevices() const {
	return mRingerDevices;
}

int SettingsCore::getVideoDeviceIndex() const {
	return mVideoDevices.indexOf(mVideoDevice);
}

QStringList SettingsCore::getVideoDevices() const {
	return mVideoDevices;
}

bool SettingsCore::getCaptureGraphRunning() {
	return mCaptureGraphRunning;
}

float SettingsCore::getCaptureGain() const {
	return mCaptureGain;
}

float SettingsCore::getPlaybackGain() const {
	return mPlaybackGain;
}

QString SettingsCore::getCaptureDevice() const {
	return mCaptureDevice;
}

QString SettingsCore::getPlaybackDevice() const {
	return mPlaybackDevice;
}

QString SettingsCore::getRingerDevice() const {
	return mRingerDevice;
}

int SettingsCore::getEchoCancellationCalibration() const {
	return mEchoCancellationCalibration;
}

bool SettingsCore::getFirstLaunch() const {
	auto val = mAppSettings.value("firstLaunch", 1).toInt();
	return val;
}

void SettingsCore::setFirstLaunch(bool first) {
	auto firstLaunch = getFirstLaunch();
	if (firstLaunch != first) {
		mAppSettings.setValue("firstLaunch", (int)first);
		mAppSettings.sync();
		emit firstLaunchChanged(first);
	}
}

void SettingsCore::setLastActiveTabIndex(int index) {
	auto lastActiveIndex = getLastActiveTabIndex();
	if (lastActiveIndex != index) {
		mAppSettings.setValue("lastActiveTabIndex", index);
		mAppSettings.sync();
		emit lastActiveTabIndexChanged();
	}
}

int SettingsCore::getLastActiveTabIndex() {
	return mAppSettings.value("lastActiveTabIndex", 1).toInt();
}

void SettingsCore::setDisplayDeviceCheckConfirmation(bool display) {
	if (getDisplayDeviceCheckConfirmation() != display) {
		mAppSettings.setValue("displayDeviceCheckConfirmation", display);
		mAppSettings.sync();
		emit showVerifyDeviceConfirmationChanged(display);
	}
}

bool SettingsCore::getDisplayDeviceCheckConfirmation() const {
	auto val = mAppSettings.value("displayDeviceCheckConfirmation", 1).toInt();
	return val;
}

void SettingsCore::startEchoCancellerCalibration() {
	mSettingsModelConnection->invokeToModel(
	    [this]() { SettingsModel::getInstance()->startEchoCancellerCalibration(); });
}

void SettingsCore::accessCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->accessCallSettings(); });
}
void SettingsCore::closeCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->closeCallSettings(); });
}

void SettingsCore::updateMicVolume() const {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->getMicVolume(); });
}

bool SettingsCore::getLogsEnabled() const {
	return mLogsEnabled;
}

bool SettingsCore::getFullLogsEnabled() const {
	return mFullLogsEnabled;
}

void SettingsCore::cleanLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->cleanLogs(); });
}

void SettingsCore::sendLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->sendLogs(); });
}

QString SettingsCore::getLogsEmail() const {
	return mLogsEmail;
}

QString SettingsCore::getLogsFolder() const {
	return mLogsFolder;
}

bool SettingsCore::dndEnabled() const {
	return mDndEnabled;
}

bool SettingsCore::getAutoStart() const {
	return mAutoStart;
}

bool SettingsCore::getExitOnClose() const {
	return mExitOnClose;
}

bool SettingsCore::getSyncLdapContacts() const {
	return mSyncLdapContacts;
}
