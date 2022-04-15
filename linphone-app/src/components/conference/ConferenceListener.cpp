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

#include "ConferenceListener.hpp"

#include <QQmlApplicationEngine>
#include <QDesktopServices>
#include <QImageReader>
#include <QMessageBox>

#include "app/App.hpp"
#include "app/paths/Paths.hpp"



// =============================================================================

ConferenceListener::ConferenceListener () : QObject(nullptr) {
}

ConferenceListener::~ConferenceListener(){
}

//-----------------------------------------------------------------------------------------------------------------------
//												LINPHONE LISTENERS
//-----------------------------------------------------------------------------------------------------------------------
void ConferenceListener::onParticipantAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qWarning() << "onParticipantAdded";
	emit participantAdded(participant);
}
void ConferenceListener::onParticipantRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qWarning() << "onParticipantRemoved";
	emit participantRemoved(participant);
}
void ConferenceListener::onParticipantDeviceAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "onParticipantDeviceAdded";
	qWarning() << "Me devices : " << conference->getMe()->getDevices().size();
	emit participantDeviceAdded(participantDevice);
}
void ConferenceListener::onParticipantDeviceRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "onParticipantDeviceRemoved";
	qWarning() << "Me devices : " << conference->getMe()->getDevices().size();
	emit participantDeviceRemoved(participantDevice);
}
void ConferenceListener::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qWarning() << "onParticipantAdminStatusChanged";
}
void ConferenceListener::onParticipantDeviceLeft(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "onParticipantDeviceLeft";
	qWarning() << "Me devices : " << conference->getMe()->getDevices().size();
	emit participantDeviceLeft(participantDevice);
}
void ConferenceListener::onParticipantDeviceJoined(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "onParticipantDeviceJoined";
	qWarning() << "Me devices : " << conference->getMe()->getDevices().size();
	emit participantDeviceJoined(participantDevice);
}
void ConferenceListener::onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "onParticipantDeviceMediaAvailabilityChanged";
	qWarning() << "ConferenceListener::onParticipantDeviceMediaAvailabilityChanged: "  << (int)participantDevice->getStreamAvailability(linphone::StreamType::Video) << ". Me devices : " << conference->getMe()->getDevices().size();
	emit participantDeviceMediaAvailabilityChanged(participantDevice);
}
void ConferenceListener::onStateChanged(const std::shared_ptr<linphone::Conference> & conference, linphone::Conference::State newState){
	qWarning() << "onStateChanged";
	emit conferenceStateChanged(newState);
}
void ConferenceListener::onSubjectChanged(const std::shared_ptr<linphone::Conference> & conference, const std::string & subject){
	qWarning() << "onSubjectChanged";
	emit subjectChanged(subject);
}
void ConferenceListener::onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::AudioDevice> & audioDevice){
	qWarning() << "onAudioDeviceChanged is not yet implemented.";
}
	
	
//-----------------------------------------------------------------------------------------------------------------------	