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

SipAddressObserver::SipAddressObserver (const QString &sip_address) {
  m_sip_address = sip_address;
}

void SipAddressObserver::setContact (ContactModel *contact) {
  if (contact == m_contact)
    return;

  m_contact = contact;
  emit contactChanged(contact);
}

void SipAddressObserver::setPresenceStatus (const Presence::PresenceStatus &presence_status) {
  if (presence_status == m_presence_status)
    return;

  m_presence_status = presence_status;
  emit presenceStatusChanged(presence_status);
}
