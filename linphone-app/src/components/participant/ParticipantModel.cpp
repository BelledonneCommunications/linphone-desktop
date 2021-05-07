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

#include "ParticipantModel.hpp"
#include "utils/Utils.hpp"

// =============================================================================

using namespace std;

ParticipantModel::ParticipantModel (shared_ptr<linphone::Participant> linphoneParticipant, QObject *parent) : QObject(parent) {
  mLinphoneParticipant = linphoneParticipant;
}

// -----------------------------------------------------------------------------

QString ParticipantModel::getAddress() const{
    return Utils::coreStringToAppString(mLinphoneParticipant->getAddress()->asStringUriOnly());
}

QDateTime ParticipantModel::getCreationTime() const{
    return QDateTime::fromSecsSinceEpoch(mLinphoneParticipant->getCreationTime());
}

//std::list<std::shared_ptr<linphone::ParticipantDevice>> ParticipantModel::getDevices() const;
bool ParticipantModel::isAdmin() const{
    return mLinphoneParticipant->isAdmin();
}
bool ParticipantModel::isFocus() const{
    return mLinphoneParticipant->isFocus();
}
//linphone::ChatRoomSecurityLevel ParticipantModel::getSecurityLevel() const;
//std::shared_ptr<linphone::ParticipantDevice> ParticipantModel::findDevice(const std::shared_ptr<const linphone::Address> & address) const;
