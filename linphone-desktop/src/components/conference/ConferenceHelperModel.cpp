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
#include "../smart-search-bar/SmartSearchBarModel.hpp"

#include "ConferenceHelperModel.hpp"

// =============================================================================

ConferenceHelperModel::ConferenceHelperModel (QObject *parent) : QSortFilterProxyModel(parent) {
  CoreManager *coreManager = CoreManager::getInstance();

  for (const auto &participant : coreManager->getCore()->getConference()->getParticipants())
    mInConference << ::Utils::linphoneStringToQString(participant->asStringUriOnly());

  CallsListModel *calls = coreManager->getCallsListModel();

  QObject::connect(calls, &CallsListModel::rowsAboutToBeRemoved, this, &ConferenceHelperModel::handleCallsAboutToBeRemoved);
  QObject::connect(calls, &CallsListModel::callRunning, this, &ConferenceHelperModel::handleCallRunning);

  setSourceModel(new SmartSearchBarModel(this));
}

QHash<int, QByteArray> ConferenceHelperModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$sipAddress";
  return roles;
}

// -----------------------------------------------------------------------------

void ConferenceHelperModel::setFilter (const QString &pattern) {
  static_cast<SmartSearchBarModel *>(sourceModel())->setFilter(pattern);
}

// -----------------------------------------------------------------------------

bool ConferenceHelperModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex &index = sourceModel()->index(sourceRow, 0, sourceParent);
  const QVariantMap &data = index.data().toMap();
  const QString &sipAddress = data["sipAddress"].toString();

  return !mInConference.contains(sipAddress) && !mToAdd.contains(sipAddress);
}

// -----------------------------------------------------------------------------

void ConferenceHelperModel::handleCallsAboutToBeRemoved (const QModelIndex &, int first, int last) {
  CallsListModel *calls = CoreManager::getInstance()->getCallsListModel();
  bool soFarSoGood = false;

  for (int i = first; i <= last; ++i) {
    const CallModel *callModel = calls->data(calls->index(first, 0)).value<CallModel *>();
    const QString &sipAddress = callModel->getSipAddress();

    if (removeFromConference(sipAddress))
      soFarSoGood = true;
  }

  if (soFarSoGood) {
    invalidateFilter();
    emit inConferenceChanged(mInConference);
  }
}

void ConferenceHelperModel::handleCallRunning (int, CallModel *callModel) {
  const QString &sipAddress = callModel->getSipAddress();
  bool soFarSoGood = callModel->getCall()->getConference()
    ? addToConference(sipAddress)
    : removeFromConference(sipAddress);

  if (soFarSoGood) {
    invalidateFilter();
    emit inConferenceChanged(mInConference);
  }
}

// -----------------------------------------------------------------------------

bool ConferenceHelperModel::addToConference (const QString &sipAddress) {
  bool ret = !mInConference.contains(sipAddress);
  if (ret) {
    qInfo() << QStringLiteral("Add sip address to conference: `%1`.").arg(sipAddress);
    mInConference << sipAddress;
  }
  return ret;
}

bool ConferenceHelperModel::removeFromConference (const QString &sipAddress) {
  bool ret = mInConference.removeOne(sipAddress);
  if (ret)
    qInfo() << QStringLiteral("Remove sip address from conference: `%1`.").arg(sipAddress);
  return ret;
}
