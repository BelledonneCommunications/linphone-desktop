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

#ifndef PARTICIPANT_DEVICE_LIST_H_
#define PARTICIPANT_DEVICE_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "core/call/CallCore.hpp"
#include "core/participant/ParticipantDeviceCore.hpp"
#include <QDateTime>
#include <QObject>
#include <QString>

class ParticipantDeviceList : public ListProxy, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<ParticipantDeviceList> create(const std::shared_ptr<linphone::Participant> &participant);
	static QSharedPointer<ParticipantDeviceList> create();

	ParticipantDeviceList(const std::shared_ptr<linphone::Participant> &participant, QObject *parent = nullptr);
	// ParticipantDeviceList(CallCore *callCore, QObject *parent = nullptr);
	ParticipantDeviceList(QObject *parent = Q_NULLPTR);
	~ParticipantDeviceList();

	void setSelf(QSharedPointer<ParticipantDeviceList> me);

	void initConferenceModel();
	void updateDevices(std::shared_ptr<linphone::Participant> participant);
	void updateDevices(const std::list<QSharedPointer<ParticipantDeviceCore>> &devices, const bool &isMe);

	bool add(const QSharedPointer<ParticipantDeviceCore> &deviceToAdd);
	bool remove(std::shared_ptr<const linphone::ParticipantDevice> deviceToAdd);
	QSharedPointer<ParticipantDeviceCore> get(std::shared_ptr<const linphone::ParticipantDevice> deviceToGet,
	                                          int *index = nullptr);
	QSharedPointer<ParticipantDeviceCore> getMe(int *index = nullptr) const;
	ParticipantDeviceCore *getActiveSpeakerModel() const;

	bool isMe(std::shared_ptr<linphone::ParticipantDevice> device) const;
	bool isMeAlone() const;

public slots:
	void onActiveSpeakerParticipantDevice(const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void onConferenceModelChanged();
	void onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void onParticipantAdded(const std::shared_ptr<const linphone::Participant> &participant);
	void onParticipantRemoved(const std::shared_ptr<const linphone::Participant> &participant);
	void onParticipantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void onParticipantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void onConferenceStateChanged(linphone::Conference::State newState);
	void onParticipantDeviceMediaCapabilityChanged(
	    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void onParticipantDeviceMediaAvailabilityChanged(
	    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void onParticipantDeviceIsSpeakingChanged(const std::shared_ptr<const linphone::ParticipantDevice> &device,
	                                          bool isSpeaking);
	void onParticipantDeviceSpeaking();

signals:
	void activeSpeakerChanged();
	void securityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void participantSpeaking(ParticipantDeviceCore *speakingDevice);
	void conferenceCreated();
	void meChanged();

private:
	CallCore *mCallCore = nullptr;
	QSharedPointer<ParticipantDeviceCore> mActiveSpeaker;
	// QList<ParticipantDeviceCore*> mActiveSpeakers;// First item is last speaker
	bool mInitialized = false;
	QSharedPointer<SafeConnection<ParticipantDeviceList, CallModel>> mModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(QSharedPointer<ParticipantDeviceList>);

#endif // PARTICIPANT_DEVICE_LIST_H_
