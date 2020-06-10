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

#include <QQmlApplicationEngine>

#include "app/App.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesProxyModel.hpp"
#include "utils/Utils.hpp"

#include "ConferenceAddModel.hpp"
#include "ConferenceHelperModel.hpp"

// =============================================================================

using namespace std;

ConferenceHelperModel::ConferenceHelperModel (QObject *parent) : QSortFilterProxyModel(parent) {
  mCore = CoreManager::getInstance()->getCore();
  mConferenceAddModel = new ConferenceAddModel(this);
  App::getInstance()->getEngine()->setObjectOwnership(mConferenceAddModel, QQmlEngine::CppOwnership);

  QObject::connect(this, &CallsListModel::rowsRemoved, [this] {
    invalidate();
  });
  QObject::connect(this, &CallsListModel::rowsInserted, [this] {
    invalidate();
  });

  setSourceModel(new SipAddressesProxyModel(this));
  sort(0);
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
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  const QVariantMap data = index.data().toMap();

  return !mConferenceAddModel->contains(data["sipAddress"].toString());
}

// -----------------------------------------------------------------------------

bool ConferenceHelperModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  shared_ptr<linphone::Call> callA = mCore->findCallFromUri(
    Utils::appStringToCoreString(left.data().toMap()["sipAddress"].toString())
  );
  shared_ptr<linphone::Call> callB = mCore->findCallFromUri(
    Utils::appStringToCoreString(right.data().toMap()["sipAddress"].toString())
  );

  return callA && !callB;
}
