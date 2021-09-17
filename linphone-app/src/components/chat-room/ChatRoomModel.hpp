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
class ChatEvent;
class ContactModel;
class ChatRoomModel;

class ChatRoomModelListener : public QObject, public linphone::ChatRoomListener {
Q_OBJECT
public:
	ChatRoomModelListener(ChatRoomModel * model, QObject * parent = nullptr);
	virtual ~ChatRoomModelListener(){}
		
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
	void isComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing);
	void messageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message);
	void newEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void chatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void chatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void chatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void stateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState);
	void securityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void subjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void undecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message);
	void participantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void conferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void conferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void ephemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void ephemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void ephemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void conferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom);
	void participantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	void participantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	void chatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message);
	void chatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state);


};

class ChatRoomModel : public QAbstractListModel {
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
	
	
	//Q_PROPERTY(QString participants READ getParticipants NOTIFY participantsChanged);
	//Q_PROPERTY(ParticipantProxyModel participants READ getParticipants NOTIFY participantsChanged);
	Q_PROPERTY(QString subject READ getSubject WRITE setSubject NOTIFY subjectChanged)
	Q_PROPERTY(QDateTime lastUpdateTime MEMBER mLastUpdateTime WRITE setLastUpdateTime NOTIFY lastUpdateTimeChanged)
	Q_PROPERTY(int unreadMessagesCount MEMBER mUnreadMessagesCount WRITE setUnreadMessagesCount NOTIFY unreadMessagesCountChanged)
	Q_PROPERTY(int missedCallsCount MEMBER mMissedCallsCount WRITE setMissedCallsCount NOTIFY missedCallsCountChanged)
	
	Q_PROPERTY(int securityLevel READ getSecurityLevel NOTIFY securityLevelChanged)
	Q_PROPERTY(bool groupEnabled READ isGroupEnabled NOTIFY groupEnabledChanged)
	Q_PROPERTY(bool isConference READ isConference CONSTANT)
	Q_PROPERTY(bool isOneToOne READ isOneToOne CONSTANT)
	Q_PROPERTY(bool haveEncryption READ haveEncryption CONSTANT)
	Q_PROPERTY(bool isMeAdmin READ isMeAdmin NOTIFY isMeAdminChanged)
	Q_PROPERTY(bool canHandleParticipants READ canHandleParticipants CONSTANT)
	
	//Q_PROPERTY(bool isComposing MEMBER mIsRemoteComposing NOTIFY isRemoteComposingChanged)
	Q_PROPERTY(QList<QString> composers READ getComposers NOTIFY isRemoteComposingChanged)
	Q_PROPERTY(bool hasBeenLeft READ hasBeenLeft NOTIFY hasBeenLeftChanged)
	
	Q_PROPERTY(QString sipAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString sipAddressUriOnly READ getPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString username READ getUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString avatar READ getAvatar NOTIFY avatarChanged)
	Q_PROPERTY(int presenceStatus READ getPresenceStatus NOTIFY presenceStatusChanged)
	Q_PROPERTY(int state READ getState NOTIFY stateChanged)
	
	Q_PROPERTY(long ephemeralLifetime READ getEphemeralLifetime WRITE setEphemeralLifetime NOTIFY ephemeralLifetimeChanged)
	Q_PROPERTY(bool ephemeralEnabled READ isEphemeralEnabled WRITE setEphemeralEnabled NOTIFY ephemeralEnabledChanged)
	Q_PROPERTY(bool canBeEphemeral READ canBeEphemeral NOTIFY canBeEphemeralChanged)
	
	Q_PROPERTY(ParticipantListModel* participants READ getParticipants CONSTANT)
	
	
	
	//ChatRoomModel (const QString &peerAddress, const QString &localAddress, const bool& isSecure);
	static std::shared_ptr<ChatRoomModel> create(std::shared_ptr<linphone::ChatRoom> chatRoom);
	ChatRoomModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject * parent = nullptr);
	~ChatRoomModel ();
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role) const override;
	
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	void removeAllEntries ();

//---- Getters
	
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
	bool isEphemeralEnabled() const;
	long getEphemeralLifetime() const;
	bool canBeEphemeral();
	bool haveEncryption() const;
	Q_INVOKABLE bool isSecure() const;
	int getSecurityLevel() const;
	bool isGroupEnabled() const;
	bool isConference() const;
	bool isOneToOne() const;
	bool isMeAdmin() const;
	bool isCurrentProxy() const;						// Return true if this chat room is Me() is the current proxy
	bool canHandleParticipants() const;
	bool getIsRemoteComposing () const;
	ParticipantListModel* getParticipants() const;
	std::shared_ptr<linphone::ChatRoom> getChatRoom();
	QList<QString> getComposers();
		
