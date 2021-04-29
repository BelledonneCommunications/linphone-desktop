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

class ChatModel;

class TimelineModel : public QObject {
  Q_OBJECT

public:
	TimelineModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject *parent = Q_NULLPTR);
	
	Q_PROPERTY(QString fullPeerAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString fullLocalAddress READ getFullLocalAddress NOTIFY fullLocalAddressChanged)
	Q_PROPERTY(std::shared_ptr<ChatModel> chatRoom READ getChatRoom CONSTANT)
	
// Contact
	Q_PROPERTY(QString sipAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString username READ getUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString avatar READ getAvatar NOTIFY avatarChanged)
	Q_PROPERTY(int presenceStatus READ getPresenceStatus NOTIFY presenceStatusChanged)
	
	
	QString getFullPeerAddress() const;
	QString getFullLocalAddress() const;
	
	QString getUsername() const;
	QString getAvatar() const;
	int getPresenceStatus() const;
	
	
	std::shared_ptr<ChatModel> getChatRoom() const;

	QDateTime mTimestamp;
	std::shared_ptr<ChatModel> mChatModel;
	//std::shared_ptr<linphone::ChatRoom> mChatRoom;

signals:
	void fullPeerAddressChanged();
	void fullLocalAddressChanged();
	void usernameChanged();
	void avatarChanged();
	void presenceStatusChanged();
  
};

#endif // TIMELINE_MODEL_H_
