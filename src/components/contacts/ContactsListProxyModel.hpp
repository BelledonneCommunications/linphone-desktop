/*
 * ContactsListProxyModel.hpp
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

#ifndef CONTACTS_LIST_PROXY_MODEL_H_
#define CONTACTS_LIST_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

// =============================================================================

class ContactModel;
class ContactsListModel;

class ContactsListProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

  Q_PROPERTY(
    bool useConnectedFilter
    READ isConnectedFilterUsed
    WRITE setConnectedFilter
  );

public:
  ContactsListProxyModel (QObject *parent = Q_NULLPTR);
  ~ContactsListProxyModel () = default;

  Q_INVOKABLE void setFilter (const QString &pattern);

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;

private:
  float computeStringWeight (const QString &string, float percentage) const;
  float computeContactWeight (const ContactModel *contact) const;

  bool isConnectedFilterUsed () const {
    return mUseConnectedFilter;
  }

  void setConnectedFilter (bool useConnectedFilter);

  QString mFilter;
  bool mUseConnectedFilter = false;

  // It's just a cache to save values computed by `filterAcceptsRow`
  // and reused by `lessThan`.
  mutable QHash<const ContactModel *, unsigned int> mWeights;

  static const QRegExp mSearchSeparators;
};

#endif // CONTACTS_LIST_PROXY_MODEL_H_
