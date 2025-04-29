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

#ifndef CHATMESSAGECORE_H_
#define CHATMESSAGECORE_H_

#include "model/chat/message/ChatMessageModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>

#include <linphone++/linphone.hh>

class ChatMessageCore : public QObject, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(QDateTime timestamp READ getTimestamp WRITE setTimestamp NOTIFY timestampChanged)
	Q_PROPERTY(QString text READ getText WRITE setText NOTIFY textChanged)
	Q_PROPERTY(QString peerAddress READ getPeerAddress CONSTANT)
	Q_PROPERTY(QString peerName READ getPeerName CONSTANT)
	Q_PROPERTY(bool isRemoteMessage READ isRemoteMessage WRITE setIsRemoteMessage NOTIFY isRemoteMessageChanged)

public:
	static QSharedPointer<ChatMessageCore> create(const std::shared_ptr<linphone::ChatMessage> &chatmessage);
	ChatMessageCore(const std::shared_ptr<linphone::ChatMessage> &chatmessage);
	~ChatMessageCore();
	void setSelf(QSharedPointer<ChatMessageCore> me);

	QDateTime getTimestamp() const;
	void setTimestamp(QDateTime timestamp);

	QString getText() const;
	void setText(QString text);

	QString getPeerAddress() const;
	QString getPeerName() const;

	bool isRemoteMessage() const;
	void setIsRemoteMessage(bool isRemote);

signals:
	void timestampChanged(QDateTime timestamp);
	void textChanged(QString text);
	void isRemoteMessageChanged(bool isRemote);

private:
	DECLARE_ABSTRACT_OBJECT
	QString mText;
	QString mPeerAddress;
	QString mPeerName;
	QDateTime mTimestamp;
	bool mIsRemoteMessage = false;
	std::shared_ptr<ChatMessageModel> mChatMessageModel;
	QSharedPointer<SafeConnection<ChatMessageCore, ChatMessageModel>> mChatMessageModelConnection;
};

#endif // CHATMESSAGECORE_H_
