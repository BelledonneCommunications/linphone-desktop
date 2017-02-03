/*
 * AccountSettingsModel.cpp
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

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "AccountSettingsModel.hpp"

// =============================================================================

AccountSettingsModel::AccountSettingsModel (QObject *parent) : QObject(parent) {
  m_default_proxy = CoreManager::getInstance()->getCore()->getDefaultProxyConfig();
}

QString AccountSettingsModel::getUsername () const {
  shared_ptr<linphone::Address> address = getDefaultSipAddress();
  const string &display_name = address->getDisplayName();

  return ::Utils::linphoneStringToQString(
    display_name.empty() ? address->getUsername() : display_name
  );
}

void AccountSettingsModel::setUsername (const QString &username) {
  shared_ptr<linphone::Address> address = getDefaultSipAddress();

  if (address->setDisplayName(::Utils::qStringToLinphoneString(username)))
    qWarning() << QStringLiteral("Unable to set displayName on sip address: `%1`.")
      .arg(::Utils::linphoneStringToQString(address->asStringUriOnly()));

  emit accountUpdated();
}

Presence::PresenceLevel AccountSettingsModel::getPresenceLevel () const {
  return Presence::Green;
}

Presence::PresenceStatus AccountSettingsModel::getPresenceStatus () const {
  return Presence::Online;
}

QString AccountSettingsModel::getSipAddress () const {
  return ::Utils::linphoneStringToQString(getDefaultSipAddress()->asStringUriOnly());
}

// -----------------------------------------------------------------------------

shared_ptr<linphone::Address> AccountSettingsModel::getDefaultSipAddress () const {
  if (m_default_proxy)
    return m_default_proxy->getIdentityAddress();

  return CoreManager::getInstance()->getCore()->getPrimaryContactParsed();
}
