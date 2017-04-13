/*
 * CoreHandlers.cpp
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

#include "../../app/App.hpp"
#include "../../utils.hpp"
#include "CoreManager.hpp"

#include "CoreHandlers.hpp"

using namespace std;

// =============================================================================

void CoreHandlers::onAuthenticationRequested (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::AuthInfo> &authInfo,
  linphone::AuthMethod
) {
  emit authenticationRequested(authInfo);
}

void CoreHandlers::onCallStateChanged (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Call> &call,
  linphone::CallState state,
  const string &
) {
  emit callStateChanged(call, state);

  if (call->getState() == linphone::CallStateIncomingReceived)
    App::getInstance()->getNotifier()->notifyReceivedCall(call);
}

void CoreHandlers::onMessageReceived (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::ChatRoom> &,
  const shared_ptr<linphone::ChatMessage> &message
) {
  const string contentType = message->getContentType();

  if (contentType == "text/plain" || contentType == "application/vnd.gsma.rcs-ft-http+xml") {
    emit messageReceived(message);

    const App *app = App::getInstance();
    if (!app->hasFocus())
      app->getNotifier()->notifyReceivedMessage(message);
  }
}

void CoreHandlers::onNotifyPresenceReceivedForUriOrTel (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Friend> &,
  const string &uriOrTel,
  const shared_ptr<const linphone::PresenceModel> &presenceModel
) {
  emit presenceReceived(::Utils::linphoneStringToQString(uriOrTel), presenceModel);
}

void CoreHandlers::onNotifyPresenceReceived (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Friend> &linphoneFriend
) {
  linphoneFriend->getData<ContactModel>("contact-model").refreshPresence();
}

void CoreHandlers::onRegistrationStateChanged (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::ProxyConfig> &proxyConfig,
  linphone::RegistrationState state,
  const string &
) {
  emit registrationStateChanged(proxyConfig, state);
}
