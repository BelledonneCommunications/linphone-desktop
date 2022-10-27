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
#include "app/proxyModel/ProxyListModel.hpp"
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
class ChatMessageModel;
class ChatNoticeModel;
class ChatRoomListener;

class ChatRoomModel : public ProxyListModel {
	
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
	Q_ENUM(EntryType)
	
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
	
	Q_PROPERTY(bool isComposing READ getIsRemoteComposing NOTIFY isRemoteComposingChanged)
	Q_PROPERTY(QList<QString> composers READ getComposers NOTIFY isRemoteComposingChanged)
	Q_PROPERTY(bool isReadOnly READ isReadOnly NOTIFY isReadOnlyChanged)
	
	Q_PROPERTY(QString sipAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString sipAddressUriOnly READ getPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString username READ getUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString avatar READ getAvatar NOTIFY avatarChanged)
	Q_PROPERTY(int presenceStatus READ getPresenceStatus NOTIFY presenceStatusChanged)
	Q_PROPERTY(int state READ getState NOTIFY stateChanged)
	
	Q_PROPERTY(long ephemeralLifetime READ getEphemeralLifetime WRITE setEphemeralLifetime NOTIFY ephemeralLifetimeChanged)
	Q_PROPERTY(bool ephemeralEnabled READ isEphemeralEnabled WRITE setEphemeralEnabled NOTIFY ephemeralEnabledChanged)
	Q_PROPERTY(bool canBeEphemeral READ canBeEphemeral NOTIFY canBeEphemeralChanged)
	Q_PROPERTY(bool markAsReadEnabled READ markAsReadEnabled WRITE enableMarkAsRead NOTIFY markAsReadEnabledChanged)
	
	Q_PROPERTY(ParticipantListModel* participants READ getParticipantListModel CONSTANT)
	
	Q_PROPERTY(ChatMessageModel * reply READ getReply WRITE setReply NOTIFY replyChanged)
	
	Q_PROPERTY(bool entriesLoading READ isEntriesLoading WRITE setEntriesLoading NOTIFY entriesLoadingChanged)
	
	
	static QSharedPointer<ChatRoomModel> create(const std::shared_ptr<linphone::ChatRoom>& chatRoom, const std::list<std::shared_ptr<linphone::CallLog>>& callLogs = std::list<std::shared_ptr<linphone::CallLog>>());
	ChatRoomModel (const std::shared_ptr<linphone::ChatRoom>& chatRoom, const std::list<std::shared_ptr<linphone::CallLog>>& callLogs = std::list<std::shared_ptr<linphone::CallLog>>(), QObject * parent = nullptr);
	
	~ChatRoomModel ();
	
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role) const override;
	
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
	bool isReadOnly() const;
	bool isEphemeralEnabled() const;
	long getEphemeralLifetime() const;
	bool canBeEphemeral();
	bool haveEncryption() const;
	bool haveConferenceAddress() const;
	bool markAsReadEnabled() const;
	Q_INVOKABLE bool isSecure() const;
	int getSecurityLevel() const;
	bool isGroupEnabled() const;
	bool isConference() const;
	bool isOneToOne() const;
	bool isMeAdmin() const;
	bool isCurrentAccount() const;						// Return true if this chat room is Me() is the current account
	bool canHandleParticipants() const;
	bool getIsRemoteComposing () const;
	bool isEntriesLoading() const;
	bool isBasic() const;
	ParticipantListModel* getParticipantListModel() const;
	std::list<std::shared_ptr<linphone::Participant>> getParticipants(const bool& withMe = true) const;
	std::shared_ptr<linphone::ChatRoom> getChatRoom();
	QList<QString> getComposers();
	QString getParticipantAddress();	// return peerAddress if not secure else return the first participant SIP address.
	int getAllUnreadCount();	// Return unread messages and missed call.
		
//---- Setters
	void setSubject(QString& subject);
	void setLastUpdateTime(const QDateTime& lastUpdateDate);
	void updateLastUpdateTime();
	void setEntriesLoading(const bool& loading);
	
	void setUnreadMessagesCount(const int& count);	
	void setMissedCallsCount(const int& count);
	void addMissedCallsCount(std::shared_ptr<linphone::Call> call);
	void setEphemeralEnabled(bool enabled);
	void setEphemeralLifetime(long lifetime);
	void enableMarkAsRead(const bool& enable);
	
	void setReply(ChatMessageModel * model);
	ChatMessageModel * getReply()const;
	void clearReply();
	
	void clearFilesToSend();

