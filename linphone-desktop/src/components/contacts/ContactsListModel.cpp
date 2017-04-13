/*
 * ContactsListModel.cpp
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
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include <QtDebug>

#include "../../app/App.hpp"
#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "ContactsListModel.hpp"

using namespace std;

// =============================================================================

ContactsListModel::ContactsListModel (QObject *parent) : QAbstractListModel(parent) {
  mLinphoneFriends = CoreManager::getInstance()->getCore()->getFriendsLists().front();

  // Init contacts with linphone friends list.
  for (const auto &_friend : mLinphoneFriends->getFriends()) {
    ContactModel *contact = new ContactModel(this, _friend);

    // See: http://doc.qt.io/qt-5/qtqml-cppintegration-data.html#data-ownership
    // The returned value must have a explicit parent or a QQmlEngine::CppOwnership.
    App::getInstance()->getEngine()->setObjectOwnership(contact, QQmlEngine::CppOwnership);

    addContact(contact);
  }
}

int ContactsListModel::rowCount (const QModelIndex &) const {
  return mList.count();
}

QHash<int, QByteArray> ContactsListModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$contact";
  return roles;
}

QVariant ContactsListModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mList.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(mList[row]);

  return QVariant();
}

bool ContactsListModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool ContactsListModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mList.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i) {
    ContactModel *contact = mList.takeAt(row);

    mLinphoneFriends->removeFriend(contact->mLinphoneFriend);

    emit contactRemoved(contact);
    contact->deleteLater();
  }

  endRemoveRows();

  return true;
}

// -----------------------------------------------------------------------------

ContactModel *ContactsListModel::addContact (VcardModel *vcard) {
  ContactModel *contact = new ContactModel(this, vcard);
  App::getInstance()->getEngine()->setObjectOwnership(contact, QQmlEngine::CppOwnership);

  qInfo() << "Add contact:" << contact;

  if (
    mLinphoneFriends->addFriend(contact->mLinphoneFriend) !=
    linphone::FriendListStatus::FriendListStatusOK
  ) {
    qWarning() << "Unable to add friend from vcard:" << vcard;
    delete contact;
    return nullptr;
  }

  int row = mList.count();

  beginInsertRows(QModelIndex(), row, row);
  addContact(contact);
  endInsertRows();

  emit contactAdded(contact);

  return contact;
}

void ContactsListModel::removeContact (ContactModel *contact) {
  qInfo() << "Removing contact:" << contact;

  int index = mList.indexOf(contact);
  if (index == -1 || !removeRow(index))
    qWarning() << "Unable to remove contact:" << contact;
}

// -----------------------------------------------------------------------------

void ContactsListModel::addContact (ContactModel *contact) {
  QObject::connect(
    contact, &ContactModel::contactUpdated,
    this, [this, contact]() {
      emit contactUpdated(contact);
    }
  );
  QObject::connect(
    contact, &ContactModel::sipAddressAdded, this, [this, contact](const QString &sipAddress) {
      emit sipAddressAdded(contact, sipAddress);
    }
  );
  QObject::connect(
    contact, &ContactModel::sipAddressRemoved, this, [this, contact](const QString &sipAddress) {
      emit sipAddressRemoved(contact, sipAddress);
    }
  );

  mList << contact;
}
