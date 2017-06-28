/*
 * ContactsListProxyModel.cpp
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

#include <cmath>

#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "ContactsListProxyModel.hpp"

#define USERNAME_WEIGHT 50.f
#define SIP_ADDRESSES_WEIGHT 50.f

#define FACTOR_POS_0 1.0f
#define FACTOR_POS_1 0.9f
#define FACTOR_POS_2 0.8f
#define FACTOR_POS_3 0.7f
#define FACTOR_POS_OTHER 0.6f

using namespace std;

// =============================================================================

// Notes:
//
// - First `^` is necessary to search two words with one separator
// between them like `Claire Manning`.
//
// - [^_.-;@ ] is used to search patterns which starts with
// a separator like ` word`.
//
// - [_.-;@ ] is the main pattern (a separator).
const QRegExp ContactsListProxyModel::mSearchSeparators("^[^_.-;@ ][_.-;@ ]");

// -----------------------------------------------------------------------------

ContactsListProxyModel::ContactsListProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getContactsListModel());
  sort(0);
}

// -----------------------------------------------------------------------------

void ContactsListProxyModel::setFilter (const QString &pattern) {
  mFilter = pattern;
  invalidate();
}

// -----------------------------------------------------------------------------

bool ContactsListProxyModel::filterAcceptsRow (
  int sourceRow,
  const QModelIndex &sourceParent
) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  const ContactModel *contact = index.data().value<ContactModel *>();

  mWeights[contact] = static_cast<unsigned int>(round(computeContactWeight(contact)));

  return mWeights[contact] > 0 && (
    !mUseConnectedFilter ||
    contact->getPresenceLevel() != Presence::PresenceLevel::White
  );
}

bool ContactsListProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const ContactModel *contactA = sourceModel()->data(left).value<ContactModel *>();
  const ContactModel *contactB = sourceModel()->data(right).value<ContactModel *>();

  unsigned int weightA = mWeights[contactA];
  unsigned int weightB = mWeights[contactB];

  // Sort by weight and name.
  return weightA > weightB || (
    weightA == weightB &&
    contactA->mLinphoneFriend->getName() <= contactB->mLinphoneFriend->getName()
  );
}

// -----------------------------------------------------------------------------

float ContactsListProxyModel::computeStringWeight (const QString &string, float percentage) const {
  int index = -1;
  int offset = -1;

  // Search pattern.
  while ((index = string.indexOf(mFilter, index + 1, Qt::CaseInsensitive)) != -1) {
    // Search n chars between one separator and index.
    int tmpOffset = index - string.lastIndexOf(mSearchSeparators, index) - 1;

    if ((tmpOffset != -1 && tmpOffset < offset) || offset == -1)
      if ((offset = tmpOffset) == 0) break;
  }

  switch (offset) {
    case -1: return 0;
    case 0: return percentage * FACTOR_POS_0;
    case 1: return percentage * FACTOR_POS_1;
    case 2: return percentage * FACTOR_POS_2;
    case 3: return percentage * FACTOR_POS_3;
    default: break;
  }

  return percentage * FACTOR_POS_OTHER;
}

float ContactsListProxyModel::computeContactWeight (const ContactModel *contact) const {
  float weight = computeStringWeight(contact->getVcardModel()->getUsername(), USERNAME_WEIGHT);

  // Get all contact's addresses.
  const list<shared_ptr<linphone::Address> > addresses = contact->mLinphoneFriend->getAddresses();

  float size = static_cast<float>(addresses.size());
  for (auto it = addresses.cbegin(); it != addresses.cend(); ++it)
    weight += computeStringWeight(
        ::Utils::coreStringToAppString((*it)->asStringUriOnly()),
        SIP_ADDRESSES_WEIGHT / size
      );

  return weight;
}

// -----------------------------------------------------------------------------

void ContactsListProxyModel::setConnectedFilter (bool useConnectedFilter) {
  if (useConnectedFilter != mUseConnectedFilter) {
    mUseConnectedFilter = useConnectedFilter;
    invalidate();
  }
}
