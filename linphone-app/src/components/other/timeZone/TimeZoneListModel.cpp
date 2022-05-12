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

#include "TimeZoneListModel.hpp"

#include <QTimeZone>

// =============================================================================

using namespace std;

TimeZoneListModel::TimeZoneListModel (QObject *parent) : ProxyListModel(parent) {
	initTimeZones();
}

// -----------------------------------------------------------------------------

void TimeZoneListModel::initTimeZones () {
	resetData();
	for(auto id : QTimeZone::availableTimeZoneIds()){
		auto model = QSharedPointer<TimeZoneModel>::create(QTimeZone(id));
		if(model->getCountryName().toUpper() != "DEFAULT")
			ProxyListModel::add(model);
	}	
}


QHash<int, QByteArray> TimeZoneListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	roles[Qt::DisplayRole+1] = "displayText";
	return roles;
}

QVariant TimeZoneListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())	
		return QVariant();
	auto timeZoneModel = getAt<TimeZoneModel>(row);
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(timeZoneModel.get());
	}else{
		int offset = timeZoneModel->getStandardTimeOffset()/3600;
		int absOffset = std::abs(offset);
		
		return QStringLiteral("%1 (UTC%2%3%4) %5")
				.arg(timeZoneModel->getCountryName())
				.arg(offset >=0 ? "+" : "-")
				.arg(absOffset <10 ? "0" : "")
				.arg(absOffset)
				.arg(timeZoneModel->getTimeZone().comment());
	}
	
	return QVariant();
}

int TimeZoneListModel::getDefaultIndex () const {
	auto defaultTimezone = QTimeZone::systemTimeZone();
	const auto it = find_if(
				mList.cbegin(), mList.cend(), [&defaultTimezone](QSharedPointer<QObject> item) {
		return item.objectCast<TimeZoneModel>()->getTimeZone() == defaultTimezone;
	}
	);
	return it != mList.cend() ? int(distance(mList.cbegin(), it)) : 0;
}