/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef TIME_ZONE_LIST_MODEL_H_
#define TIME_ZONE_LIST_MODEL_H_

#include "TimeZoneModel.hpp"
#include "app/proxyModel/ProxyListModel.hpp"
// =============================================================================

class TimeZoneListModel : public ProxyListModel {
	Q_OBJECT
	
public:
	
	TimeZoneListModel (QObject *parent = Q_NULLPTR);
	
	void initTimeZones();
	int get(const QTimeZone& timeZone = QTimeZone::systemTimeZone())const;
	
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
};

#endif
