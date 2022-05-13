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

#ifndef PROXY_ABSTRACT_MAP_MODEL_H_
#define PROXY_ABSTRACT_MAP_MODEL_H_

#include <QDebug>

#include "ProxyAbstractObject.hpp"

template <class X, class Y>
class ProxyAbstractMapModel : public ProxyAbstractObject {
public:
	
	ProxyAbstractMapModel (QObject *parent = Q_NULLPTR) : ProxyAbstractObject(parent) {}

	virtual ~ProxyAbstractMapModel(){
		resetData();
	}
	
	virtual int rowCount (const QModelIndex &index = QModelIndex()) const override{
		return mMappedList.count();
	}
	
	
	virtual QHash<int, QByteArray> roleNames () const override {
		QHash<int, QByteArray> roles;
		roles[Qt::DisplayRole] = "$modelData";
		roles[Qt::DisplayRole+1] = "$modelKey";
		return roles;
	}
	
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override{
		int row = index.row();
		auto it = mMappedList.begin() + row;
		if (role == Qt::DisplayRole)
			return QVariant::fromValue(*it);
		else if( role == Qt::DisplayRole+1)
			return QVariant::fromValue(it.key());
		
		return QVariant();
	}
	
	virtual void resetData() override{
		beginResetModel();
		mMappedList.clear();
		endResetModel();
	}
	
protected:
	QMap<X, Y> mMappedList;
};

#endif
