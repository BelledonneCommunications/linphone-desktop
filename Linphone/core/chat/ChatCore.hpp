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

#include "core/chat/message/ChatMessageCore.hpp"
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
	Q_PROPERTY(QString peerAddress READ getPeerAddress WRITE setPeerAddress NOTIFY peerAddressChanged)
	Q_PROPERTY(QString avatarUri READ getAvatarUri WRITE setAvatarUri NOTIFY avatarUriChanged)
	Q_PROPERTY(QDateTime lastUpdatedTime READ getLastUpdatedTime WRITE setLastUpdatedTime NOTIFY lastUpdatedTimeChanged)
	Q_PROPERTY(QString lastMessageInHistory READ getLastMessageInHistory WRITE setLastMessageInHistory NOTIFY
	               lastMessageInHistoryChanged)
	Q_PROPERTY(int unreadMessagesCount READ getUnreadMessagesCount WRITE setUnreadMessagesCount NOTIFY
	               unreadMessagesCountChanged)
	// Q_PROPERTY(VideoStats videoStats READ getVideoStats WRITE setVideoStats NOTIFY videoStatsChanged)

	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<ChatCore> create(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	ChatCore(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	~ChatCore();
	void setSelf(QSharedPointer<ChatCore> me);

	QDateTime getLastUpdatedTime() const;
	void setLastUpdatedTime(QDateTime time);

	QString getTitle() const;
	void setTitle(QString title);

	QString getIdentifier() const;

	QString getLastMessageInHistory() const;
	void setLastMessageInHistory(QString message);

	int getUnreadMessagesCount() const;
	void setUnreadMessagesCount(int count);

	QString getPeerAddress() const;
	void setPeerAddress(QString peerAddress);

	QList<QSharedPointer<ChatMessageCore>> getChatMessageList() const;
	void resetChatMessageList(QList<QSharedPointer<ChatMessageCore>> list);
	void appendMessagesToMessageList(QList<QSharedPointer<ChatMessageCore>> list);
	void removeMessagesFromMessageList(QList<QSharedPointer<ChatMessageCore>> list);

	QString getAvatarUri() const;
	void setAvatarUri(QString avatarUri);

	std::shared_ptr<ChatModel> getModel() const;

signals:
	void lastUpdatedTimeChanged(QDateTime time);
	void lastMessageInHistoryChanged(QString time);
	void titleChanged(QString title);
	void peerAddressChanged(QString address);
	void unreadMessagesCountChanged(int count);
	void messageListChanged();
	void avatarUriChanged();

private:
	QString id;
	QDateTime mLastUpdatedTime;
	QString mLastMessageInHistory;
	QString mPeerAddress;
	QString mTitle;
	QString mIdentifier;
	QString mAvatarUri;
	int mUnreadMessagesCount;
	std::shared_ptr<ChatModel> mChatModel;
	QList<QSharedPointer<ChatMessageCore>> mChatMessageList;
	QSharedPointer<SafeConnection<ChatCore, ChatModel>> mChatModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(ChatCore *)
#endif
