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
	mSettingsModel = Utils::makeQObject_ptr<SettingsModel>();

	// Security
	mVfsEnabled = mSettingsModel->getVfsEnabled();

	// Call
	mVideoEnabled = mSettingsModel->getVideoEnabled();
	mEchoCancellationEnabled = mSettingsModel->getEchoCancellationEnabled();
	mAutomaticallyRecordCallsEnabled = mSettingsModel->getAutomaticallyRecordCallsEnabled();

	// Audio
	mCaptureDevices = mSettingsModel->getCaptureDevices();
	mPlaybackDevices = mSettingsModel->getPlaybackDevices();
	mCaptureDevice = mSettingsModel->getCaptureDevice();
	mPlaybackDevice = mSettingsModel->getPlaybackDevice();

	mCaptureGain = mSettingsModel->getCaptureGain();
	mPlaybackGain = mSettingsModel->getPlaybackGain();

	// Video
	mVideoDevice = mSettingsModel->getVideoDevice();
	mVideoDevices = mSettingsModel->getVideoDevices();

	// Logs
	mLogsEnabled = mSettingsModel->getLogsEnabled();
	mFullLogsEnabled = mSettingsModel->getFullLogsEnabled();
	mLogsFolder = mSettingsModel->getLogsFolder();
	mLogsEmail = mSettingsModel->getLogsEmail();

	// DND
	mDndEnabled = mSettingsModel->dndEnabled();

	// Ui
	INIT_CORE_MEMBER(DisableChatFeature, mSettingsModel)
	INIT_CORE_MEMBER(DisableMeetingsFeature, mSettingsModel)
	INIT_CORE_MEMBER(DisableBroadcastFeature, mSettingsModel)
	INIT_CORE_MEMBER(HideSettings, mSettingsModel)
	INIT_CORE_MEMBER(HideAccountSettings, mSettingsModel)
	INIT_CORE_MEMBER(DisableCallRecordings, mSettingsModel)
	INIT_CORE_MEMBER(AssistantHideCreateAccount, mSettingsModel)
	INIT_CORE_MEMBER(AssistantHideCreateAccount, mSettingsModel)
	INIT_CORE_MEMBER(AssistantDisableQrCode, mSettingsModel)

	INIT_CORE_MEMBER(AssistantHideThirdPartyAccount, mSettingsModel)
	INIT_CORE_MEMBER(OnlyDisplaySipUriUsername, mSettingsModel)
	INIT_CORE_MEMBER(DarkModeAllowed, mSettingsModel)
	INIT_CORE_MEMBER(MaxAccount, mSettingsModel)
	INIT_CORE_MEMBER(AssistantGoDirectlyToThirdPartySipAccountLogin, mSettingsModel)
	INIT_CORE_MEMBER(AssistantThirdPartySipAccountDomain, mSettingsModel)
	INIT_CORE_MEMBER(AssistantThirdPartySipAccountTransport, mSettingsModel)
	INIT_CORE_MEMBER(AutoStart, mSettingsModel)
}

SettingsCore::~SettingsCore() {
}

