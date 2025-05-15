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

#include "core/chat/message/ChatMessageGui.hpp"
#include "model/chat/ChatModel.hpp"
#include "model/search/MagicSearchModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class ChatCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	Q_PROPERTY(QString title READ getTitle WRITE setTitle NOTIFY titleChanged)
	Q_PROPERTY(QString identifier READ getIdentifier CONSTANT)
	Q_PROPERTY(QString peerAddress READ getPeerAddress CONSTANT)
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

	QString getIdentifier() const;

	ChatMessageGui *getLastMessage() const;
	QString getLastMessageText() const;

	LinphoneEnums::ChatMessageState getLastMessageState() const;

	LinphoneEnums::ChatRoomState getChatRoomState() const;
	void setChatRoomState(LinphoneEnums::ChatRoomState state);

	QSharedPointer<ChatMessageCore> getLastMessageCore() const;
	void setLastMessage(QSharedPointer<ChatMessageCore> lastMessage);

	int getUnreadMessagesCount() const;
	void setUnreadMessagesCount(int count);

	QString getChatRoomAddress() const;
	QString getPeerAddress() const;

	QList<QSharedPointer<ChatMessageCore>> getChatMessageList() const;
	void resetChatMessageList(QList<QSharedPointer<ChatMessageCore>> list);
	void appendMessageToMessageList(QSharedPointer<ChatMessageCore> message);
	void appendMessagesToMessageList(QList<QSharedPointer<ChatMessageCore>> list);
	void removeMessagesFromMessageList(QList<QSharedPointer<ChatMessageCore>> list);
	void clearMessagesList();

	QString getAvatarUri() const;
	void setAvatarUri(QString avatarUri);

	QString getComposingName() const;
	QString getComposingAddress() const;
	void setComposingName(QString composingName);
	void setComposingAddress(QString composingAddress);

	std::shared_ptr<ChatModel> getModel() const;

signals:
	// used to close all the notifications when one is clicked
	void messageOpen();
	void lastUpdatedTimeChanged(QDateTime time);
	void lastMessageChanged();
	void titleChanged(QString title);
	void unreadMessagesCountChanged(int count);
	void messageListChanged();
	void messagesInserted(QList<QSharedPointer<ChatMessageCore>> list);
	void messageRemoved();
	void avatarUriChanged();
	void deleted();
	void composingUserChanged();
	void chatRoomStateChanged();

	void lDeleteMessage();
	void lDelete();
	void lDeleteHistory();
	void lMarkAsRead();
	void lUpdateLastMessage();
	void lUpdateUnreadCount();
	void lUpdateLastUpdatedTime();
	void lSendTextMessage(QString message);
	void lCompose();

private:
	QString id;
	QDateTime mLastUpdatedTime;
	QString mPeerAddress;
	QString mChatRoomAddress;
	QString mTitle;
	QString mIdentifier;
	QString mAvatarUri;
	int mUnreadMessagesCount;
	QString mComposingName;
	QString mComposingAddress;
	bool mIsGroupChat = false;
	LinphoneEnums::ChatRoomState mChatRoomState;
	std::shared_ptr<ChatModel> mChatModel;
	QSharedPointer<ChatMessageCore> mLastMessage;
	QList<QSharedPointer<ChatMessageCore>> mChatMessageList;
	QSharedPointer<SafeConnection<ChatCore, ChatModel>> mChatModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(ChatCore *)
#endif
