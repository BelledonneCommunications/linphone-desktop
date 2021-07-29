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

#include "ChatRoomInitializer.hpp"

#include <QObject>

#include "components/core/CoreManager.hpp"
#include "components/core/CoreHandlers.hpp"

// =============================================================================

ChatRoomInitializer::ChatRoomInitializer(){}
ChatRoomInitializer::~ChatRoomInitializer(){}

void ChatRoomInitializer::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	if(mAdmins.size() > 0){
		setAdminsSync(chatRoom, mAdmins);
	}
	chatRoom->removeListener(mSelf);
	mSelf = nullptr;
}

void ChatRoomInitializer::setAdminsSync(const std::shared_ptr<linphone::ChatRoom> & chatRoom, QList< std::shared_ptr<linphone::Address>> admins){
	std::list<std::shared_ptr<linphone::Participant>> chatRoomParticipants = chatRoom->getParticipants();
	for(auto participant : chatRoomParticipants){
		auto address = participant->getAddress();
		auto isAdmin = std::find_if(admins.begin(), admins.end(), [address](std::shared_ptr<linphone::Address> addr){
				return addr->weakEqual(address);
	});
		if( isAdmin != admins.end()){
			chatRoom->setParticipantAdminStatus(participant, true);
		}
	}
}

void ChatRoomInitializer::setAdminsAsync(const std::string& subject, const linphone::ChatRoomBackend& backend, const bool& groupEnabled, QList< std::shared_ptr<linphone::Address>> admins){
	QObject * context = new QObject();
	QObject::connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::chatRoomStateChanged,
					 context,[context, admins, subject, backend, groupEnabled](const std::shared_ptr<linphone::ChatRoom> &chatRoomEvent,linphone::ChatRoom::State state){
		auto params = chatRoomEvent->getCurrentParams();
		if( subject == chatRoomEvent->getSubject() && backend == params->getBackend() && groupEnabled == params->groupEnabled()){
			if( state == linphone::ChatRoom::State::Created){
				std::shared_ptr<ChatRoomInitializer> init = std::make_shared<ChatRoomInitializer>();
				init->mAdmins = admins;
				init->mSelf = init;
				chatRoomEvent->addListener(init);
				delete context;
			}else if( state >  linphone::ChatRoom::State::Created){// The chat room could be completed. Delete the bind.
				delete context;
			}
		}
	});
}
