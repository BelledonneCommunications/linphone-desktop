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

#include "ParticipantModel.hpp"

#include "tool/Utils.hpp"

#include <QTimer>

DEFINE_ABSTRACT_OBJECT(ParticipantModel)

ParticipantModel::ParticipantModel(std::shared_ptr<linphone::Participant> linphoneParticipant, QObject *parent)
    : QObject(parent) {
	if (linphoneParticipant) mustBeInLinphoneThread(getClassName());
	mParticipant = linphoneParticipant;
}

ParticipantModel::~ParticipantModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

int ParticipantModel::getSecurityLevel() const {
	return (int)mParticipant->getSecurityLevel();
}

std::list<std::shared_ptr<linphone::ParticipantDevice>> ParticipantModel::getDevices() const {
	return mParticipant->getDevices();
}

int ParticipantModel::getDeviceCount() {
	return mParticipant->getDevices().size();
}

QString ParticipantModel::getSipAddress() const {
	return Utils::coreStringToAppString(mParticipant->getAddress()->asString());
}

QDateTime ParticipantModel::getCreationTime() const {
	return QDateTime::fromSecsSinceEpoch(mParticipant->getCreationTime());
}

bool ParticipantModel::getAdminStatus() const {
	return mParticipant->isAdmin();
}

bool ParticipantModel::isFocus() const {
	return mParticipant->isFocus();
}
