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

#ifndef TIME_ZONE_PROXY_MODEL_H_
#define TIME_ZONE_PROXY_MODEL_H_

#include "../proxy/LimitProxy.hpp"

// =============================================================================

class TimeZoneModel;
class TimeZoneList;

class TimeZoneProxy : public LimitProxy {
	Q_OBJECT
public:
	DECLARE_SORTFILTER_CLASS()

	TimeZoneProxy(QObject *parent = Q_NULLPTR);
	Q_PROPERTY(int defaultIndex READ getIndex CONSTANT)

	Q_INVOKABLE int getIndex(TimeZoneModel *model = nullptr) const;

protected:
	QSharedPointer<TimeZoneList> mList;
};

#endif
