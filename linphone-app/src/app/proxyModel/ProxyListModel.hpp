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

#ifndef _PROXY_LIST_MODEL_H_
#define _PROXY_LIST_MODEL_H_


#include <QAbstractListModel>
#include <QSharedPointer>

// =============================================================================

class ProxyListModel : public QAbstractListModel {
	Q_OBJECT
	
public:
	ProxyListModel (QObject *parent = Q_NULLPTR);
	
	virtual int rowCount (const QModelIndex &index = QModelIndex()) const override;
	
	virtual QHash<int, QByteArray> roleNames () const override;
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	QSharedPointer<QObject> getAt(const int& index) const;
	
	template <class T>
	QList<QSharedPointer<T>> getSharedList(){
		QList<QSharedPointer<T>> newList;
		for(auto item : mList)
			newList << item.objectCast<T>();
		return newList;
	}
// Add functions
	virtual void add(QSharedPointer<QObject> item);
	template <class T>
	void add(QSharedPointer<T> item){
		add(item.template objectCast<QObject>());
	}
	//virtual void add(QList<QSharedPointer<QObject>> item);
	
	virtual void prepend(QSharedPointer<QObject> item);
	template <class T>
	void prepend(QSharedPointer<T> item){
		prepend(item.template objectCast<QObject>());
	}
	
	virtual void prepend(QList<QSharedPointer<QObject>> items);
	template <class T>
	void prepend(QList<QSharedPointer<T>> items){
		beginInsertRows(QModelIndex(), 0, items.size()-1);
		items << mList;
		mList = items;
		endInsertRows();
	}

// Remove functions
	Q_INVOKABLE virtual bool remove(QObject *itemToRemove) ;
	virtual bool remove(QSharedPointer<QObject> itemToRemove) ;
	
	virtual bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	virtual bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	
	Q_INVOKABLE virtual void resetData();
	
protected:
	QList<QSharedPointer<QObject>> mList;
	
};

#endif
