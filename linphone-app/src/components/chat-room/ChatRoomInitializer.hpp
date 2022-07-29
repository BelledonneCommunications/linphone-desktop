/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#ifndef CHAT_ROOM_INITIALIZER_H_
#define CHAT_ROOM_INITIALIZER_H_


#include <linphone++/linphone.hh>
#include "ChatRoomInitializer.hpp"


#include <QList>

#include <QObject>
// =============================================================================

class ChatRoomListener;

class ChatRoomInitializer : public QObject{
Q_OBJECT
public:
	ChatRoomInitializer(std::shared_ptr<linphone::ChatRoom> chatRoom);
	~ChatRoomInitializer();
//				DATA to set
	QList< std::shared_ptr<linphone::Address>> mAdmins;
	bool mAdminsSet = false;
	
	static QSharedPointer<ChatRoomInitializer> create(std::shared_ptr<linphone::ChatRoom> chatRoom); // Return a shared pointer to pass to start function (if delayed creation is needed)
	
	void setAdminsData(QList< std::shared_ptr<linphone::Address>> admins);// Call it to initialize admins for delayed creation.
	void setAdmins(QList< std::shared_ptr<linphone::Address>> admins);// set admins directly in chat room from list
		
	static void start(QSharedPointer<ChatRoomInitializer> initializer);// Keep a ref and remove it when initialization is finished.
	
// Linphone callbacks
	virtual void onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog);
	virtual void onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState);
	
signals:
	void finished(int state);	// this signal is emit before deletion and give the current linphone::ChatRoom:State of the chat room.
	
private:
	void connectTo(ChatRoomListener * listener);
	
	void checkInitialization();// Will send finished() if all are done
	
	std::shared_ptr<linphone::ChatRoom> mChatRoom;
	std::shared_ptr<ChatRoomListener> mChatRoomListener;	// This need to be a shared_ptr because of adding it to linphone
};
#endif
