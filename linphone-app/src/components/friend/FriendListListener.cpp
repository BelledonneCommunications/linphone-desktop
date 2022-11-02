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

#include "FriendListListener.hpp"
#include "../../utils/Utils.hpp"

#include <QDebug>

// =============================================================================

FriendListListener::FriendListListener(QObject *parent) : QObject(parent) {
}

//--------------------------------------------------------------------
void FriendListListener::onContactCreated(const std::shared_ptr<linphone::FriendList> & friendList, const std::shared_ptr<linphone::Friend> & linphoneFriend) {
	qDebug() << "onContactCreated: " << Utils::coreStringToAppString(linphoneFriend->getName());
	emit contactCreated(linphoneFriend);
}
void FriendListListener::onContactDeleted(const std::shared_ptr<linphone::FriendList> & friendList, const std::shared_ptr<linphone::Friend> & linphoneFriend) {
	qDebug() << "onContactDeleted: " << Utils::coreStringToAppString(linphoneFriend->getName());
	emit contactDeleted(linphoneFriend);
}
void FriendListListener::onContactUpdated(const std::shared_ptr<linphone::FriendList> & friendList, const std::shared_ptr<linphone::Friend> & newFriend, const std::shared_ptr<linphone::Friend> & oldFriend) {
	qDebug() << "onContactUpdated: " << Utils::coreStringToAppString(newFriend->getName());
	emit contactUpdated(newFriend, oldFriend);
}
void FriendListListener::onSyncStatusChanged(const std::shared_ptr<linphone::FriendList> & friendList, linphone::FriendList::SyncStatus status, const std::string & message) {
	qDebug() << "onSyncStatusChanged: [" << (int)status<<"] " << Utils::coreStringToAppString(message);
	emit syncStatusChanged(status, message);
}
void FriendListListener::onPresenceReceived(const std::shared_ptr<linphone::FriendList> & friendList, const std::list<std::shared_ptr<linphone::Friend>> & friends) {
	qDebug() << "onPresenceReceived: " <<friends.size();
	emit presenceReceived(friends);
}