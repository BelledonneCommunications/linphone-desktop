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

#ifndef TIMELINE_MODEL_H_
#define TIMELINE_MODEL_H_

#include <QSortFilterProxyModel>
// =============================================================================
#include <QObject>
#include <QDateTime>

#include <linphone++/chat_room.hh>

#include "../contact/ContactModel.hpp"

class ChatRoomModel;

class TimelineModel : public QObject, public linphone::ChatRoomListener {
  Q_OBJECT

public:
	TimelineModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject *parent = Q_NULLPTR);
	virtual ~TimelineModel();
	
	Q_PROPERTY(QString fullPeerAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString fullLocalAddress READ getFullLocalAddress NOTIFY fullLocalAddressChanged)
	Q_PROPERTY(ChatRoomModel* chatRoomModel READ getChatRoomModel CONSTANT)
	
// Contact
	//Q_PROPERTY(QString sipAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	//Q_PROPERTY(QString username READ getUsername NOTIFY usernameChanged)
	//Q_PROPERTY(QString avatar READ getAvatar NOTIFY avatarChanged)
	//Q_PROPERTY(int presenceStatus READ getPresenceStatus NOTIFY presenceStatusChanged)
	Q_PROPERTY(bool selected MEMBER mSelected WRITE setSelected NOTIFY selectedChanged)
	
	
	QString getFullPeerAddress() const;
	QString getFullLocalAddress() const;
	
	QString getUsername() const;
	QString getAvatar() const;
	int getPresenceStatus() const;
	
	void setSelected(const bool& selected);
	
	
	//Q_INVOKABLE std::shared_ptr<ChatRoomModel> getChatRoomModel() const;
	Q_INVOKABLE ChatRoomModel* getChatRoomModel() const;

	bool mSelected;
	//QDateTime mTimestamp;
	std::shared_ptr<ChatRoomModel> mChatRoomModel;
	//std::shared_ptr<linphone::ChatRoom> mChatRoom;
	
	virtual void onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing) override;
	virtual void onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message) override;
	virtual void onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState) override;
	virtual void onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message) override;
	virtual void onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	virtual void onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom) override;
	virtual void onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress) override;
	virtual void onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress) override;
	virtual void onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message) override;
	virtual void onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state) override;
	
public slots:
	void updateUnreadCount();
	
signals:
	void fullPeerAddressChanged();
	void fullLocalAddressChanged();
	void usernameChanged();
	void avatarChanged();
	void presenceStatusChanged();
	void selectedChanged(bool selected);
  
};

#endif // TIMELINE_MODEL_H_
