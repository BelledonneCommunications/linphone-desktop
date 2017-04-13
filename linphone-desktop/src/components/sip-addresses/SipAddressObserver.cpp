/*
 * SipAddressObserver.cpp
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
 *  Created on: March 28, 2017
 *      Author: Ronan Abhamon
 */

#include "SipAddressObserver.hpp"

// =============================================================================

SipAddressObserver::SipAddressObserver (const QString &sipAddress) {
  mSipAddress = sipAddress;
}

void SipAddressObserver::setContact (ContactModel *contact) {
  if (contact == mContact)
    return;

  mContact = contact;
  emit contactChanged(contact);
}

void SipAddressObserver::setPresenceStatus (const Presence::PresenceStatus &presenceStatus) {
  if (presenceStatus == mPresenceStatus)
    return;

  mPresenceStatus = presenceStatus;
  emit presenceStatusChanged(presenceStatus);
}

void SipAddressObserver::setUnreadMessagesCount (int unreadMessagesCount) {
  if (unreadMessagesCount == mUnreadMessagesCount)
    return;

  mUnreadMessagesCount = unreadMessagesCount;
  emit unreadMessagesCountChanged(unreadMessagesCount);
}
