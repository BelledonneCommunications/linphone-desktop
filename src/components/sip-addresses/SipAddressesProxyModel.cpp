/*
 * SipAddressesProxyModel.cpp
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

#include "../core/CoreManager.hpp"

#include "SipAddressesProxyModel.hpp"

#define WEIGHT_POS_0 5
#define WEIGHT_POS_1 4
#define WEIGHT_POS_2 3
#define WEIGHT_POS_3 2
#define WEIGHT_POS_OTHER 1

// =============================================================================

const QRegExp SipAddressesProxyModel::mSearchSeparators("^[^_.-;@ ][_.-;@ ]");

// -----------------------------------------------------------------------------

SipAddressesProxyModel::SipAddressesProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getSipAddressesModel());
  sort(0);
}

// -----------------------------------------------------------------------------

void SipAddressesProxyModel::setFilter (const QString &pattern) {
  mFilter = pattern;
  invalidate();
}

// -----------------------------------------------------------------------------

bool SipAddressesProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  return computeEntryWeight(index.data().toMap()) > 0;
}

bool SipAddressesProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const QVariantMap mapA = sourceModel()->data(left).toMap();
  const QVariantMap mapB = sourceModel()->data(right).toMap();

  const QString sipAddressA = mapA["sipAddress"].toString();
  const QString sipAddressB = mapB["sipAddress"].toString();

  // TODO: Use a cache, do not compute the same value as `filterAcceptsRow`.
  int weightA = computeEntryWeight(mapA);
  int weightB = computeEntryWeight(mapB);

  // 1. Not the same weight.
  if (weightA != weightB)
    return weightA > weightB;

  const ContactModel *contactA = mapA.value("contact").value<ContactModel *>();
  const ContactModel *contactB = mapB.value("contact").value<ContactModel *>();

  // 2. No contacts.
  if (!contactA && !contactB)
    return sipAddressA <= sipAddressB;

  // 3. No contact for a or b.
  if (!contactA || !contactB)
    return !!contactA;

  // 4. Same contact (address).
  if (contactA == contactB)
    return sipAddressA <= sipAddressB;

  // 5. Not the same contact name.
  int diff = contactA->mLinphoneFriend->getName().compare(contactB->mLinphoneFriend->getName());
  if (diff)
    return diff <= 0;

  // 6. Same contact name, so compare sip addresses.
  return sipAddressA <= sipAddressB;
}

int SipAddressesProxyModel::computeEntryWeight (const QVariantMap &entry) const {
  int weight = computeStringWeight(entry["sipAddress"].toString().mid(4));

  const ContactModel *contact = entry.value("contact").value<ContactModel *>();
  if (contact)
    weight += computeStringWeight(contact->getVcardModel()->getUsername());

  return weight;
}

int SipAddressesProxyModel::computeStringWeight (const QString &string) const {
  int index = -1;
  int offset = -1;

  while ((index = string.indexOf(mFilter, index + 1, Qt::CaseInsensitive)) != -1) {
    int tmpOffset = index - string.lastIndexOf(mSearchSeparators, index) - 1;
    if ((tmpOffset != -1 && tmpOffset < offset) || offset == -1)
      if ((offset = tmpOffset) == 0) break;
  }

  switch (offset) {
    case -1: return 0;
    case 0: return WEIGHT_POS_0;
    case 1: return WEIGHT_POS_1;
    case 2: return WEIGHT_POS_2;
    case 3: return WEIGHT_POS_3;
    default: break;
  }

  return WEIGHT_POS_OTHER;
}
