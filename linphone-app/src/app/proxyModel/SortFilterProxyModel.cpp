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

#include "SortFilterProxyModel.hpp"

SortFilterProxyModel::SortFilterProxyModel(QObject * parent) : QSortFilterProxyModel(parent){
	mFilterType = 0;
	connect(this, &SortFilterProxyModel::rowsInserted, this, &SortFilterProxyModel::countChanged);
	connect(this, &SortFilterProxyModel::rowsRemoved, this, &SortFilterProxyModel::countChanged);
}

int SortFilterProxyModel::getCount() const{
	return rowCount();
}

int SortFilterProxyModel::getFilterType () const{
	return mFilterType;
}

QVariant SortFilterProxyModel::getAt(const int& atIndex) const {
	auto modelIndex = index(atIndex,0);
	return sourceModel()->data(mapToSource(modelIndex), 0);
}

void SortFilterProxyModel::setSortOrder(const Qt::SortOrder& order){
	sort(0, order);
}

void SortFilterProxyModel::setFilterType (int filterType) {
	if (getFilterType() != filterType) {
		mFilterType = filterType;
		emit filterTypeChanged(filterType);
		invalidate();
	}
}

void SortFilterProxyModel::remove(int index, int count){
	QSortFilterProxyModel::removeRows(index, count);
}
