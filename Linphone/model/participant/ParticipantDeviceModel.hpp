/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_DEVICE_MODEL_H_
#define PARTICIPANT_DEVICE_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"
#include <linphone++/linphone.hh>

#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <QString>

class ParticipantDeviceModel : public ::Listener<linphone::ParticipantDevice, linphone::ParticipantDeviceListener>,
                               public linphone::ParticipantDeviceListener,
                               public AbstractObject {
	Q_OBJECT

public:
	ParticipantDeviceModel(const std::shared_ptr<linphone::ParticipantDevice> &device, QObject *parent = nullptr);
	virtual ~ParticipantDeviceModel();

	QString getName() const;
	QString getDisplayName() const;
	QString getAddress() const;
	int getSecurityLevel() const;
	time_t getTimeOfJoining() const;
	bool isVideoEnabled() const;
	// bool isLocal() const;
	bool getPaused() const;
	bool getIsSpeaking() const;
	bool getIsMuted() const;
	LinphoneEnums::ParticipantDeviceState getState() const;

	virtual void onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
	                                 bool isSpeaking) override;
	virtual void onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
	                       bool isMuted) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
	                            linphone::ParticipantDevice::State state) override;
	virtual void onStreamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
	                                       linphone::MediaDirection direction,
	                                       linphone::StreamType streamType) override;
	virtual void onStreamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
	                                         bool available,
	                                         linphone::StreamType streamType) override;

	// void updateVideoEnabled();
	// void updateIsLocal();

signals:
	// void securityLevelChanged();
	// void videoEnabledChanged();
	void isSpeakingChanged(bool speaking);
	void isMutedChanged(bool muted);
	void stateChanged(LinphoneEnums::ParticipantDeviceState state);
	void streamCapabilityChanged(linphone::StreamType streamType);
	void streamAvailabilityChanged(linphone::StreamType streamType);

private:
	DECLARE_ABSTRACT_OBJECT
};

#endif // PARTICIPANT_DEVICE_MODEL_H_
