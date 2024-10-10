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

CarddavProxy::CarddavProxy(QObject *parent) : LimitProxy(parent) {
	mCarddavList = CarddavList::create();
	setSourceModels(new SortFilterList(mCarddavList.get(), Qt::AscendingOrder));
}

CarddavProxy::~CarddavProxy() {
	setSourceModel(nullptr);
}

void CarddavProxy::removeAllEntries() {
	static_cast<CarddavList *>(sourceModel())->removeAllEntries();
}

void CarddavProxy::removeEntriesWithFilter() {
	QList<QSharedPointer<CarddavCore>> itemList(rowCount());
	for (auto i = rowCount() - 1; i >= 0; --i) {
		auto item = getItemAt<SortFilterList, CarddavList, CarddavCore>(i);
		itemList[i] = item;
	}
	for (auto item : itemList) {
		mCarddavList->ListProxy::remove(item.get());
		if (item) item->remove();
	}
}

bool CarddavProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool CarddavProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<CarddavList, CarddavCore>(sourceLeft.row());
	auto r = getItemAtSource<CarddavList, CarddavCore>(sourceRight.row());

	return l->mDisplayName < r->mDisplayName;
}

void CarddavProxy::updateView() {
	mCarddavList->lUpdate();
}
