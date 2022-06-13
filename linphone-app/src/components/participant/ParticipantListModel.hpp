/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_LIST_MODEL_H_
#define PARTICIPANT_LIST_MODEL_H_

#include <QSortFilterProxyModel>
#include "components/participant/ParticipantModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"
#include "app/proxyModel/ProxyListModel.hpp"

class ConferenceModel;

// =============================================================================

class ParticipantListModel : public ProxyListModel {
  Q_OBJECT
public:	
	ParticipantListModel (ChatRoomModel * chatRoomModel, QObject *parent = Q_NULLPTR);
	ParticipantListModel (ConferenceModel * conferenceModel, QObject *parent = Q_NULLPTR);
	virtual ~ParticipantListModel();
	
	Q_PROPERTY(ChatRoomModel* chatRoomModel READ getChatRoomModel CONSTANT)
	Q_PROPERTY(QString addressesToString READ addressesToString NOTIFY participantsChanged)
	Q_PROPERTY(QString displayNamesToString READ displayNamesToString NOTIFY participantsChanged)
	Q_PROPERTY(QString usernamesToString READ usernamesToString NOTIFY participantsChanged)
    
    void reset();
	void update();
	void selectAll(const bool& selected);
	const QSharedPointer<ParticipantModel> getParticipant(const std::shared_ptr<const linphone::Address>& address) const;
	const QSharedPointer<ParticipantModel> getParticipant(const std::shared_ptr<const linphone::Participant>& participant) const;
  
	void add (QSharedPointer<ParticipantModel> participant);
	void add(const std::shared_ptr<const linphone::Participant> & participant);
	void add(const std::shared_ptr<const linphone::Address> & participantAddress);
	void updateParticipants();	// Update list from Chat Room

// Remove a chatroom
	Q_INVOKABLE void remove (ParticipantModel *importer);
	Q_INVOKABLE ChatRoomModel* getChatRoomModel() const;
	Q_INVOKABLE ConferenceModel* getConferenceModel() const;
	std::list<std::shared_ptr<linphone::Address>> getParticipants()const;
	
	Q_INVOKABLE QString addressesToString()const;	
	Q_INVOKABLE QString displayNamesToString()const;
	Q_INVOKABLE QString usernamesToString()const;
	
	bool contains(const QString& address) const;
	
public slots:
	void setAdminStatus(const std::shared_ptr<linphone::Participant> participant, const bool& isAdmin);

	void onSecurityEvent(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onConferenceJoined();
	void onParticipantAdded(const std::shared_ptr<const linphone::Participant> & participant);
	void onParticipantAdded(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantAdded(const std::shared_ptr<const linphone::Address>& address);
	void onParticipantRemoved(const std::shared_ptr<const linphone::Participant> & participant);
	void onParticipantRemoved(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantRemoved(const std::shared_ptr<const linphone::Address>& address);
	void onParticipantDeviceJoined(const std::shared_ptr<const linphone::ParticipantDevice> & device);
	void onParticipantDeviceJoined(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantDeviceJoined(const std::shared_ptr<const linphone::Address>& address);
	void onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Participant> & participant);
	void onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Address>& address );
	void onParticipantDeviceAdded(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantDeviceRemoved(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<const linphone::Address> & participantAddress);
	void onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<const linphone::Address> & participantAddress);
	void onStateChanged();
	
signals:
	void securityLevelChanged();
	void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void participantsChanged();

private:
	ChatRoomModel* mChatRoomModel = nullptr;
	ConferenceModel *mConferenceModel = nullptr;
};
Q_DECLARE_METATYPE(QSharedPointer<ParticipantListModel>);
#endif // PARTICIPANT_LIST_MODEL_H_
