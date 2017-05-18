/*
 * ConferenceAddModel.cpp
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
 *  Created on: May 18, 2017
 *      Author: Ronan Abhamon
 */

#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "ConferenceAddModel.hpp"

using namespace std;

// =============================================================================

ConferenceHelperModel::ConferenceAddModel::ConferenceAddModel (QObject *parent) : QAbstractListModel(parent) {
  mConferenceHelperModel = qobject_cast<ConferenceHelperModel *>(parent);
  Q_ASSERT(mConferenceHelperModel != nullptr);

  for (auto &participant : CoreManager::getInstance()->getCore()->getConference()->getParticipants())
    addToConference(participant);
}

int ConferenceHelperModel::ConferenceAddModel::rowCount (const QModelIndex &) const {
  return mRefs.count();
}

QHash<int, QByteArray> ConferenceHelperModel::ConferenceAddModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$sipAddress";
  return roles;
}

QVariant ConferenceHelperModel::ConferenceAddModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mRefs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(*mRefs[row]);

  return QVariant();
}

// -----------------------------------------------------------------------------

bool ConferenceHelperModel::ConferenceAddModel::addToConference (const QString &sipAddress) {
  if (mSipAddresses.contains(sipAddress))
    return false;

  int row = rowCount();

  beginInsertRows(QModelIndex(), row, row);

  qInfo() << QStringLiteral("Add sip address to conference: `%1`.").arg(sipAddress);
  shared_ptr<linphone::Address> linphoneAddress = CoreManager::getInstance()->getCore()->interpretUrl(
      ::Utils::qStringToLinphoneString(sipAddress)
    );
  addToConference(linphoneAddress);

  endInsertRows();

  mConferenceHelperModel->invalidate();

  return true;
}

bool ConferenceHelperModel::ConferenceAddModel::removeFromConference (const QString &sipAddress) {
  auto it = mSipAddresses.find(sipAddress);
  if (it == mSipAddresses.end())
    return false;

  int row = mRefs.indexOf(&(*it));

  beginRemoveRows(QModelIndex(), row, row);

  qInfo() << QStringLiteral("Remove sip address from conference: `%1`.").arg(sipAddress);

  mRefs.removeAt(row);
  mSipAddresses.remove(sipAddress);

  endRemoveRows();

  mConferenceHelperModel->invalidate();

  return true;
}

// -----------------------------------------------------------------------------

void ConferenceHelperModel::ConferenceAddModel::update () {
  list<shared_ptr<linphone::Address> > linphoneAddresses;
  for (const auto &map : mRefs)
    linphoneAddresses.push_back(map->value("__linphoneAddress").value<shared_ptr<linphone::Address> > ());

  mConferenceHelperModel->mConference->inviteParticipants(
    linphoneAddresses,
    CoreManager::getInstance()->getCore()->createCallParams(nullptr)
  );
}

// -----------------------------------------------------------------------------

void ConferenceHelperModel::ConferenceAddModel::addToConference (const std::shared_ptr<linphone::Address> &linphoneAddress) {
  QString sipAddress = ::Utils::linphoneStringToQString(linphoneAddress->asStringUriOnly());
  QVariantMap map;

  map["sipAddress"] = sipAddress;
  map["__linphoneAddress"] = QVariant::fromValue(linphoneAddress);

  mSipAddresses[sipAddress] = map;
  mRefs << &mSipAddresses[sipAddress];
}
