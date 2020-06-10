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

#include "SipAddressObserver.hpp"

// =============================================================================

SipAddressObserver::SipAddressObserver (const QString &peerAddress, const QString &localAddress) {
  mPeerAddress = peerAddress;
  mLocalAddress = localAddress;
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

void SipAddressObserver::setUnreadMessageCount (int unreadMessageCount) {
  if (unreadMessageCount == mUnreadMessageCount)
    return;

  mUnreadMessageCount = unreadMessageCount;
  emit unreadMessageCountChanged(unreadMessageCount);
}
