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

#include "ProxyListModel.hpp"

#include <QDebug>

// =============================================================================

ProxyListModel::ProxyListModel (QObject *parent) : QAbstractListModel(parent) {
	connect(this, &ProxyListModel::rowsInserted, this, &ProxyListModel::countChanged);
	connect(this, &ProxyListModel::rowsRemoved, this, &ProxyListModel::countChanged);
}

ProxyListModel::~ProxyListModel(){
	beginResetModel();
	mList.clear();
	endResetModel();
}

int ProxyListModel::rowCount (const QModelIndex &) const {
	return mList.count();
}

int ProxyListModel::getCount() const{
	return rowCount();
}

QHash<int, QByteArray> ProxyListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	return roles;
}

QVariant ProxyListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row].get());
	
	return QVariant();
}

QSharedPointer<QObject> ProxyListModel::getAt(const int& index) const{
	return mList[index];
}

QSharedPointer<QObject> ProxyListModel::get(QObject * itemToGet, int * index) const{
	int row = 0;
	for(auto item : mList)
		if( item.get() == itemToGet){
			if( index )
				*index = row;
			return item;
		}else
			++row;
	return nullptr;
}

// -----------------------------------------------------------------------------

void ProxyListModel::add(QSharedPointer<QObject> item){
	int row = mList.count();
	beginInsertRows(QModelIndex(), row, row);
	mList << item;
	endInsertRows();
}

void ProxyListModel::prepend(QSharedPointer<QObject> item){
	mList.prepend(item);
}

void ProxyListModel::prepend(QList<QSharedPointer<QObject>> items){
	beginInsertRows(QModelIndex(), 0, items.size()-1);
	items << mList;
	mList = items;
	endInsertRows();
}

bool ProxyListModel::remove(QObject *itemToRemove) {
	bool removed = false;
	qInfo() << QStringLiteral("Removing ") << itemToRemove->metaObject()->className() << QStringLiteral(" : ") << itemToRemove;
	int index = 0;
	for(auto item : mList)
		if( item.get() == itemToRemove) {
			removed = removeRow(index);
			break;
		}else
			++index;
	if( !removed)
		qWarning() << QStringLiteral("Unable to remove ") << itemToRemove->metaObject()->className() << QStringLiteral(" : ") << itemToRemove;
	return removed;
}

bool ProxyListModel::remove(QSharedPointer<QObject> itemToRemove){
	return remove(itemToRemove.get());
}

bool ProxyListModel::removeRow (int row, const QModelIndex &parent) {
	return removeRows(row, 1, parent);
}

bool ProxyListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row);
	
	endRemoveRows();
	
	return true;
}

void ProxyListModel::resetData(){
	beginResetModel();
	mList.clear();
	endResetModel();
}
// -----------------------------------------------------------------------------
