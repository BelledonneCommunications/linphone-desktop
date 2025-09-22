/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef CHAT_CORE_H_
#define CHAT_CORE_H_

#include "core/chat/message/EventLogGui.hpp"
#include "core/participant/ParticipantCore.hpp"
#include "message/ChatMessageGui.hpp"
#include "model/chat/ChatModel.hpp"
#include "model/search/MagicSearchModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class EventLogCore;
class FriendModel;
class AccountCore;

class ChatCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	Q_PROPERTY(QString title READ getTitle WRITE setTitle NOTIFY titleChanged)
	Q_PROPERTY(QString identifier READ getIdentifier CONSTANT)
	Q_PROPERTY(QString peerAddress READ getParticipantAddress CONSTANT)
	Q_PROPERTY(QString chatRoomAddress READ getChatRoomAddress CONSTANT)
	Q_PROPERTY(QString avatarUri READ getAvatarUri WRITE setAvatarUri NOTIFY avatarUriChanged)
	Q_PROPERTY(QDateTime lastUpdatedTime READ getLastUpdatedTime WRITE setLastUpdatedTime NOTIFY lastUpdatedTimeChanged)
	Q_PROPERTY(QString lastMessageText READ getLastMessageText NOTIFY lastMessageChanged)
	Q_PROPERTY(ChatMessageGui *lastMessage READ getLastMessage NOTIFY lastMessageChanged)
	Q_PROPERTY(LinphoneEnums::ChatMessageState lastMessageState READ getLastMessageState NOTIFY lastMessageChanged)
	Q_PROPERTY(LinphoneEnums::ChatRoomState state READ getChatRoomState NOTIFY chatRoomStateChanged)
	Q_PROPERTY(int unreadMessagesCount READ getUnreadMessagesCount WRITE setUnreadMessagesCount NOTIFY
	               unreadMessagesCountChanged)
	Q_PROPERTY(QString composingName READ getComposingName WRITE setComposingName NOTIFY composingUserChanged)
	Q_PROPERTY(QString composingAddress READ getComposingAddress WRITE setComposingAddress NOTIFY composingUserChanged)
	Q_PROPERTY(bool isGroupChat READ isGroupChat CONSTANT)
	Q_PROPERTY(bool isEncrypted READ isEncrypted CONSTANT)
	Q_PROPERTY(bool isReadOnly READ getIsReadOnly WRITE setIsReadOnly NOTIFY readOnlyChanged)
	Q_PROPERTY(bool isSecured READ isSecured WRITE setIsSecured NOTIFY isSecuredChanged)
	Q_PROPERTY(bool isBasic MEMBER mIsBasic CONSTANT)
	Q_PROPERTY(QString sendingText READ getSendingText WRITE setSendingText NOTIFY sendingTextChanged)
	Q_PROPERTY(bool ephemeralEnabled READ isEphemeralEnabled WRITE lEnableEphemeral NOTIFY ephemeralEnabledChanged)
	Q_PROPERTY(
	    int ephemeralLifetime READ getEphemeralLifetime WRITE lSetEphemeralLifetime NOTIFY ephemeralLifetimeChanged)
	Q_PROPERTY(bool muted READ isMuted WRITE lSetMuted NOTIFY mutedChanged)
	Q_PROPERTY(bool conferenceJoined MEMBER mConferenceJoined NOTIFY conferenceJoined)
	Q_PROPERTY(bool meAdmin READ getMeAdmin WRITE setMeAdmin NOTIFY meAdminChanged)
	Q_PROPERTY(QVariantList participants READ getParticipantsGui NOTIFY participantsChanged)
	Q_PROPERTY(QStringList participantsAddresses READ getParticipantsAddresses WRITE lSetParticipantsAddresses NOTIFY
	               participantsChanged)
	Q_PROPERTY(QList<QSharedPointer<ChatMessageContentCore>> fileList READ getFileList NOTIFY fileListChanged)

	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<ChatCore> create(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	ChatCore(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	~ChatCore();
	void setSelf(QSharedPointer<ChatCore> me);

	QDateTime getLastUpdatedTime() const;
	void setLastUpdatedTime(QDateTime time);

	QString getTitle() const;
	void setTitle(QString title);

	bool isGroupChat() const;

	bool isEncrypted() const;

	bool isMuted() const;

	bool isEphemeralEnabled() const;
	int getEphemeralLifetime() const;

	QString getIdentifier() const;

	QString getSendingText() const;
	void setSendingText(const QString &text);

	ChatMessageGui *getLastMessage() const;
	QString getLastMessageText() const;

	QList<QSharedPointer<ChatMessageContentCore>> getFileList() const;
	void resetFileList(QList<QSharedPointer<ChatMessageContentCore>> list);

	LinphoneEnums::ChatMessageState getLastMessageState() const;

	LinphoneEnums::ChatRoomState getChatRoomState() const;
	void setChatRoomState(LinphoneEnums::ChatRoomState state);

	bool getIsReadOnly() const;
	void setIsReadOnly(bool readOnly);

	QSharedPointer<ChatMessageCore> getLastMessageCore() const;
	void setLastMessage(QSharedPointer<ChatMessageCore> lastMessage);

	int getUnreadMessagesCount() const;
	void setUnreadMessagesCount(int count);

	QString getChatRoomAddress() const;
	QString getParticipantAddress() const;

	bool getMeAdmin() const;
	void setMeAdmin(bool admin);

	bool isSecured() const;
	void setIsSecured(bool secured);
	bool computeSecuredStatus() const;

	// void resetEventLogList(QList<QSharedPointer<EventLogCore>> list);
	// void appendEventLogToEventLogList(QSharedPointer<EventLogCore> event);
	// void appendEventLogsToEventLogList(QList<QSharedPointer<EventLogCore>> list);
	// void removeEventLogsFromEventLogList(QList<QSharedPointer<EventLogCore>> list);
	// void clearEventLogList();

	QString getAvatarUri() const;
	void setAvatarUri(QString avatarUri);

	QString getComposingName() const;
	QString getComposingAddress() const;
	void setComposingName(QString composingName);
	void setComposingAddress(QString composingAddress);

	std::shared_ptr<ChatModel> getModel() const;
	QSharedPointer<SafeConnection<ChatCore, ChatModel>> getChatModelConnection() const;

	void setParticipants(QList<QSharedPointer<ParticipantCore>> participants);
	QList<QSharedPointer<ParticipantCore>> buildParticipants(const std::shared_ptr<linphone::ChatRoom> &chatRoom) const;
	QList<QSharedPointer<ParticipantCore>> getParticipants() const;
	QVariantList getParticipantsGui() const;
	QStringList getParticipantsAddresses() const;

	QSharedPointer<AccountCore> getLocalAccount() const;

	void updateInfo(const std::shared_ptr<linphone::Friend> &updatedFriend, bool isRemoval = false);

signals:
	// used to close all the notifications when one is clicked
	void messageOpen();
	void lastUpdatedTimeChanged(QDateTime time);
	void lastMessageChanged();
	void titleChanged(QString title);
	void unreadMessagesCountChanged(int count);
	void eventListChanged();
	void eventListCleared();
	void eventsInserted(QList<QSharedPointer<EventLogCore>> list);
	void eventRemoved();
	void avatarUriChanged();
	void deleted();
	void composingUserChanged();
	void chatRoomStateChanged();
	void readOnlyChanged();
	void sendingTextChanged(QString text);
	void mutedChanged();
	void ephemeralEnabledChanged();
	void ephemeralLifetimeChanged();
	void meAdminChanged();
	void participantsChanged();
	void fileListChanged();
	void isSecuredChanged();
	void conferenceJoined();

	void lDeleteMessage(ChatMessageGui *message);
	void lDelete();
	void lDeleteHistory();
	void lMarkAsRead();
	void lUpdateLastMessage();
	void lUpdateUnreadCount();
	void lUpdateLastUpdatedTime();
	void lSendTextMessage(QString message);
	void lSendMessage(QString message, QVariantList files);
	void lSendVoiceMessage();
	void lCompose();
	void lLeave();
	void lSetMuted(bool muted);
	void lEnableEphemeral(bool enable);
	void lSetEphemeralLifetime(int time);
	void lSetSubject(QString subject);
	void lRemoveParticipantAtIndex(int index);
	void lSetParticipantsAddresses(QStringList addresses);
	void lToggleParticipantAdminStatusAtIndex(int index);

private:
	QString id;
	QDateTime mLastUpdatedTime;
	QString mParticipantAddress;
	QString mChatRoomAddress;
	QString mTitle;
	QString mIdentifier;
	QString mAvatarUri;
	QString mSendingText;
	int mUnreadMessagesCount;
	QString mComposingName;
	QString mComposingAddress;
	bool mIsGroupChat = false;
	bool mIsEncrypted = false;
	bool mIsReadOnly = false;
	bool mEphemeralEnabled = false;
	// ChatRoom is secured if all its participants are
	// EndToEndEncryptedAndVerified friends
	bool mIsSecured = false;
	bool mIsBasic = false;
	int mEphemeralLifetime = 0;
	QList<QSharedPointer<ChatMessageContentCore>> mFileList;
	bool mIsMuted = false;
	bool mMeAdmin = false;
	bool mConferenceJoined = false;
	QList<QSharedPointer<ParticipantCore>> mParticipants;
	LinphoneEnums::ChatRoomState mChatRoomState;
	std::shared_ptr<ChatModel> mChatModel;
	QSharedPointer<ChatMessageCore> mLastMessage;
	QSharedPointer<AccountCore> mLocalAccount;
	std::shared_ptr<FriendModel> mFriendModel;
	QSharedPointer<SafeConnection<ChatCore, ChatModel>> mChatModelConnection;
	QSharedPointer<SafeConnection<ChatCore, CoreModel>> mCoreModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(ChatCore *)
#endif
