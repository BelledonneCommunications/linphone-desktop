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

#ifndef CHAT_ROOM_INITIALIZER_H_
#define CHAT_ROOM_INITIALIZER_H_

// Update Admin. We need this hack in order to set parameters without touching on ChatRoom from createChatRoom.
// If something protect the return ChatRoom (like with shared pointer), the future behaviour will be unstable (2 internal instances, wrong ChatRoom objects from callbacks and crash on deletion)
// Thus, we cannot bind to ChatRoom callbacks at the moment of creation and we need to wait for onChatRoomStateChanged from Core Listener and then, react to linphone::ChatRoom::State::Created from the new ChatRoom.
// As we cannot compare exactly the right ChatRoom, we test on subject and parameters that should be enough to be unique at the moment of the creation. 
// This is not a 100% (we may protect with a one-time creation) but this workaround should be enough.

// Used on Core::createChatRoom()

#include <linphone++/linphone.hh>

#include <QList>

// =============================================================================


class ChatRoomInitializer : public linphone::ChatRoomListener{
public:
	ChatRoomInitializer();
	~ChatRoomInitializer();
	QList< std::shared_ptr<linphone::Address>> mAdmins;
	std::shared_ptr<ChatRoomInitializer> mSelf;

	virtual void onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) override;
	
	// Sync : Set Admins to chat room without binding anything (eg. do not wait for any callback and use ChatRoom directly)
	static void setAdminsSync(const std::shared_ptr<linphone::ChatRoom> & chatRoom, QList< std::shared_ptr<linphone::Address>> admins);
	
	// Async : Bind to core for onChatRoomStateChanged event and then wait of linphone::ChatRoom::State::Created from ChatRoom listener.
	static void setAdminsAsync(const std::string& subject, const linphone::ChatRoomBackend& backend, const bool& groupEnabled, QList< std::shared_ptr<linphone::Address>> admins);
};
#endif