// Tools
	void markAsToDelete();
	Q_INVOKABLE void deleteChatRoom();
	Q_INVOKABLE void leaveChatRoom ();
	Q_INVOKABLE void updateParticipants(const QVariantList& participants);		
	void sendMessage (const QString &message);
	Q_INVOKABLE void forwardMessage(ChatMessageModel * model);
	void compose ();
	Q_INVOKABLE void resetMessageCount ();
	void initEntries();
	Q_INVOKABLE int loadMoreEntries();	// return new entries count
	void onCallEnded(std::shared_ptr<linphone::Call> call);
	void updateNewMessageNotice(const int& count);
	Q_INVOKABLE int loadTillMessage(ChatMessageModel * message);// Load all entries till message and return its index. -1 if not found.
	static bool isTerminated(const std::shared_ptr<linphone::ChatRoom>& chatRoom);
	bool exists(const std::shared_ptr<linphone::ChatMessage> message) const;
	
	void addBindingCall();	// If a call is binding to this chat room, we avoid cleaning data (Add=+1, remove=-1)
	void removeBindingCall();
	virtual void resetData() override;
	
	QDateTime mLastUpdateTime;
	int mUnreadMessagesCount = 0;
	int mMissedCallsCount = 0;
	bool mIsInitialized = false;
	
	bool mDeleteChatRoom = false;	// Use as workaround because of core->deleteChatRoom() that call destructor without takking account of count ref : call it in ChatRoomModel destructor	
	int mLastEntriesStep = 50;		// Retrieve a part of the history to avoid too much processing
	int mFirstLastEntriesStep = 10;	// Retrieve a part of the history to avoid too much processing at the init
	bool mMarkAsReadEnabled = true;
	bool mEntriesLoading = false;
	
	
	void insertCall (const std::shared_ptr<linphone::CallLog> &callLog);
	void insertCalls (const QList<std::shared_ptr<linphone::CallLog> > &calls);
	QSharedPointer<ChatMessageModel> insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message);
	void insertMessages (const QList<std::shared_ptr<linphone::ChatMessage> > &messages);
	void insertNotice (const std::shared_ptr<linphone::EventLog> &enventLog);
	void insertNotices (const QList<std::shared_ptr<linphone::EventLog>> &eventLogs);
	
	//--------------------		CHAT ROOM HANDLER
	
public slots:
	virtual void onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing);
	virtual void onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message);
	virtual void onMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::ChatMessage>> & messages);
	virtual void onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onChatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::EventLog>> & eventLogs);
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

	void emitFullPeerAddressChanged();	// Use to call signal when changing data that are not managed by the chat room (like data coming from call)
	
signals:
	bool isRemoteComposingChanged ();
	void entriesLoadingChanged(const bool& loading);
	void moreEntriesLoaded(const int& count);
	
	void allEntriesRemoved (QSharedPointer<ChatRoomModel> model);
	void lastEntryRemoved ();
	
	void messageSent (const std::shared_ptr<linphone::ChatMessage> &message);
	void messageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
	
	void messageCountReset ();
	
	void focused ();
	
	void fullPeerAddressChanged();
	void participantsChanged();
	void subjectChanged(QString subject);
	void usernameChanged();
	void avatarChanged();
	void presenceStatusChanged();
	void lastUpdateTimeChanged();
	void unreadMessagesCountChanged();
	void missedCallsCountChanged();
	
	void securityLevelChanged(int securityLevel);
	void groupEnabledChanged(bool groupEnabled);
	void isMeAdminChanged();
	void stateChanged(int state);
	void isReadOnlyChanged();
	void ephemeralEnabledChanged();
	void ephemeralLifetimeChanged();
	void canBeEphemeralChanged();
	void markAsReadEnabledChanged();
	void chatRoomDeleted();// Must be connected with DirectConnection mode
	void replyChanged();
	
// Chat Room listener callbacks	
	
	void securityEvent(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdded(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantRemoved(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantDeviceAdded(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantDeviceRemoved(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantAdminStatusChanged(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void participantRegistrationSubscriptionRequested(const std::shared_ptr<const linphone::Address> & participantAddress);
	void participantRegistrationUnsubscriptionRequested(const std::shared_ptr<const linphone::Address> & participantAddress);
	void conferenceJoined(const std::shared_ptr<const linphone::EventLog> & eventLog);
	void conferenceLeft(const std::shared_ptr<const linphone::EventLog> & eventLog);
	
private:

	void connectTo(ChatRoomListener * listener);
	
	void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	void handleCallCreated(const std::shared_ptr<linphone::Call> &call);// Count an event call
	void handlePresenceStatusReceived(std::shared_ptr<linphone::Friend> contact);
	
	std::shared_ptr<linphone::ChatRoom> mChatRoom;
	std::shared_ptr<ChatRoomListener> mChatRoomListener;	// This need to be a shared_ptr because of adding it to linphone
	std::shared_ptr<CoreHandlers> mCoreHandlers;					// This need to be a shared_ptr because of adding it to linphone
	
	QMap<std::shared_ptr<const linphone::Address>, QString> mComposers;	// Store all addresses that are composing with its username
	
	QSharedPointer<ParticipantListModel> mParticipantListModel;
	QSharedPointer<ChatMessageModel> mReplyModel;
	QSharedPointer<ChatNoticeModel> mUnreadMessageNotice;
	int mBindingCalls = 0;
	
	QWeakPointer<ChatRoomModel> mSelf;
};

Q_DECLARE_METATYPE(QSharedPointer<ChatRoomModel>)

#endif // CHAT_ROOM_MODEL_H_
