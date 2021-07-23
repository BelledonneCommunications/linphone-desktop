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

#ifndef CHAT_ROOM_MODEL_H_
#define CHAT_ROOM_MODEL_H_

#include <linphone++/linphone.hh>
#include <QAbstractListModel>
#include <QDateTime>

// =============================================================================
// Fetch all N messages of a ChatRoom.
// =============================================================================

class CoreHandlers;
class ParticipantModel;
class ParticipantListModel;

class ChatRoomModel : public QAbstractListModel, public linphone::ChatRoomListener {
	class MessageHandlers;
	
	Q_OBJECT
	
public:
	enum Roles {
		ChatEntry = Qt::DisplayRole,
		SectionDate
	};
	
	enum EntryType {
		GenericEntry,
		MessageEntry,
		CallEntry,
		NoticeEntry
	};
	Q_ENUM(EntryType);
	
	enum NoticeType {
		NoticeMessage,
		NoticeError
	};
	Q_ENUM(NoticeType);
	
	
	enum CallStatus {
		CallStatusDeclined = int(linphone::Call::Status::Declined),
		CallStatusMissed = int(linphone::Call::Status::Missed),
		CallStatusSuccess = int(linphone::Call::Status::Success),
		CallStatusAborted = int(linphone::Call::Status::Aborted),
		CallStatusEarlyAborted = int(linphone::Call::Status::EarlyAborted),
		CallStatusAcceptedElsewhere = int(linphone::Call::Status::AcceptedElsewhere),
		CallStatusDeclinedElsewhere = int(linphone::Call::Status::DeclinedElsewhere)
	};
	Q_ENUM(CallStatus);
	
	enum MessageStatus {
		MessageStatusDelivered = int(linphone::ChatMessage::State::Delivered),
		MessageStatusDeliveredToUser = int(linphone::ChatMessage::State::DeliveredToUser),
		MessageStatusDisplayed = int(linphone::ChatMessage::State::Displayed),
		MessageStatusFileTransferDone = int(linphone::ChatMessage::State::FileTransferDone),
		MessageStatusFileTransferError = int(linphone::ChatMessage::State::FileTransferError),
		MessageStatusFileTransferInProgress = int(linphone::ChatMessage::State::FileTransferInProgress),
		MessageStatusIdle = int(linphone::ChatMessage::State::Idle),
		MessageStatusInProgress = int(linphone::ChatMessage::State::InProgress),
		MessageStatusNotDelivered = int(linphone::ChatMessage::State::NotDelivered)
		
	};
	Q_ENUM(MessageStatus);
	
	//Q_PROPERTY(QString participants READ getParticipants NOTIFY participantsChanged);
	//Q_PROPERTY(ParticipantProxyModel participants READ getParticipants NOTIFY participantsChanged);
	Q_PROPERTY(QString subject READ getSubject NOTIFY subjectChanged)
	Q_PROPERTY(QDateTime lastUpdateTime MEMBER mLastUpdateTime WRITE setLastUpdateTime NOTIFY lastUpdateTimeChanged)
	Q_PROPERTY(int unreadMessagesCount MEMBER mUnreadMessagesCount WRITE setUnreadMessagesCount NOTIFY unreadMessagesCountChanged)
	Q_PROPERTY(int missedCallsCount MEMBER mMissedCallsCount WRITE setMissedCallsCount NOTIFY missedCallsCountChanged)
	
	Q_PROPERTY(int securityLevel READ getSecurityLevel NOTIFY securityLevelChanged)
	Q_PROPERTY(bool groupEnabled READ isGroupEnabled NOTIFY groupEnabledChanged)
	Q_PROPERTY(bool haveEncryption READ haveEncryption CONSTANT)
	
	Q_PROPERTY(bool isComposing MEMBER mIsRemoteComposing NOTIFY isRemoteComposingChanged)
	Q_PROPERTY(bool hasBeenLeft READ hasBeenLeft NOTIFY hasBeenLeftChanged)
	
	
	
	Q_PROPERTY(QString sipAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString sipAddressUriOnly READ getPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString username READ getUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString avatar READ getAvatar NOTIFY avatarChanged)
	Q_PROPERTY(int presenceStatus READ getPresenceStatus NOTIFY presenceStatusChanged)
	Q_PROPERTY(int state READ getState NOTIFY stateChanged)
	
	Q_PROPERTY(long ephemeralLifetime READ getEphemeralLifetime WRITE setEphemeralLifetime NOTIFY ephemeralLifetimeChanged)
	Q_PROPERTY(bool ephemeralEnabled READ getEphemeralEnabled WRITE setEphemeralEnabled NOTIFY ephemeralEnabledChanged)
	
	
	
