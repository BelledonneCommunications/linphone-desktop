/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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
#include "components/settings/AccountSettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "TimelineProxyModel.hpp"
#include "TimelineListModel.hpp"
#include "TimelineModel.hpp"

#include <QDebug>


// =============================================================================

// -----------------------------------------------------------------------------

TimelineProxyModel::TimelineProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getTimelineListModel());
  sort(0);
}

// -----------------------------------------------------------------------------

bool TimelineProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  return true;
}

bool TimelineProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
    const TimelineModel* a = sourceModel()->data(left).value<TimelineModel*>();
    const TimelineModel* b = sourceModel()->data(right).value<TimelineModel*>();
  
    return a->mTimestamp <= b->mTimestamp;
}
