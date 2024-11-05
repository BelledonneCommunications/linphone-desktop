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

#include "TimeZoneProxy.hpp"
#include "TimeZoneList.hpp"
#include "core/timezone/TimeZone.hpp"

// -----------------------------------------------------------------------------

TimeZoneProxy::TimeZoneProxy(QObject *parent) : LimitProxy(parent) {
	mList = TimeZoneList::create();
	auto a = new SortFilterList(mList.get()); // Avoid using sort because it is too slow
	setSourceModels(a);
}

// -----------------------------------------------------------------------------

bool TimeZoneProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool TimeZoneProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<TimeZoneList, TimeZoneModel>(sourceLeft.row());
	auto r = getItemAtSource<TimeZoneList, TimeZoneModel>(sourceRight.row());
	if (!l || !r) return true;
	auto timeA = l->getStandardTimeOffset() / 3600;
	auto timeB = r->getStandardTimeOffset() / 3600;

	return timeA < timeB || (timeA == timeB && l->getCountryName() < r->getCountryName());
}

int TimeZoneProxy::getIndex(TimeZoneModel *model) const {
	int index = 0;
	index = mList->get(model ? model->getTimeZone() : QTimeZone::systemTimeZone());
	return dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(mList->index(index, 0)).row();
}