//---- Setters
	void setSubject(QString& subject);
	void setLastUpdateTime(const QDateTime& lastUpdateDate);
	void updateLastUpdateTime();
	
	void setUnreadMessagesCount(const int& count);	
	void setMissedCallsCount(const int& count);
	void addMissedCallsCount(std::shared_ptr<linphone::Call> call);
	void setEphemeralEnabled(bool enabled);
	void setEphemeralLifetime(long lifetime);

// Tools
	
	void deleteChatRoom();
	Q_INVOKABLE void leaveChatRoom ();
	Q_INVOKABLE void updateParticipants(const QVariantList& participants);		
	void sendMessage (const QString &message);	
	void sendFileMessage (const QString &path);
	void compose ();
	void resetMessageCount ();
	Q_INVOKABLE void initEntries();
	Q_INVOKABLE int loadMoreEntries();	// return new entries count
	void callEnded(std::shared_ptr<linphone::Call> call);
	
	QDateTime mLastUpdateTime;
	int mUnreadMessagesCount = 0;
	int mMissedCallsCount = 0;
	bool mIsInitialized = false;
	
	bool mDeleteChatRoom = false;	// Use as workaround because of core->deleteChatRoom() that call destructor without takking account of count ref : call it in ChatRoomModel destructor	
	int mLastEntriesStep = 50;		// Retrieve a part of the history to avoid too much processing
	
	
	void insertCall (const std::shared_ptr<linphone::CallLog> &callLog);
	void insertCalls (const QList<std::shared_ptr<linphone::CallLog> > &calls);
	void insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message);
	void insertMessages (const QList<std::shared_ptr<linphone::ChatMessage> > &messages);
	void insertNotice (const std::shared_ptr<linphone::EventLog> &enventLog);
	void insertNotices (const QList<std::shared_ptr<linphone::EventLog>> &eventLogs);
	
	
	//--------------------		CHAT ROOM HANDLER
	
public slots:
	virtual void onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing);
	virtual void onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message);
	virtual void onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState);
	virtual void onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message);
	virtual void onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom);
	virtual void onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	virtual void onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	virtual void onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message);
	virtual void onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state) ;


	void removeEntry(ChatEvent* entry);	
	
signals:
	bool isRemoteComposingChanged ();
	
	void allEntriesRemoved (std::shared_ptr<ChatRoomModel> model);
	void lastEntryRemoved ();
	
	void messageSent (const std::shared_ptr<linphone::ChatMessage> &message);
	void messageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
	
	void messageCountReset ();
	
	void focused ();
	
	void fullPeerAddressChanged();
	void participantsChanged();
	void subjectChanged(QString subject);
	void usernameChanged();
	void avatarChanged(QString avatar);
	void presenceStatusChanged();
	void lastUpdateTimeChanged();
	void unreadMessagesCountChanged();
	void missedCallsCountChanged();
	
	void securityLevelChanged(int securityLevel);
	void groupEnabledChanged(bool groupEnabled);
	void isMeAdminChanged();
	void stateChanged(int state);
	void hasBeenLeftChanged();
	void ephemeralEnabledChanged();
	void ephemeralLifetimeChanged();
	void canBeEphemeralChanged();
	void chatRoomDeleted();// Must be connected with DirectConnection mode	
	
// Chat Room listener callbacks	
	
	void securityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	void participantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress);
	void conferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	void conferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	
private:
	
	void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	void handleCallCreated(const std::shared_ptr<linphone::Call> &call);// Count an event call
	void handlePresenceStatusReceived(std::shared_ptr<linphone::Friend> contact);
	//void handleIsComposingChanged (const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	//void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
	
	//bool mIsRemoteComposing = false;

	QList<std::shared_ptr<ChatEvent> > mEntries;
	std::shared_ptr<ParticipantListModel> mParticipantListModel;
	std::shared_ptr<CoreHandlers> mCoreHandlers;
	std::shared_ptr<MessageHandlers> mMessageHandlers;
	QMap<std::shared_ptr<const linphone::Address>, QString> mComposers;	// Store all addresses that are composing with its username
	std::shared_ptr<linphone::ChatRoom> mChatRoom;
	std::shared_ptr<ChatRoomModelListener> mChatRoomModelListener;
	
	std::weak_ptr<ChatRoomModel> mSelf;
};

Q_DECLARE_METATYPE(std::shared_ptr<ChatRoomModel>)

#endif // CHAT_ROOM_MODEL_H_
