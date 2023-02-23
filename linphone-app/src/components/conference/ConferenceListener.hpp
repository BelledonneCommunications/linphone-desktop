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

#ifndef CONFERENCE_LISTENER_H_
#define CONFERENCE_LISTENER_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

class ConferenceListener : public QObject, public linphone::ConferenceListener{
	Q_OBJECT
public:
	ConferenceListener();
	virtual ~ConferenceListener();

// LINPHONE LISTENERS
	virtual void onActiveSpeakerParticipantDevice(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice) override;
	virtual void onParticipantAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant) override;
	virtual void onParticipantRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant) override;
	virtual void onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant) override;
	virtual void onParticipantDeviceAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice) override;
	virtual void onParticipantDeviceRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice) override;
	virtual void onParticipantDeviceStateChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device, linphone::ParticipantDevice::State state) override;
	virtual void onParticipantDeviceMediaCapabilityChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device) override;
	virtual void onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device) override;
	virtual void onParticipantDeviceIsSpeakingChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice, bool isSpeaking) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::Conference> & conference, linphone::Conference::State newState) override;
	virtual void onSubjectChanged(const std::shared_ptr<linphone::Conference> & conference, const std::string & subject) override;
	virtual void onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::AudioDevice> & audioDevice) override;
//---------------------------------------------------------------------------
	
signals:
	void activeSpeakerParticipantDevice(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantAdded(const std::shared_ptr<const linphone::Participant> & participant);
	void participantRemoved(const std::shared_ptr<const linphone::Participant> & participant);
	void participantAdminStatusChanged(const std::shared_ptr<const linphone::Participant> & participant);
	void participantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceStateChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device, linphone::ParticipantDevice::State state);
	void participantDeviceMediaCapabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceIsSpeakingChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice, bool isSpeaking);
	void conferenceStateChanged(linphone::Conference::State newState);
	void subjectChanged(const std::string & subject);
	
};


#endif