void SettingsCore::setSelf(QSharedPointer<SettingsCore> me) {
	mustBeInLinphoneThread(getClassName());
	mSettingsModelConnection = QSharedPointer<SafeConnection<SettingsCore, SettingsModel>>(
	    new SafeConnection<SettingsCore, SettingsModel>(me, mSettingsModel), &QObject::deleteLater);

	// VFS
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setVfsEnabled, [this](const bool enabled) {
		mSettingsModelConnection->invokeToModel([this, enabled]() { mSettingsModel->setVfsEnabled(enabled); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::vfsEnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() {
			mVfsEnabled = enabled;
			emit vfsEnabledChanged();
		});
	});

	// Video Calls
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setVideoEnabled, [this](const bool enabled) {
		mSettingsModelConnection->invokeToModel([this, enabled]() { mSettingsModel->setVideoEnabled(enabled); });
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
		    [this, enabled]() { mSettingsModel->setEchoCancellationEnabled(enabled); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::echoCancellationEnabledChanged,
	                                             [this](const bool enabled) {
		                                             mSettingsModelConnection->invokeToCore([this, enabled]() {
			                                             mEchoCancellationEnabled = enabled;
			                                             emit echoCancellationEnabledChanged();
		                                             });
	                                             });

	// Auto recording
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setAutomaticallyRecordCallsEnabled,
	                                            [this](const bool enabled) {
		                                            mSettingsModelConnection->invokeToModel([this, enabled]() {
			                                            mSettingsModel->setAutomaticallyRecordCallsEnabled(enabled);
		                                            });
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
		mSettingsModelConnection->invokeToModel([this, id]() { mSettingsModel->setCaptureDevice(id); });
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mCaptureDevice = device;
			emit captureDeviceChanged(device);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetPlaybackDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { mSettingsModel->setPlaybackDevice(id); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mPlaybackDevice = device;
			emit playbackDeviceChanged(device);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetPlaybackGain, [this](const float value) {
		mSettingsModelConnection->invokeToModel([this, value]() { mSettingsModel->setPlaybackGain(value); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackGainChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() {
			mPlaybackGain = value;
			emit playbackGainChanged(value);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetCaptureGain, [this](const float value) {
		mSettingsModelConnection->invokeToModel([this, value]() { mSettingsModel->setCaptureGain(value); });
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

	// Video device(s)
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetVideoDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { mSettingsModel->setVideoDevice(id); });
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
		mSettingsModelConnection->invokeToModel([this, status]() { mSettingsModel->setLogsEnabled(status); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::logsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() {
			mLogsEnabled = status;
			emit logsEnabledChanged();
		});
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::setFullLogsEnabled, [this](const bool status) {
		mSettingsModelConnection->invokeToModel([this, status]() { mSettingsModel->setFullLogsEnabled(status); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::fullLogsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() {
			mFullLogsEnabled = status;
			emit fullLogsEnabledChanged();
		});
	});

	// DND
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lEnableDnd, [this](const bool value) {
		mSettingsModelConnection->invokeToModel([this, value]() { mSettingsModel->enableDnd(value); });
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::dndChanged, [this](const bool value) {
		mSettingsModelConnection->invokeToCore([this, value]() {
			mDndEnabled = value;
			emit dndChanged();
		});
	});

	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           disableChatFeature, DisableChatFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           disableMeetingsFeature, DisableMeetingsFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           disableBroadcastFeature, DisableBroadcastFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           hideSettings, HideSettings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           hideAccountSettings, HideAccountSettings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           disableCallRecordings, DisableCallRecordings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           assistantDisableQrCode, AssistantDisableQrCode)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           assistantHideThirdPartyAccount, AssistantHideThirdPartyAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           onlyDisplaySipUriUsername, OnlyDisplaySipUriUsername)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           darkModeAllowed, DarkModeAllowed)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, int, maxAccount,
	                           MaxAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool,
	                           assistantGoDirectlyToThirdPartySipAccountLogin,
	                           AssistantGoDirectlyToThirdPartySipAccountLogin)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, QString,
	                           assistantThirdPartySipAccountDomain, AssistantThirdPartySipAccountDomain)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, QString,
	                           assistantThirdPartySipAccountTransport, AssistantThirdPartySipAccountTransport)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, mSettingsModel, bool, autoStart,
	                           AutoStart)

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
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->startEchoCancellerCalibration(); });
}

void SettingsCore::accessCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->accessCallSettings(); });
}
void SettingsCore::closeCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->closeCallSettings(); });
}

void SettingsCore::updateMicVolume() const {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->getMicVolume(); });
}

bool SettingsCore::getLogsEnabled() const {
	return mLogsEnabled;
}

bool SettingsCore::getFullLogsEnabled() const {
	return mFullLogsEnabled;
}

void SettingsCore::cleanLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->cleanLogs(); });
}

void SettingsCore::sendLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->sendLogs(); });
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
