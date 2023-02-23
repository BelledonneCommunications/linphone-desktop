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

#ifndef PARTICIPANT_DEVICE_LISTENER_H_
#define PARTICIPANT_DEVICE_LISTENER_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

class CallModel;

class ParticipantDeviceListener : public QObject, public linphone::ParticipantDeviceListener {
    Q_OBJECT
	
public:
    ParticipantDeviceListener (QObject *parent = nullptr);
    
	virtual void onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isSpeaking) override;
	virtual void onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isMuted) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::ParticipantDevice::State state) override;
	virtual void onStreamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::MediaDirection direction, linphone::StreamType streamType) override;
	virtual void onStreamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool available, linphone::StreamType streamType) override;
signals:
	void isSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isSpeaking);
	void isMuted(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isMuted);
	void stateChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::ParticipantDevice::State state);
	void streamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::MediaDirection direction, linphone::StreamType streamType);
	void streamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool available, linphone::StreamType streamType);
};

#endif // PARTICIPANT_MODEL_H_
