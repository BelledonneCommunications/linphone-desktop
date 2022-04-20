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

#ifndef PARTICIPANT_DEVICE_LIST_MODEL_H_
#define PARTICIPANT_DEVICE_LIST_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include "app/proxyModel/ProxyListModel.hpp"

class CallModel;
class ParticipantDeviceModel;

class ParticipantDeviceListModel : public ProxyListModel {
	Q_OBJECT
	
public:
	ParticipantDeviceListModel (std::shared_ptr<linphone::Participant> participant, QObject *parent = nullptr);
	ParticipantDeviceListModel (CallModel * callModel, QObject *parent = nullptr);
	
	void updateDevices(std::shared_ptr<linphone::Participant> participant);
	void updateDevices(const std::list<std::shared_ptr<linphone::ParticipantDevice>>& devices, const bool& isMe);
	
	bool add(std::shared_ptr<linphone::ParticipantDevice> deviceToAdd);
	bool remove(std::shared_ptr<const linphone::ParticipantDevice> deviceToAdd);
	QSharedPointer<ParticipantDeviceModel> get(std::shared_ptr<const linphone::ParticipantDevice> deviceToGet, int * index = nullptr);
	
	bool isMe(std::shared_ptr<linphone::ParticipantDevice> device)const;
	bool isMeAlone() const;
	
public slots:
	void onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void onParticipantAdded(const std::shared_ptr<const linphone::Participant> & participant);
	void onParticipantRemoved(const std::shared_ptr<const linphone::Participant> & participant);
	void onParticipantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void onParticipantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void onParticipantDeviceJoined(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void onParticipantDeviceLeft(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void onConferenceStateChanged(linphone::Conference::State newState);
	void onParticipantDeviceMediaCapabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);

signals:
	void securityLevelChanged(std::shared_ptr<const linphone::Address> device);
	
private:
	CallModel * mCallModel = nullptr;
	
};

Q_DECLARE_METATYPE(std::shared_ptr<ParticipantDeviceListModel>)

#endif // PARTICIPANT_MODEL_H_
