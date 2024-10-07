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

#include "CarddavProxy.hpp"
#include "CarddavGui.hpp"
#include "CarddavList.hpp"

DEFINE_ABSTRACT_OBJECT(CarddavProxy)

CarddavProxy::CarddavProxy(QObject *parent) : SortFilterProxy(parent) {
	mCarddavList = CarddavList::create();
	setSourceModel(mCarddavList.get());
}

CarddavProxy::~CarddavProxy() {
	setSourceModel(nullptr);
}

QString CarddavProxy::getFilterText() const {
	return mFilterText;
}

void CarddavProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
		mFilterText = filter;
		invalidate();
		emit filterTextChanged();
	}
}

void CarddavProxy::removeAllEntries() {
	static_cast<CarddavList *>(sourceModel())->removeAllEntries();
}

void CarddavProxy::removeEntriesWithFilter() {
	std::list<QSharedPointer<CarddavCore>> itemList(rowCount());
	for (auto i = rowCount() - 1; i >= 0; --i) {
		auto item = getItemAt<CarddavList, CarddavCore>(i);
		itemList.emplace_back(item);
	}
	for (auto item : itemList) {
		mCarddavList->ListProxy::remove(item.get());
		if (item) item->remove();
	}
}

bool CarddavProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool CarddavProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = getItemAt<CarddavList, CarddavCore>(left.row());
	auto r = getItemAt<CarddavList, CarddavCore>(right.row());

	return l->mDisplayName < r->mDisplayName;
}

void CarddavProxy::updateView() {
	mCarddavList->lUpdate();
}
