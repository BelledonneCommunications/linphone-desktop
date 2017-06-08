/*
 * AuthenticationNotifier.cpp
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
 *  Created on: April 13, 2017
 *      Author: Ronan Abhamon
 */

#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "AuthenticationNotifier.hpp"

using namespace std;

// =============================================================================

AuthenticationNotifier::AuthenticationNotifier (QObject *parent) : QObject(parent) {
  QObject::connect(
    CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::authenticationRequested,
    this, &AuthenticationNotifier::handleAuthenticationRequested
  );
}

void AuthenticationNotifier::handleAuthenticationRequested (const shared_ptr<linphone::AuthInfo> &authInfo) {
  emit authenticationRequested(
    QVariant::fromValue(authInfo),
    ::Utils::coreStringToAppString(authInfo->getRealm()),
    QStringLiteral("%1@%2").arg(
      ::Utils::coreStringToAppString(authInfo->getUsername())
    ).arg(
      ::Utils::coreStringToAppString(authInfo->getDomain())
    ),
    ::Utils::coreStringToAppString(authInfo->getUserid())
  );
}
