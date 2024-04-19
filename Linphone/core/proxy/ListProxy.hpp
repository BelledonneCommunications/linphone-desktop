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

#ifndef _LIST_PROXY_H_
#define _LIST_PROXY_H_

#include "AbstractListProxy.hpp"
#include "tool/Utils.hpp"
#include <QSharedPointer>

// =============================================================================

class ListProxy : public AbstractListProxy<QSharedPointer<QObject>> {
	Q_OBJECT

public:
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)
	ListProxy(QObject *parent = Q_NULLPTR);
	virtual ~ListProxy();

	template <class T>
	QSharedPointer<T> getAt(const int &index) const {
		return AbstractListProxy<QSharedPointer<QObject>>::getAt(index).objectCast<T>();
	}

	QSharedPointer<QObject> get(QObject *itemToGet, int *index = nullptr) const;

	template <class T>
	QList<QSharedPointer<T>> getSharedList() {
		QList<QSharedPointer<T>> newList;
		for (auto item : mList)
			newList << item.objectCast<T>();
		return newList;
	}
	// Add functions
	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
		int row = index.row();
		if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
		if (role == Qt::DisplayRole) return QVariant::fromValue(mList[row].get());
		return QVariant();
	}
	template <class T>
	void add(QSharedPointer<T> item) {
		AbstractListProxy<QSharedPointer<QObject>>::add(item.template objectCast<QObject>());
	}

	template <class T>
	void add(QList<QSharedPointer<T>> items) {
		if (items.size() > 0) {
			QModelIndex firstIndex = mList.size() > 0 ? index(mList.size() - 1, 0) : index(0, 0);
			beginInsertRows(QModelIndex(), mList.size(), mList.size() + items.size() - 1);
			for (auto i : items)
				mList << i.template objectCast<QObject>();
			endInsertRows();
			auto lastIndex = index(mList.size() - 1, 0);
			emit dataChanged(firstIndex, lastIndex);
		}
	}

	template <class T>
	void prepend(QSharedPointer<T> item) {
		AbstractListProxy<QSharedPointer<QObject>>::prepend(item.template objectCast<QObject>());
	}

	template <class T>
	void prepend(QList<QSharedPointer<T>> items) {
		if (items.size() > 0) {
			beginInsertRows(QModelIndex(), 0, items.size() - 1);
			items << mList;
			mList = items;
			endInsertRows();
			emit dataChanged(index(0), index(items.size() - 1));
		}
	}

	virtual bool remove(QObject *itemToRemove) override {
		bool removed = false;
		if (itemToRemove) {
			lInfo() << QStringLiteral("Removing ") << itemToRemove->metaObject()->className() << QStringLiteral(" : ")
			        << itemToRemove;
			int index = 0;
			for (auto item : mList)
				if (item == itemToRemove) {
					removed = removeRow(index);
					break;
				} else ++index;
			if (!removed)
				qWarning() << QStringLiteral("Unable to remove ") << itemToRemove->metaObject()->className()
				           << QStringLiteral(" : ") << itemToRemove;
		}
		return removed;
	}
	virtual bool remove(QSharedPointer<QObject> itemToRemove) {
		return remove(itemToRemove.get());
	}
};

#endif
