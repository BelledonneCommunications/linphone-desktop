/*
 * ConferenceHelperModel.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: May 11, 2017
 *      Author: Ronan Abhamon
 */

#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "ConferenceHelperModel.hpp"

// =============================================================================

ConferenceHelperModel::ConferenceHelperModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getSipAddressesModel());

  for (const auto &participant : CoreManager::getInstance()->getCore()->getConference()->getParticipants())
    mInConference << ::Utils::linphoneStringToQString(participant->asStringUriOnly());
}

QHash<int, QByteArray> ConferenceHelperModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$sipAddress";
  return roles;
}

bool ConferenceHelperModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex &index = sourceModel()->index(sourceRow, 0, sourceParent);
  const QVariantMap &data = index.data().toMap();

  return !mInConference.contains(data["sipAddress"].toString());
}
