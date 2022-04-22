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
	qWarning() << "onIsSpeakingChanged " << isSpeaking;
	emit isSpeakingChanged(participantDevice, isSpeaking);
}

void ParticipantDeviceListener::onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isMutedVar) {
	qWarning() << "onIsMuted " << isMutedVar << " vs " << participantDevice->getIsMuted();
	emit isMuted(participantDevice, isMutedVar);
}

void ParticipantDeviceListener::onConferenceJoined(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice) {
	emit conferenceJoined(participantDevice);
}

void ParticipantDeviceListener::onConferenceLeft(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice) {
	emit conferenceLeft(participantDevice);
}
void ParticipantDeviceListener::onStreamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::MediaDirection direction, linphone::StreamType streamType) {
	emit streamCapabilityChanged(participantDevice, direction, streamType);
}

void ParticipantDeviceListener::onStreamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool available, linphone::StreamType streamType) {
	emit streamAvailabilityChanged(participantDevice, available, streamType);
}