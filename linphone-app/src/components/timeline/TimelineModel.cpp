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

#include "TimelineModel.hpp"

// =============================================================================

TimelineModel::TimelineModel (QObject *parent) : QSortFilterProxyModel(parent) {
  CoreManager *coreManager = CoreManager::getInstance();
  AccountSettingsModel *accountSettingsModel = coreManager->getAccountSettingsModel();

  QObject::connect(accountSettingsModel, &AccountSettingsModel::accountSettingsUpdated, this, [this]() {
    handleLocalAddressChanged(CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddressAsString());
  });
  mLocalAddress = accountSettingsModel->getUsedSipAddressAsString();

  setSourceModel(coreManager->getSipAddressesModel());
  sort(0);
}

QHash<int, QByteArray> TimelineModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$timelineEntry";
  return roles;
}

// -----------------------------------------------------------------------------

static inline const QHash<QString, SipAddressesModel::ConferenceEntry> *getLocalToConferenceEntry (const QVariantMap &map) {
  return map.value("__localToConferenceEntry").value<decltype(getLocalToConferenceEntry({}))>();
}

QVariant TimelineModel::data (const QModelIndex &index, int role) const {
  QVariantMap map(QSortFilterProxyModel::data(index, role).toMap());

  auto localToConferenceEntry = getLocalToConferenceEntry(map);
  auto it = localToConferenceEntry->find(mLocalAddress);
  if (it != localToConferenceEntry->end()) {
    map["timestamp"] = it->timestamp;
    map["isComposing"] = it->isComposing;
    map["unreadMessageCount"] = it->unreadMessageCount;
  }

  return map;
}

bool TimelineModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  return getLocalToConferenceEntry(index.data().toMap())->contains(mLocalAddress);
}

bool TimelineModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const QDateTime &a(getLocalToConferenceEntry(sourceModel()->data(left).toMap())->find(mLocalAddress)->timestamp);
  const QDateTime &b(getLocalToConferenceEntry(sourceModel()->data(right).toMap())->find(mLocalAddress)->timestamp);
  return a > b;
}

// -----------------------------------------------------------------------------

void TimelineModel::handleLocalAddressChanged (const QString &localAddress) {
  if (mLocalAddress != localAddress) {
    mLocalAddress = localAddress;
    invalidate();
  }
}
