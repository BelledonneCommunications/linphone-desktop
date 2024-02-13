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
	auto core = CoreModel::getInstance()->getCore();
	for (auto &device : core->getExtendedAudioDevices()) {
		auto core = CoreModel::getInstance()->getCore();
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityRecord)) {
			mInputAudioDevices.append(Utils::coreStringToAppString(device->getId()));
			// mInputAudioDevices.append(createDeviceVariant(Utils::coreStringToAppString(device->getId()),
			//   Utils::coreStringToAppString(device->getDeviceName())));
		}
		if (device->hasCapability(linphone::AudioDevice::Capabilities::CapabilityPlay)) {
			mOutputAudioDevices.append(Utils::coreStringToAppString(device->getId()));
			// mOutputAudioDevices.append(createDeviceVariant(Utils::coreStringToAppString(device->getId()),
			//    Utils::coreStringToAppString(device->getDeviceName())));
		}
	}
	for (auto &device : core->getVideoDevicesList()) {
		mVideoDevices.append(Utils::coreStringToAppString(device));
	}
}

Settings::~Settings() {
}

void Settings::setSelf(QSharedPointer<Settings> me) {
	mustBeInLinphoneThread(getClassName());
	mSettingsModelConnection = QSharedPointer<SafeConnection<Settings, SettingsModel>>(
	    new SafeConnection<Settings, SettingsModel>(me, mSettingsModel), &QObject::deleteLater);
	mSettingsModelConnection->makeConnectToCore(&Settings::lSetVideoDevice, [this](const QString &id) {
		mSettingsModelConnection->invokeToModel(
		    [this, id]() { mSettingsModel->setVideoDevice(Utils::appStringToCoreString(id)); });
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

QStringList Settings::getInputAudioDevicesList() const {
	return mInputAudioDevices;
}

QStringList Settings::getOutputAudioDevicesList() const {
	return mOutputAudioDevices;
}

QStringList Settings::getVideoDevicesList() const {
	return mVideoDevices;
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