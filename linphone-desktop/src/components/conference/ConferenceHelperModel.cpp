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

#include "../../app/App.hpp"
#include "../core/CoreManager.hpp"
#include "../sip-addresses/SipAddressesProxyModel.hpp"
#include "ConferenceAddModel.hpp"

#include "ConferenceHelperModel.hpp"

using namespace std;

// =============================================================================

ConferenceHelperModel::ConferenceHelperModel (QObject *parent) : QSortFilterProxyModel(parent) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  mConference = core->getConference();
  if (!mConference)
    mConference = core->createConferenceWithParams(core->createConferenceParams());

  mConferenceAddModel = new ConferenceAddModel(this);
  App::getInstance()->getEngine()->setObjectOwnership(mConferenceAddModel, QQmlEngine::CppOwnership);

  setSourceModel(new SipAddressesProxyModel(this));
}

QHash<int, QByteArray> ConferenceHelperModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$sipAddress";
  return roles;
}

// -----------------------------------------------------------------------------

void ConferenceHelperModel::setFilter (const QString &pattern) {
  static_cast<SipAddressesProxyModel *>(sourceModel())->setFilter(pattern);
}

// -----------------------------------------------------------------------------

bool ConferenceHelperModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex &index = sourceModel()->index(sourceRow, 0, sourceParent);
  const QVariantMap &data = index.data().toMap();

  return !mConferenceAddModel->contains(data["sipAddress"].toString());
}
