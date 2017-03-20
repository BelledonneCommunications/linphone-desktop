/*
 * CoreHandlers.hpp
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

#ifndef CORE_HANDLERS_H_
#define CORE_HANDLERS_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class CoreHandlers :
  public QObject,
  public linphone::CoreListener {
  Q_OBJECT;

signals:
  void callStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::CallState state);
  void messageReceived (const std::shared_ptr<linphone::ChatMessage> &message);

private:
  void onAuthenticationRequested (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::AuthInfo> &auth_info,
    linphone::AuthMethod method
  ) override;

  void onCallStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Call> &call,
    linphone::CallState state,
    const std::string &message
  ) override;

  void onMessageReceived (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::ChatRoom> &room,
    const std::shared_ptr<linphone::ChatMessage> &message
  ) override;

  void onNotifyPresenceReceivedForUriOrTel (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Friend> &linphone_friend,
    const std::string &uri_or_tel,
    const std::shared_ptr<linphone::PresenceModel> &presence_model
  ) override;

  void onRegistrationStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::ProxyConfig> &config,
    linphone::RegistrationState state,
    const std::string &message
  ) override;
};

#endif // CORE_HANDLERS_H_
