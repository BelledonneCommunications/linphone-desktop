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

// =============================================================================

class ParticipantListModel : public QAbstractListModel {
  Q_OBJECT
public:	
	ParticipantListModel (ChatRoomModel * chatRoomModel, QObject *parent = Q_NULLPTR);
	virtual ~ParticipantListModel();
	
	Q_PROPERTY(ChatRoomModel* chatRoomModel READ getChatRoomModel CONSTANT)
    
    void reset();
	void update();
	void selectAll(const bool& selected);
	ParticipantModel * getAt(const int& index);
	const std::shared_ptr<ParticipantModel> getParticipant(const std::shared_ptr<const linphone::Address>& address) const;
  
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
  
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
  
	void add (std::shared_ptr<ParticipantModel> participant);
	void updateParticipants();	// Update list from Chat Room
// Remove a chatroom
	Q_INVOKABLE void remove (ParticipantModel *importer);
	Q_INVOKABLE ChatRoomModel* getChatRoomModel() const;
	
	Q_INVOKABLE QString addressesToString()const;	
	Q_INVOKABLE QString displayNamesToString()const;
	Q_INVOKABLE QString usernamesToString()const;
	
	bool contains(const QString& address) const;
	
	
	
public slots:
	void onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	void onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	
signals:
	void securityLevelChanged();
	void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void participantsChanged();

private:
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	QList<std::shared_ptr<ParticipantModel>> mParticipants;
	ChatRoomModel* mChatRoomModel;
};
Q_DECLARE_METATYPE(std::shared_ptr<ParticipantListModel>);
#endif // PARTICIPANT_LIST_MODEL_H_
