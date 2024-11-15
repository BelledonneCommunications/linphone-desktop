/*
 * Copyright (c) 2022-2024 Belledonne Communications SARL.
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

#include "SortFilterProxy.hpp"

SortFilterProxy::SortFilterProxy(QAbstractItemModel *list) : QSortFilterProxyModel(list) {
	connect(this, &SortFilterProxy::rowsInserted, this, &SortFilterProxy::countChanged);
	connect(this, &SortFilterProxy::rowsRemoved, this, &SortFilterProxy::countChanged);
	setSourceModel(list);
}

SortFilterProxy::SortFilterProxy(QAbstractItemModel *list, Qt::SortOrder order) : SortFilterProxy(list) {
	sort(0, order);
}

SortFilterProxy::~SortFilterProxy() {
	if (mDeleteSourceModel) deleteSourceModel();
}

void SortFilterProxy::deleteSourceModel() {
	auto oldSourceModel = sourceModel();
	if (oldSourceModel) {
		oldSourceModel->deleteLater();
		setSourceModel(nullptr);
	}
}

void SortFilterProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldSourceModel = sourceModel();
	if (oldSourceModel) disconnect(oldSourceModel);
	QSortFilterProxyModel::setSourceModel(model);
}

int SortFilterProxy::getCount() const {
	return rowCount();
}

QVariant SortFilterProxy::getAt(const int &atIndex) const {
	auto modelIndex = index(atIndex, 0);
	return sourceModel()->data(mapToSource(modelIndex), 0);
}

int SortFilterProxy::getFilterType() const {
	return mFilterType;
}

void SortFilterProxy::setFilterType(int filterType) {
	if (getFilterType() != filterType) {
		mFilterType = filterType;
		emit filterTypeChanged(filterType);
		invalidate();
	}
}

QString SortFilterProxy::getFilterText() const {
	return mFilterText;
}

void SortFilterProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
		mFilterText = filter;
		invalidateFilter();
		emit filterTextChanged();
	}
}

void SortFilterProxy::setSortOrder(const Qt::SortOrder &order) {
	sort(0, order);
}

void SortFilterProxy::remove(int index, int count) {
	QSortFilterProxyModel::removeRows(index, count);
}

void SortFilterProxy::invalidateFilter() {
	QSortFilterProxyModel::invalidateFilter();
}
