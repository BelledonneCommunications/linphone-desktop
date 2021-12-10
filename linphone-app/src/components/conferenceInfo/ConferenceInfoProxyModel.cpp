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

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"

#include "ConferenceInfoListModel.hpp"
#include "ConferenceInfoProxyModel.hpp"

// =============================================================================

using namespace std;

ConferenceInfoProxyModel::ConferenceInfoProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	setSourceModel(new ConferenceInfoListModel());
	sort(0);
}

bool ConferenceInfoProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}
