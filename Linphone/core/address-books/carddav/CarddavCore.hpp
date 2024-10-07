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

#ifndef CARDDAV_CORE_H_
#define CARDDAV_CORE_H_

#include "model/address-books/carddav/CarddavModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class CarddavCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<CarddavCore> create(const std::shared_ptr<linphone::FriendList> &carddavFriendList);
	CarddavCore(const std::shared_ptr<linphone::FriendList> &carddavFriendList);
	~CarddavCore();

	void setSelf(QSharedPointer<CarddavCore> me);

	Q_INVOKABLE void remove();
	Q_INVOKABLE void save();
	Q_INVOKABLE bool isValid();

	DECLARE_CORE_MEMBER(QString, displayName, DisplayName)
	DECLARE_CORE_MEMBER(QString, uri, Uri)
	DECLARE_CORE_MEMBER(QString, username, Username)
	DECLARE_CORE_MEMBER(QString, password, Password)
	DECLARE_CORE_MEMBER(QString, realm, Realm)
	DECLARE_CORE_MEMBER(bool, storeNewFriendsInIt, StoreNewFriendsInIt)

signals:
	void saved(bool success);

private:
	std::shared_ptr<CarddavModel> mCarddavModel;
	QSharedPointer<SafeConnection<CarddavCore, CarddavModel>> mCarddavModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(CarddavCore *)
#endif