	//ChatRoomModel (const QString &peerAddress, const QString &localAddress, const bool& isSecure);
	ChatRoomModel (std::shared_ptr<linphone::ChatRoom> chatRoom);
	~ChatRoomModel ();
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role) const override;
	
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	Q_INVOKABLE QString getPeerAddress () const;
	Q_INVOKABLE QString getLocalAddress () const;
	Q_INVOKABLE QString getFullPeerAddress () const;
	Q_INVOKABLE QString getFullLocalAddress () const;
	Q_INVOKABLE QString getConferenceAddress () const;
	
	QString getSubject () const;
	QString getUsername () const;
	QString getAvatar () const;
	int getPresenceStatus() const;
	int getState() const;
	bool hasBeenLeft() const;
	bool getEphemeralEnabled() const;
	long getEphemeralLifetime() const;
	
	
	void setLastUpdateTime(const QDateTime& lastUpdateDate);
	
	void setUnreadMessagesCount(const int& count);
	void setMissedCallsCount(const int& count);
	void setEphemeralEnabled(bool enabled);
	void setEphemeralLifetime(long lifetime);
	
	
	Q_INVOKABLE void leaveChatRoom ();
	
	Q_INVOKABLE bool haveEncryption() const;
	Q_INVOKABLE bool isSecure() const;
	int getSecurityLevel() const;
	bool isGroupEnabled() const;
	
	bool getIsRemoteComposing () const;
	
	
	//Q_INVOKABLE QList<ParticipantModel*> getParticipants()const
	//Q_INVOKABLE QString getParticipants()const;
	//QList<std::shared_ptr<ParticipantModel> > getParticipants();
	//Q_INVOKABLE std::shared_ptr<ParticipantListModel> getParticipants();
	Q_PROPERTY(ParticipantListModel* participants READ getParticipants CONSTANT)
	
	ParticipantListModel* getParticipants() const;
	
	
	void removeEntry (int id);
	void removeAllEntries ();
	
	void sendMessage (const QString &message);
	
	void resendMessage (int id);
	
	void sendFileMessage (const QString &path);
	
	void downloadFile (int id);
	void openFile (int id, bool showDirectory = false);
	void openFileDirectory (int id) {
		openFile(id, true);
	}
	
	bool fileWasDownloaded (int id);
	
	void compose ();
	
	void resetMessageCount ();
	
	std::shared_ptr<linphone::ChatRoom> getChatRoom();
	QDateTime mLastUpdateTime;
	int mUnreadMessagesCount = 0;
	int mMissedCallsCount = 0;
	
	
	//--------------------		CHAT ROOM HANDLER
	
	
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
	
	
signals:
	bool isRemoteComposingChanged (bool status);
	
	void allEntriesRemoved ();
	void lastEntryRemoved ();
	
	void messageSent (const std::shared_ptr<linphone::ChatMessage> &message);
	void messageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
	
	void messageCountReset ();
	
	void focused ();
	
	void fullPeerAddressChanged();
	void participantsChanged();
	void subjectChanged(QString subject);
	void usernameChanged(QString username);
	void avatarChanged(QString avatar);
	void presenceStatusChanged();
	void lastUpdateTimeChanged();
	void unreadMessagesCountChanged();
	void missedCallsCountChanged();
	
	void securityLevelChanged(int securityLevel);
	void groupEnabledChanged(bool groupEnabled);
	void stateChanged(int state);
	void hasBeenLeftChanged();
	void ephemeralEnabledChanged();
	void ephemeralLifetimeChanged();
	
	
// Chat Room listener callbacks	
	
	void securityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	void participantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	void conferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	
private:
	typedef QPair<QVariantMap, std::shared_ptr<void>> ChatEntryData;
	
	//void setSipAddresses (const QString &peerAddress, const QString &localAddress, const bool& isSecure);
	
	const ChatEntryData getFileMessageEntry (int id);
	
	void removeEntry (ChatEntryData &entry);
	
	void insertCall (const std::shared_ptr<linphone::CallLog> &callLog);
	void insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message);
	void insertNotice (const std::shared_ptr<linphone::EventLog> &enventLog);
	
	void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	void handleCallCreated(const std::shared_ptr<linphone::Call> &call);// Count an event call
	void handlePresenceStatusReceived(std::shared_ptr<linphone::Friend> contact);
	//void handleIsComposingChanged (const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	//void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
	
	bool mIsRemoteComposing = false;
	
	mutable QList<ChatEntryData> mEntries;
	//QList<ParticipantModel*> mParticipants;
	std::shared_ptr<ParticipantListModel> mParticipantListModel;
	
	std::shared_ptr<CoreHandlers> mCoreHandlers;
	std::shared_ptr<MessageHandlers> mMessageHandlers;
	
	std::shared_ptr<linphone::ChatRoom> mChatRoom;
};

Q_DECLARE_METATYPE(std::shared_ptr<ChatRoomModel>);

#endif // CHAT_ROOM_MODEL_H_
