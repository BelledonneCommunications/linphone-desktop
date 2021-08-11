/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/core/CoreManager.hpp"

#include "SipAddressesSorter.hpp"

#include "../search/SearchResultModel.hpp"

// =============================================================================

namespace {
  constexpr int WeightPos0 = 5;
  constexpr int WeightPos1 = 4;
  constexpr int WeightPos2 = 3;
  constexpr int WeightPos3 = 2;
  constexpr int WeightPosOther = 1;
}

const QRegExp SipAddressesSorter::SearchSeparators("^[^_.-;@ ][_.-;@ ]");

// -----------------------------------------------------------------------------

SipAddressesSorter::SipAddressesSorter (QObject *parent) : QObject(parent) {
}

// -----------------------------------------------------------------------------

//bool SipAddressesSorter::lessThan (const QString& filter, const QVariantMap &left, const QVariantMap &right) {
bool SipAddressesSorter::lessThan (const QString& filter, const SearchResultModel *left, const SearchResultModel *right) {
  const QString sipAddressA = left->getAddressString();
  const QString sipAddressB = right->getAddressString();

  // TODO: Use a cache, do not compute the same value as `filterAcceptsRow`.
  int weightA = computeEntryWeight(filter, left);
  int weightB = computeEntryWeight(filter, right);

  // 1. Not the same weight.
  if (weightA != weightB)
    return weightA > weightB;

  const ContactModel *contactA = left->getContactModel();
  const ContactModel *contactB = right->getContactModel();

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

int SipAddressesSorter::computeEntryWeight (const QString& filter, const SearchResultModel *entry) {
  int weight = computeStringWeight(filter, entry->getAddressString().mid(4));

  const ContactModel *contact = entry->getContactModel();
  if (contact)
    weight += computeStringWeight(filter, contact->getVcardModel()->getUsername());

  return weight;
}

int SipAddressesSorter::computeStringWeight (const QString& filter, const QString &string) {
  int index = -1;
  int offset = -1;

  while ((index = string.indexOf(filter, index + 1, Qt::CaseInsensitive)) != -1) {
    int tmpOffset = index - string.lastIndexOf(SearchSeparators, index) - 1;
    if ((tmpOffset != -1 && tmpOffset < offset) || offset == -1)
      if ((offset = tmpOffset) == 0) break;
  }

  switch (offset) {
    case -1: return 0;
    case 0: return WeightPos0;
    case 1: return WeightPos1;
    case 2: return WeightPos2;
    case 3: return WeightPos3;
    default: break;
  }

  return WeightPosOther;
}
