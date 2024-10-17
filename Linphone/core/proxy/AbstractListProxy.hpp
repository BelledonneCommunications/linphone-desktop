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

#ifndef ABSTRACT_LIST_PROXY_H_
#define ABSTRACT_LIST_PROXY_H_

#include <QAbstractListModel>
#include <QDebug>

#include "Proxy.hpp"

template <class T>
class AbstractListProxy : public Proxy {
public:
	AbstractListProxy(QObject *parent = Q_NULLPTR) : Proxy(parent) {
	}

	virtual ~AbstractListProxy() {
		clearData();
	}

	virtual int rowCount(const QModelIndex &index = QModelIndex()) const override {
		return mList.size();
	}

	virtual QHash<int, QByteArray> roleNames() const override {
		QHash<int, QByteArray> roles;
		roles[Qt::DisplayRole] = "$modelData";
		return roles;
	}

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
		int row = index.row();
		if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
		else if (role == Qt::DisplayRole) return QVariant::fromValue(mList[row]);
		else return QVariant();
	}

	virtual T getAt(const int &index) const {
		if (index < 0 || index >= mList.count()) return T();
		else return mList[index];
	}

	// Add functions
	virtual void add(T item) {
		int row = rowCount();
		beginInsertRows(QModelIndex(), row, row);
		mList << item;
		endInsertRows();
		// Snippet in case of not refreshing beside begin/end
		// auto lastIndex = index(mList.size() - 1, 0);
		// emit dataChanged(lastIndex, lastIndex);
	}
	virtual void add(QList<T> items) {
		int count = items.size();
		if (count > 0) {
			int currentCount = rowCount();
			int newCount = mList.size() + count;
			beginInsertRows(QModelIndex(), currentCount, newCount - 1);
			mList << items;
			endInsertRows();
			// Snippet in case of not refreshing beside begin/end
			// QModelIndex firstIndex = currentCount > 0 ? index(currentCount - 1, 0) : index(0, 0);
			// auto lastIndex = index(newCount - 1, 0);
			// emit dataChanged(firstIndex, lastIndex);
		}
	}

	virtual void prepend(T item) {
		int currentCount = rowCount();
		beginInsertRows(QModelIndex(), 0, 0);
		mList.prepend(item);
		endInsertRows();
		// Snippet in case of not refreshing beside begin/end
		// emit dataChanged(index(0), index(0));
	}

	virtual void prepend(QList<T> items) {
		int count = items.size();
		if (count > 0) {
			int currentCount = rowCount();
			int newCount = currentCount + count;
			beginInsertRows(QModelIndex(), 0, items.size() - 1);
			items << mList;
			mList = items;
			endInsertRows();
			// Snippet in case of not refreshing beside begin/end
			// emit dataChanged(index(0), index(items.size() - 1));
		}
	}

	// Remove functions
	virtual bool removeRow(int row, const QModelIndex &parent = QModelIndex()) {
		return removeRows(row, 1, parent);
	}
	virtual bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override {
		int limit = row + count - 1;
		if (row < 0 || count < 0 || limit >= mList.count()) return false;
		beginRemoveRows(parent, row, limit);
		for (int i = 0; i < count; ++i)
			mList.takeAt(row);
		endRemoveRows();
		// Snippet in case of not refreshing beside begin/end (TODO: check crashs, empty list?)
		// emit dataChanged(index(row), index(limit));
		return true;
	}

	virtual void clearData() override {
		mList.clear();
	}

	virtual void resetData(QList<T> newData = QList<T>()) {
		beginResetModel();
		mList = newData;
		endResetModel();
	}

protected:
	QList<T> mList;
};

#endif
