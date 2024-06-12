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

DEFINE_ABSTRACT_OBJECT(Settings)

// =============================================================================

QSharedPointer<Settings> Settings::create() {
	auto sharedPointer = QSharedPointer<Settings>(new Settings(), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

Settings::Settings(QObject *parent) : QObject(parent) {
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
}

Settings::~Settings() {
}

void Settings::setSelf(QSharedPointer<Settings> me) {
	mustBeInLinphoneThread(getClassName());
	mSettingsModelConnection = QSharedPointer<SafeConnection<Settings, SettingsModel>>(
	    new SafeConnection<Settings, SettingsModel>(me, mSettingsModel), &QObject::deleteLater);

	// VFS
	mSettingsModelConnection->makeConnectToCore(&Settings::setVfsEnabled, [this](const bool enabled) {
		mSettingsModelConnection->invokeToModel([this, enabled]() { mSettingsModel->setVfsEnabled(enabled); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::vfsEnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() {
			mVfsEnabled = enabled;
			emit vfsEnabledChanged();
		});
	});

	// Video Calls
	mSettingsModelConnection->makeConnectToCore(&Settings::setVideoEnabled, [this](const bool enabled) {
		mSettingsModelConnection->invokeToModel([this, enabled]() { mSettingsModel->setVideoEnabled(enabled); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::videoEnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() {
			mVideoEnabled = enabled;
			emit videoEnabledChanged();
		});
	});

	// Echo cancelling
	mSettingsModelConnection->makeConnectToCore(&Settings::setEchoCancellationEnabled, [this](const bool enabled) {
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
	mSettingsModelConnection->makeConnectToCore(&Settings::setAutomaticallyRecordCallsEnabled,
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
	mSettingsModelConnection->makeConnectToCore(&Settings::lSetCaptureDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { mSettingsModel->setCaptureDevice(id); });
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mCaptureDevice = device;
			emit captureDeviceChanged(device);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&Settings::lSetPlaybackDevice, [this](const QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() { mSettingsModel->setPlaybackDevice(id); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() {
			mPlaybackDevice = device;
			emit playbackDeviceChanged(device);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&Settings::lSetPlaybackGain, [this](const float value) {
		mSettingsModelConnection->invokeToModel([this, value]() { mSettingsModel->setPlaybackGain(value); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackGainChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() {
			mPlaybackGain = value;
			emit playbackGainChanged(value);
		});
	});

	mSettingsModelConnection->makeConnectToCore(&Settings::lSetCaptureGain, [this](const float value) {
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
	mSettingsModelConnection->makeConnectToCore(&Settings::lSetVideoDevice, [this](const QString id) {
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
	mSettingsModelConnection->makeConnectToCore(&Settings::setLogsEnabled, [this](const bool status) {
		mSettingsModelConnection->invokeToModel([this, status]() { mSettingsModel->setLogsEnabled(status); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::logsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() {
			mLogsEnabled = status;
			emit logsEnabledChanged();
		});
	});

	mSettingsModelConnection->makeConnectToCore(&Settings::setFullLogsEnabled, [this](const bool status) {
		mSettingsModelConnection->invokeToModel([this, status]() { mSettingsModel->setFullLogsEnabled(status); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::fullLogsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() {
			mFullLogsEnabled = status;
			emit fullLogsEnabledChanged();
		});
	});

	auto coreModelConnection = QSharedPointer<SafeConnection<Settings, CoreModel>>(
	    new SafeConnection<Settings, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);

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

QString Settings::getConfigPath(const QCommandLineParser &parser) {
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

QStringList Settings::getCaptureDevices() const {
	return mCaptureDevices;
}

QStringList Settings::getPlaybackDevices() const {
	return mPlaybackDevices;
}

int Settings::getVideoDeviceIndex() const {
	return mVideoDevices.indexOf(mVideoDevice);
}

QStringList Settings::getVideoDevices() const {
	return mVideoDevices;
}

bool Settings::getCaptureGraphRunning() {
	return mCaptureGraphRunning;
}

float Settings::getCaptureGain() const {
	return mCaptureGain;
}

float Settings::getPlaybackGain() const {
	return mPlaybackGain;
}

QString Settings::getRingerDevice() const {
	return mRingerDevice;
}

QString Settings::getCaptureDevice() const {
	return mCaptureDevice;
}

QString Settings::getPlaybackDevice() const {
	return mPlaybackDevice;
}

int Settings::getEchoCancellationCalibration() const {
	return mEchoCancellationCalibration;
}

bool Settings::getFirstLaunch() const {
	auto val = mAppSettings.value("firstLaunch", 1).toInt();
	return val;
}

void Settings::setFirstLaunch(bool first) {
	auto firstLaunch = getFirstLaunch();
	if (firstLaunch != first) {
		mAppSettings.setValue("firstLaunch", (int)first);
		mAppSettings.sync();
	}
}

void Settings::startEchoCancellerCalibration() {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->startEchoCancellerCalibration(); });
}

void Settings::accessCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->accessCallSettings(); });
}
void Settings::closeCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->closeCallSettings(); });
}

void Settings::updateMicVolume() const {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->getMicVolume(); });
}

bool Settings::getLogsEnabled() const {
	return mLogsEnabled;
}

bool Settings::getFullLogsEnabled() const {
	return mFullLogsEnabled;
}

void Settings::cleanLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->cleanLogs(); });
}

void Settings::sendLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { mSettingsModel->sendLogs(); });
}

QString Settings::getLogsEmail() const {
	return mLogsEmail;
}

QString Settings::getLogsFolder() const {
	return mLogsFolder;
}
