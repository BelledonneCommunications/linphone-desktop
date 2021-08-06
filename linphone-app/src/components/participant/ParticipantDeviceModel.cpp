/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "ParticipantDeviceModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

using namespace std;

ParticipantDeviceModel::ParticipantDeviceModel (shared_ptr<linphone::ParticipantDevice> device, QObject *parent) : QObject(parent) {
  mParticipantDevice = device;
}

// -----------------------------------------------------------------------------

QString ParticipantDeviceModel::getName() const{
	return Utils::coreStringToAppString(mParticipantDevice->getName());
}

int ParticipantDeviceModel::getSecurityLevel() const{
	int security =  (int)mParticipantDevice->getSecurityLevel();
	return security;
}

time_t ParticipantDeviceModel::getTimeOfJoining() const{
	return mParticipantDevice->getTimeOfJoining();
}

QString ParticipantDeviceModel::getAddress() const{
    return Utils::coreStringToAppString(mParticipantDevice->getAddress()->asStringUriOnly());
}

std::shared_ptr<linphone::ParticipantDevice>  ParticipantDeviceModel::getDevice(){
	return mParticipantDevice;
}

void ParticipantDeviceModel::onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device){
	if(!device || mParticipantDevice->getAddress()->weakEqual(device))
		emit securityLevelChanged();
}