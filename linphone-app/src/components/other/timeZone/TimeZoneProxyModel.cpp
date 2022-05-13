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

#include "components/core/CoreManager.hpp"

#include "TimeZoneModel.hpp"
#include "TimeZoneListModel.hpp"
#include "TimeZoneProxyModel.hpp"

// -----------------------------------------------------------------------------

TimeZoneProxyModel::TimeZoneProxyModel (QObject *parent) : SortFilterProxyModel(parent) {
	setSourceModel(new TimeZoneListModel(parent));
	sort(0);
}

// -----------------------------------------------------------------------------

bool TimeZoneProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	auto test = sourceModel()->data(left);
	const TimeZoneModel* a = sourceModel()->data(left).value<TimeZoneModel*>();
	const TimeZoneModel* b = sourceModel()->data(right).value<TimeZoneModel*>();
    auto timeA = a->getStandardTimeOffset();
    auto timeB = b->getStandardTimeOffset();

	return timeA < timeB || (timeA == timeB && a->getCountryName() < b->getCountryName());
}

int TimeZoneProxyModel::getIndex(TimeZoneModel * model) const{
	auto listModel = qobject_cast<TimeZoneListModel*>(sourceModel());
	int index = 0;
	if(model)
		index = listModel->get(model->getTimeZone());
	else
		index = listModel->get();
	return mapFromSource(sourceModel()->index(index, 0)).row();
}
