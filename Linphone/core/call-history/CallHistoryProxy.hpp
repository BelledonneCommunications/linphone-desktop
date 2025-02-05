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

#ifndef CALL_HISTORY_PROXY_H_
#define CALL_HISTORY_PROXY_H_

#include "../proxy/LimitProxy.hpp"
#include "../proxy/SortFilterProxy.hpp"
#include "CallHistoryList.hpp"
#include "tool/AbstractObject.hpp"
#include <QSortFilterProxyModel>

// =============================================================================

class CallHistoryProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT
public:
	DECLARE_SORTFILTER_CLASS()

	CallHistoryProxy(QObject *parent = Q_NULLPTR);
	~CallHistoryProxy();

	Q_INVOKABLE void removeAllEntries();
	Q_INVOKABLE void removeEntriesWithFilter(QString filter);
	Q_INVOKABLE void reload();

protected:
	QSharedPointer<CallHistoryList> mHistoryList;

	DECLARE_ABSTRACT_OBJECT
};

#endif
