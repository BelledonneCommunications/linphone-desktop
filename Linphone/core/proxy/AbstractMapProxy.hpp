/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#ifndef ABSTRACT_MAP_PROXY_H_
#define ABSTRACT_MAP_PROXY_H_

#include <QDebug>

#include "Proxy.hpp"

template <class X, class Y>
class AbstractMapProxy : public Proxy {
public:
	AbstractMapProxy(QObject *parent = Q_NULLPTR) : Proxy(parent) {
	}

	virtual ~AbstractMapProxy() {
		clearData();
	}

	virtual int rowCount(const QModelIndex &index = QModelIndex()) const override {
		return mMappedList.count();
	}

	virtual QHash<int, QByteArray> roleNames() const override {
		QHash<int, QByteArray> roles;
		roles[Qt::DisplayRole] = "$modelData";
		roles[Qt::DisplayRole + 1] = "$modelKey";
		return roles;
	}

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
		int row = index.row();
		auto it = mMappedList.begin() + row;
		if (role == Qt::DisplayRole) return QVariant::fromValue(*it);
		else if (role == Qt::DisplayRole + 1) return QVariant::fromValue(it.key());

		return QVariant();
	}

	virtual void clearData() override {
		mMappedList.clear();
	}

protected:
	QMap<X, Y> mMappedList;
};

#endif
