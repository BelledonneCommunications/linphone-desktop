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

#ifndef CARDDAV_MODEL_H_
#define CARDDAV_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"
#include <QObject>
#include <linphone++/linphone.hh>

class CarddavModel : public ::Listener<linphone::FriendList, linphone::FriendListListener>,
                     public linphone::FriendListListener,
                     public AbstractObject {
	Q_OBJECT
public:
	static std::shared_ptr<CarddavModel> create(const std::shared_ptr<linphone::FriendList> &carddavFriendList,
	                                            QObject *parent = nullptr);
	CarddavModel(const std::shared_ptr<linphone::FriendList> &carddavFriendList, QObject *parent = nullptr);
	~CarddavModel();

	void save(std::string displayName, std::string uri, std::string username, std::string password, std::string realm, bool storeNewFriendsInIt);
	void remove();
	bool storeNewFriendsInIt();

signals:
	void saved(bool success);
	void removed();

private:
	bool mStoreNewFriendsInIt;
	std::shared_ptr<linphone::FriendList> mCarddavFriendList;
	std::shared_ptr<const linphone::AuthInfo> mRemovedAuthInfo;
	std::shared_ptr<linphone::AuthInfo> mCreatedAuthInfo;

	DECLARE_ABSTRACT_OBJECT

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onSyncStatusChanged(const std::shared_ptr<linphone::FriendList> &friendList,
	                                 linphone::FriendList::SyncStatus status,
	                                 const std::string &message) override;
};

#endif
