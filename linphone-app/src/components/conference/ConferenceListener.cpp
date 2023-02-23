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
void ConferenceListener::onActiveSpeakerParticipantDevice(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice) {
	qDebug() << "onActiveSpeakerParticipantDevice: "  << participantDevice->getAddress()->asString().c_str();
	emit activeSpeakerParticipantDevice(participantDevice);
}

void ConferenceListener::onParticipantAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qDebug() << "onParticipantAdded: " << participant->getAddress()->asString().c_str();
	emit participantAdded(participant);
}
void ConferenceListener::onParticipantRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qDebug() << "onParticipantRemoved";
	emit participantRemoved(participant);
}
void ConferenceListener::onParticipantDeviceAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "onParticipantDeviceAdded";
	qDebug() << "Me devices : " << conference->getMe()->getDevices().size();
	if( conference->getMe()->getDevices().size() > 1)
		for(auto d : conference->getMe()->getDevices())
			qDebug() << "\t--> " << d->getAddress()->asString().c_str();
	emit participantDeviceAdded(participantDevice);
}
void ConferenceListener::onParticipantDeviceRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "onParticipantDeviceRemoved: " << participantDevice->getAddress()->asString().c_str() << " isInConf?[" << participantDevice->isInConference() << "]";
	qDebug() << "Me devices : " << conference->getMe()->getDevices().size();
	emit participantDeviceRemoved(participantDevice);
}
void ConferenceListener::onParticipantDeviceStateChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device, linphone::ParticipantDevice::State state) {
	qDebug() << "onParticipantDeviceStateChanged: " << device->getAddress()->asString().c_str() << " isInConf?[" << device->isInConference() << "] " << (int)state;
	emit participantDeviceStateChanged(conference, device, state);
}
void ConferenceListener::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qDebug() << "onParticipantAdminStatusChanged";
	emit participantAdminStatusChanged(participant);
}
void ConferenceListener::onParticipantDeviceMediaCapabilityChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "onParticipantDeviceMediaCapabilityChanged: "  << (int)participantDevice->getStreamCapability(linphone::StreamType::Video) << ". Device: " << participantDevice->getAddress()->asString().c_str();
	emit participantDeviceMediaCapabilityChanged(participantDevice);
}
void ConferenceListener::onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "onParticipantDeviceMediaAvailabilityChanged: "  << (int)participantDevice->getStreamAvailability(linphone::StreamType::Video) << ". Device: " << participantDevice->getAddress()->asString().c_str();
	emit participantDeviceMediaAvailabilityChanged(participantDevice);
}
void ConferenceListener::onParticipantDeviceIsSpeakingChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice, bool isSpeaking) {
	//qDebug() << "onParticipantDeviceIsSpeakingChanged: "  << participantDevice->getAddress()->asString().c_str() << ". Speaking:" << isSpeaking;
	emit participantDeviceIsSpeakingChanged(participantDevice, isSpeaking);
}
void ConferenceListener::onStateChanged(const std::shared_ptr<linphone::Conference> & conference, linphone::Conference::State newState){
	qDebug() << "onStateChanged:" << (int)newState;
	emit conferenceStateChanged(newState);
}
void ConferenceListener::onSubjectChanged(const std::shared_ptr<linphone::Conference> & conference, const std::string & subject){
	qDebug() << "onSubjectChanged";
	emit subjectChanged(subject);
}
void ConferenceListener::onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::AudioDevice> & audioDevice){
	qDebug() << "onAudioDeviceChanged is not yet implemented.";
}
	
	
//-----------------------------------------------------------------------------------------------------------------------	
