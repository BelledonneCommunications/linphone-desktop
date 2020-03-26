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

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"

#include "CallsListModel.hpp"
#include "CallsListProxyModel.hpp"

// =============================================================================

using namespace std;

CallsListProxyModel::CallsListProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  CallsListModel *callsListModel = CoreManager::getInstance()->getCallsListModel();

  QObject::connect(callsListModel, &CallsListModel::callRunning, this, [this](int index, CallModel *callModel) {
    emit callRunning(index, callModel);
  });

  setSourceModel(callsListModel);
  sort(0);
}

bool CallsListProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  return !index.data().value<CallModel *>()->isInConference();
}
