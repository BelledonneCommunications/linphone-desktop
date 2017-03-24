/*
 * ContactModel.cpp
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

#include <QSet>

#include "../../app/App.hpp"

#include "ContactModel.hpp"

using namespace std;

// =============================================================================

ContactModel::ContactModel (QObject *parent, shared_ptr<linphone::Friend> linphone_friend) : QObject(parent) {
  m_linphone_friend = linphone_friend;
  m_vcard = make_shared<VcardModel>(linphone_friend->getVcard());

  App::getInstance()->getEngine()->setObjectOwnership(m_vcard.get(), QQmlEngine::CppOwnership);
  m_linphone_friend->setData("contact-model", *this);
}

ContactModel::ContactModel (QObject *parent, VcardModel *vcard) : QObject(parent) {
  Q_ASSERT(vcard != nullptr);

  QQmlEngine *engine = App::getInstance()->getEngine();
  if (engine->objectOwnership(vcard) == QQmlEngine::CppOwnership)
    throw invalid_argument("A contact is already linked to this vcard.");

  m_linphone_friend = linphone::Friend::newFromVcard(vcard->m_vcard);
  m_vcard.reset(vcard);

  engine->setObjectOwnership(vcard, QQmlEngine::CppOwnership);
}

void ContactModel::refreshPresence () {
  Presence::PresenceStatus status = static_cast<Presence::PresenceStatus>(
      m_linphone_friend->getConsolidatedPresence()
    );

  emit presenceStatusChanged(status);
  emit presenceLevelChanged(Presence::getPresenceLevel(status));
}

void ContactModel::startEdit () {
  m_linphone_friend->edit();
  m_old_sip_addresses = m_vcard->getSipAddresses();
}

void ContactModel::endEdit () {
  m_linphone_friend->done();

  QVariantList sip_addresses = m_vcard->getSipAddresses();
  QSet<QString> done;

  for (const auto &variant_a : m_old_sip_addresses) {
next:
    const QString &sip_address = variant_a.toString();
    if (done.contains(sip_address))
      continue;
    done.insert(sip_address);

    // Check if old sip address exists in new set => No changes.
    for (const auto &variant_b : sip_addresses) {
      if (sip_address == variant_b.toString())
        goto next;
    }

    emit sipAddressRemoved(sip_address);
  }

  m_old_sip_addresses.clear();

  for (const auto &variant : sip_addresses) {
    const QString &sip_address = variant.toString();
    if (done.contains(sip_address))
      continue;
    done.insert(sip_address);

    emit sipAddressAdded(sip_address);
  }

  emit contactUpdated();
}

void ContactModel::abortEdit () {
  // TODO: call linphone friend abort function when available.
  // m_linphone_friend->abort();
  m_old_sip_addresses.clear();

  emit contactUpdated();
}

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return static_cast<Presence::PresenceStatus>(m_linphone_friend->getConsolidatedPresence());
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}
