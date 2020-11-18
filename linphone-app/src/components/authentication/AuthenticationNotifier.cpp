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

#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "AuthenticationNotifier.hpp"

// =============================================================================

using namespace std;

AuthenticationNotifier::AuthenticationNotifier (QObject *parent) : QObject(parent) {
  QObject::connect(
    CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::authenticationRequested,
    this, &AuthenticationNotifier::handleAuthenticationRequested
  );
}

void AuthenticationNotifier::handleAuthenticationRequested (const shared_ptr<linphone::AuthInfo> &authInfo) {
  emit authenticationRequested(
    QVariant::fromValue(authInfo),
    Utils::coreStringToAppString(authInfo->getRealm()),
    QStringLiteral("%1@%2").arg(
      QString::fromStdString(authInfo->getUsername())
    ).arg(
      Utils::coreStringToAppString(authInfo->getDomain())
    ),
    Utils::coreStringToAppString(authInfo->getUserid())
  );
}
