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

#ifndef CARDDAV_PROXY_H_
#define CARDDAV_PROXY_H_

#include "../../proxy/LimitProxy.hpp"
#include "CarddavGui.hpp"
#include "CarddavList.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class CarddavProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT

public:
	DECLARE_SORTFILTER_CLASS()

	CarddavProxy(QObject *parent = Q_NULLPTR);
	~CarddavProxy();

	Q_INVOKABLE void removeAllEntries();
	Q_INVOKABLE void removeEntriesWithFilter();
	Q_INVOKABLE void updateView();

protected:
	QSharedPointer<CarddavList> mCarddavList;

	DECLARE_ABSTRACT_OBJECT
};

#endif
