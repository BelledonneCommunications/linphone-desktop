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

#ifndef CARDDAV_LIST_H_
#define CARDDAV_LIST_H_

#include "../../proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QLocale>

class CarddavCore;
class CoreModel;
// =============================================================================

class CarddavList : public ListProxy, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<CarddavList> create();
	// Create a CarddavCore and make connections to List.
	QSharedPointer<CarddavCore> createCarddavCore(const std::shared_ptr<linphone::FriendList> &carddavFriendList);
	CarddavList(QObject *parent = Q_NULLPTR);
	~CarddavList();

	void setSelf(QSharedPointer<CarddavList> me);

	void removeAllEntries();
	void remove(const int &row);

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void lUpdate();

private:
	QSharedPointer<SafeConnection<CarddavList, CoreModel>> mModelConnection;
	DECLARE_ABSTRACT_OBJECT
};

#endif
