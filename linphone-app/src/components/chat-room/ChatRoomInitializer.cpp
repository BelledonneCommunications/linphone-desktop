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
#include <QDebug>

#include "ChatRoomListener.hpp"
#include "components/core/CoreManager.hpp"
#include "components/core/CoreHandlers.hpp"

// =============================================================================

void ChatRoomInitializer::connectTo(ChatRoomListener * listener){
	connect(listener, &ChatRoomListener::conferenceJoined, this, &ChatRoomInitializer::onConferenceJoined);
	connect(listener, &ChatRoomListener::stateChanged, this, &ChatRoomInitializer::onStateChanged);
}

// =============================================================================

ChatRoomInitializer::ChatRoomInitializer(std::shared_ptr<linphone::ChatRoom> chatRoom){
	mChatRoomListener = std::make_shared<ChatRoomListener>();
	connectTo(mChatRoomListener.get());
	if( chatRoom){
		mChatRoom = chatRoom;
		mChatRoom->addListener(mChatRoomListener);
	}
}
ChatRoomInitializer::~ChatRoomInitializer(){
	if(mChatRoom)
		mChatRoom->removeListener(mChatRoomListener);
}

QSharedPointer<ChatRoomInitializer> ChatRoomInitializer::create(std::shared_ptr<linphone::ChatRoom> chatRoom){
	QSharedPointer<ChatRoomInitializer> initializer = QSharedPointer<ChatRoomInitializer>::create(chatRoom);
	return initializer;
}



void ChatRoomInitializer::setAdminsData(QList< std::shared_ptr<linphone::Address>> admins){
	mAdmins = admins;
	mAdminsSet = false;
}

void ChatRoomInitializer::setAdmins(QList< std::shared_ptr<linphone::Address>> admins){
	if( admins.size() > 0) {
		std::list<std::shared_ptr<linphone::Participant>> participants = mChatRoom->getParticipants();
		int count = 0;
		for(auto participant : participants){
			auto address = participant->getAddress();
			auto isAdmin = std::find_if(admins.begin(), admins.end(), [address](std::shared_ptr<linphone::Address> addr){
					return addr->weakEqual(address);
			});
			if( isAdmin != admins.end()){
				++count;
				mChatRoom->setParticipantAdminStatus(participant, true);
			}
		}
		mAdminsSet = true;
		qInfo() << "[ChatRoomInitializer] '" << admins.size() << "' admin(s) specified in addition of Me, " << count << " set.";
		checkInitialization();
	}
}

void ChatRoomInitializer::start(QSharedPointer<ChatRoomInitializer> initializer){
	QObject * context = new QObject();
	QObject::connect(initializer.get(), &ChatRoomInitializer::finished, context, [context, initializer](LinphoneEnums::ChatRoomState state){
		qDebug() << "[ChatRoomInitializer] initialized";
		context->deleteLater();// This will destroy context and initializer
	});
}

void ChatRoomInitializer::checkInitialization(){
	if( mAdmins.size() > 0 && !mAdminsSet)
		return;
		
	emit finished(LinphoneEnums::fromLinphone(mChatRoom->getState()));
}

void ChatRoomInitializer::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	qDebug() << "[ChatRoomInitializer] Conference has been set";
	setAdmins(mAdmins);
}

void ChatRoomInitializer::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState) {
	qDebug() << "[ChatRoomInitializer] State : " << (int)newState;
	if( newState >= linphone::ChatRoom::State::Created || newState == linphone::ChatRoom::State::Instantiated) {
		checkInitialization();
	}
}