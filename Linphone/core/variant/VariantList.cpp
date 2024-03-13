// /*
//  * Copyright (c) 2010-2024 Belledonne Communications SARL.
//  *
//  * This file is part of linphone-desktop
//  * (see https://www.linphone.org).
//  *
//  * This program is free software: you can redistribute it and/or modify
//  * it under the terms of the GNU General Public License as published by
//  * the Free Software Foundation, either version 3 of the License, or
//  * (at your option) any later version.
//  *
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program. If not, see <http://www.gnu.org/licenses/>.
//  */

#include "VariantList.hpp"

DEFINE_ABSTRACT_OBJECT(VariantList)

VariantList::VariantList(QObject *parent) {
}

VariantList::VariantList(QList<QVariant> list, QObject *parent) {
	setModel(list);
}

VariantList::~VariantList() {
}

int VariantList::rowCount(const QModelIndex &parent) const {
	return mList.count();
}

void VariantList::setModel(QList<QVariant> list) {
	beginResetModel();
	mList = list;
	endResetModel();
	emit modelChanged();
}

void VariantList::replace(int index, QVariant newValue) {
	mList.replace(index, newValue);
}

QVariant VariantList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return mList[row];
	return QVariant();
}
