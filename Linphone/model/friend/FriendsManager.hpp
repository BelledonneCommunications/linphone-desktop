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

#ifndef FRIENDS_MANAGER_H_
#define FRIENDS_MANAGER_H_

#include <QObject>
#include <QSharedPointer>
#include <QThread>
#include <QVariantMap>
#include <linphone++/linphone.hh>
#include "tool/AbstractObject.hpp"

class FriendsManager : public QObject, public AbstractObject {
	Q_OBJECT

public:
	FriendsManager(QObject *parent);
	~FriendsManager();
	static std::shared_ptr<FriendsManager> create(QObject *parent);
	static std::shared_ptr<FriendsManager> getInstance();

	QVariantMap getKnownFriends() const;
	QVariantMap getUnknownFriends() const;
	QStringList getOtherAddresses() const;

	std::shared_ptr<linphone::Friend> getKnownFriendAtKey(const QString& key);
	std::shared_ptr<linphone::Friend> getUnknownFriendAtKey(const QString& key);

	bool isInKnownFriends(const QString& key);
	bool isInUnknownFriends(const QString& key);
	bool isInOtherAddresses(const QString& key);

	void appendKnownFriend(std::shared_ptr<linphone::Address> address, std::shared_ptr<linphone::Friend> f);
	void appendUnknownFriend(std::shared_ptr<linphone::Address> address, std::shared_ptr<linphone::Friend> f);
	void appendOtherAddress(QString address);

	void removeUnknownFriend(const QString& key);
	void removeOtherAddress(const QString& key);

private:
	static std::shared_ptr<FriendsManager> gFriendsManager;
	QVariantMap mKnownFriends;
	QVariantMap mUnknownFriends;
	QStringList mOtherAddresses;
	DECLARE_ABSTRACT_OBJECT
};

#endif
