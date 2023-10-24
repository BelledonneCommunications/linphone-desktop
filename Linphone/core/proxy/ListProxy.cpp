/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#include "ListProxy.hpp"

#include <QDebug>

// =============================================================================

ListProxy::ListProxy(QObject *parent) : AbstractListProxy(parent) {
}

ListProxy::~ListProxy() {
}

QSharedPointer<QObject> ListProxy::get(QObject *itemToGet, int *index) const {
	int row = 0;
	for (auto item : mList)
		if (item.get() == itemToGet) {
			if (index) *index = row;
			return item;
		} else ++row;
	return nullptr;
}

// -----------------------------------------------------------------------------
