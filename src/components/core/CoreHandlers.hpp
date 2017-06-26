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

class CoreManager;
class QMutex;

class CoreHandlers :
  public QObject,
  public linphone::CoreListener {
  Q_OBJECT;

public:
  CoreHandlers (CoreManager *coreManager);
  ~CoreHandlers ();

signals:
  void authenticationRequested (const std::shared_ptr<linphone::AuthInfo> &authInfo);
  void callStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::CallState state);
  void callTransferFailed (const std::shared_ptr<linphone::Call> &call);
  void callTransferSucceeded (const std::shared_ptr<linphone::Call> &call);
  void coreStarted ();
  void isComposingChanged (const std::shared_ptr<linphone::ChatRoom> &chatRoom);
  void logsUploadStateChanged (linphone::CoreLogCollectionUploadState state, const std::string &info);
  void messageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
  void presenceReceived (const QString &sipAddress, const std::shared_ptr<const linphone::PresenceModel> &presenceModel);
  void registrationStateChanged (const std::shared_ptr<linphone::ProxyConfig> &proxyConfig, linphone::RegistrationState state);

private:
  void handleCoreCreated ();
  void notifyCoreStarted ();

  // ---------------------------------------------------------------------------
  // Linphone callbacks.
  // ---------------------------------------------------------------------------

  void onAuthenticationRequested (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::AuthInfo> &authInfo,
    linphone::AuthMethod method
  ) override;

  void onCallStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Call> &call,
    linphone::CallState state,
    const std::string &message
  ) override;

  void onCallStatsUpdated (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Call> &call,
    const std::shared_ptr<const linphone::CallStats> &stats
  ) override;

  void onGlobalStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    linphone::GlobalState gstate,
    const std::string &message
  ) override;

  void onIsComposingReceived (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::ChatRoom> &room
  ) override;

  void onLogCollectionUploadStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    linphone::CoreLogCollectionUploadState state,
    const std::string &info
  ) override;

  void onLogCollectionUploadProgressIndication (
    const std::shared_ptr<linphone::Core> &lc,
    size_t offset,
    size_t total
  ) override;

  void onMessageReceived (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::ChatRoom> &room,
    const std::shared_ptr<linphone::ChatMessage> &message
  ) override;

  void onNotifyPresenceReceivedForUriOrTel (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Friend> &linphoneFriend,
    const std::string &uriOrTel,
    const std::shared_ptr<const linphone::PresenceModel> &presenceModel
  ) override;

  void onNotifyPresenceReceived (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Friend> &linphoneFriend
  ) override;

  void onRegistrationStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::ProxyConfig> &proxyConfig,
    linphone::RegistrationState state,
    const std::string &message
  ) override;

  void onTransferStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Call> &call,
    linphone::CallState state
  ) override;

  void onVersionUpdateCheckResultReceived (
    const std::shared_ptr<linphone::Core> &,
    linphone::VersionUpdateCheckResult result,
    const std::string &version,
    const std::string &url
  ) override;

  // ---------------------------------------------------------------------------

  bool mCoreCreated = false;
  bool mCoreStarted = false;

  QMutex *mCoreStartedLock = nullptr;
};

#endif // CORE_HANDLERS_H_
