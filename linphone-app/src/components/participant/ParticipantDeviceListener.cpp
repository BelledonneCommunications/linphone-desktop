/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#include "ParticipantDeviceListener.hpp"

#include <QDebug>

// =============================================================================

ParticipantDeviceListener::ParticipantDeviceListener(QObject *parent) : QObject(parent) {
}

//--------------------------------------------------------------------
void ParticipantDeviceListener::onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isSpeaking) {
	qDebug() << "onIsSpeakingChanged " << participantDevice->getAddress()->asString().c_str() << " " << isSpeaking;
	emit isSpeakingChanged(participantDevice, isSpeaking);
}

void ParticipantDeviceListener::onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isMutedVar) {
	qDebug() << "onIsMuted " << isMutedVar << " vs " << participantDevice->getIsMuted() << " for " << participantDevice->getAddress()->asString().c_str();
	emit isMuted(participantDevice, isMutedVar);
}

void ParticipantDeviceListener::onStateChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::ParticipantDevice::State state){
	qDebug() << "onStateChanged: " << participantDevice->getAddress()->asString().c_str() << " " << (int)state;
	emit stateChanged(participantDevice, state);
}

void ParticipantDeviceListener::onStreamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::MediaDirection direction, linphone::StreamType streamType) {
	qDebug() << "onStreamCapabilityChanged: " << participantDevice->getAddress()->asString().c_str() << " " << (int)direction << " / " << (int)streamType;
	emit streamCapabilityChanged(participantDevice, direction, streamType);
}

void ParticipantDeviceListener::onStreamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool available, linphone::StreamType streamType) {
	qDebug() << "onStreamAvailabilityChanged: " << participantDevice->getAddress()->asString().c_str() << " " << available<< " / " << (int)streamType;
	emit streamAvailabilityChanged(participantDevice, available, streamType);
}