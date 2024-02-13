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

// =============================================================================

DEFINE_ABSTRACT_OBJECT(SettingsModel)

const std::string SettingsModel::UiSection("ui");

SettingsModel::SettingsModel(QObject *parent) : QObject(parent) {
	mustBeInLinphoneThread(getClassName());
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

std::list<std::string> SettingsModel::getVideoDevices() const {
	auto core = CoreModel::getInstance()->getCore();
	return core->getVideoDevicesList();
}

std::string SettingsModel::getVideoDevice() {
	return CoreModel::getInstance()->getCore()->getVideoDevice();
}

void SettingsModel::setVideoDevice(const std::string &id) {
	auto core = CoreModel::getInstance()->getCore();
	if (core->getVideoDevice() != id) {
		CoreModel::getInstance()->getCore()->setVideoDevice(id);
		emit videoDeviceChanged();
	}
}