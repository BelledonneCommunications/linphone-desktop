/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef CHAT_EVENT_H
#define CHAT_EVENT_H

#include "components/chat-room/ChatRoomModel.hpp"

// =============================================================================


class ChatEvent : public QObject{	
Q_OBJECT
public:
	ChatEvent (ChatRoomModel::EntryType type, QObject * parent = nullptr);
	virtual ~ChatEvent();
	ChatRoomModel::EntryType mType;
	
	virtual QDateTime  getTimestamp() const;
	virtual void setTimestamp(const QDateTime& timestamp = QDateTime::currentDateTime());
	
	virtual void deleteEvent();
	
protected: 
	QDateTime mTimestamp;
};
Q_DECLARE_METATYPE(ChatEvent*)
#endif
