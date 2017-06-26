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

#include <QMutex>
#include <QtDebug>
#include <QThread>
#include <QTimer>

#include "../../app/App.hpp"
#include "../../utils/Utils.hpp"
#include "CoreManager.hpp"

#include "CoreHandlers.hpp"

using namespace std;

// =============================================================================

// Schedule a function in app context.
void scheduleFunctionInApp (function<void()> func) {
  App *app = App::getInstance();
  if (QThread::currentThread() != app->thread())
    QTimer::singleShot(0, app, func);
  else
    func();
}

// -----------------------------------------------------------------------------

CoreHandlers::CoreHandlers (CoreManager *coreManager) {
  mCoreStartedLock = new QMutex();
  QObject::connect(coreManager, &CoreManager::coreCreated, this, &CoreHandlers::handleCoreCreated);
}

CoreHandlers::~CoreHandlers () {
  delete mCoreStartedLock;
}

// -----------------------------------------------------------------------------

void CoreHandlers::handleCoreCreated () {
  mCoreStartedLock->lock();

  Q_ASSERT(mCoreCreated == false);
  mCoreCreated = true;
  notifyCoreStarted();

  mCoreStartedLock->unlock();
}

void CoreHandlers::notifyCoreStarted () {
  if (mCoreCreated && mCoreStarted)
    scheduleFunctionInApp([this] {
      qInfo() << QStringLiteral("Core started.");
      emit coreStarted();
    });
}

// -----------------------------------------------------------------------------

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

void CoreHandlers::onCallStatsUpdated (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Call> &call,
  const shared_ptr<const linphone::CallStats> &stats
) {
  call->getData<CallModel>("call-model").updateStats(stats);
}

void CoreHandlers::onGlobalStateChanged (
  const shared_ptr<linphone::Core> &,
  linphone::GlobalState gstate,
  const string &
) {
  if (gstate == linphone::GlobalStateOn) {
    mCoreStartedLock->lock();

    Q_ASSERT(mCoreStarted == false);
    mCoreStarted = true;
    notifyCoreStarted();

    mCoreStartedLock->unlock();
  }
}

void CoreHandlers::onIsComposingReceived (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::ChatRoom> &room
) {
  emit isComposingChanged(room);
}

void CoreHandlers::onLogCollectionUploadStateChanged (
  const shared_ptr<linphone::Core> &,
  linphone::CoreLogCollectionUploadState state,
  const string &info
) {
  emit logsUploadStateChanged(state, info);
}

void CoreHandlers::onLogCollectionUploadProgressIndication (
  const shared_ptr<linphone::Core> &,
  size_t,
  size_t
) {
  // TODO;
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
  emit presenceReceived(::Utils::coreStringToAppString(uriOrTel), presenceModel);
}

void CoreHandlers::onNotifyPresenceReceived (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Friend> &linphoneFriend
) {
  // Ignore friend without vcard because the `contact-model` data doesn't exist.
  if (linphoneFriend->getVcard())
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

void CoreHandlers::onTransferStateChanged (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Call> &call,
  linphone::CallState state
) {
  switch (state) {
    case linphone::CallStateEarlyUpdatedByRemote:
    case linphone::CallStateEarlyUpdating:
    case linphone::CallStateIdle:
    case linphone::CallStateIncomingEarlyMedia:
    case linphone::CallStateIncomingReceived:
    case linphone::CallStateOutgoingEarlyMedia:
    case linphone::CallStateOutgoingRinging:
    case linphone::CallStatePaused:
    case linphone::CallStatePausedByRemote:
    case linphone::CallStatePausing:
    case linphone::CallStateRefered:
    case linphone::CallStateReleased:
    case linphone::CallStateResuming:
    case linphone::CallStateStreamsRunning:
    case linphone::CallStateUpdatedByRemote:
    case linphone::CallStateUpdating:
      break; // Nothing.

    // 1. Init.
    case linphone::CallStateOutgoingInit:
      qInfo() << QStringLiteral("Call transfer init.");
      break;

    // 2. In progress.
    case linphone::CallStateOutgoingProgress:
      qInfo() << QStringLiteral("Call transfer in progress.");
      break;

    // 3. Done.
    case linphone::CallStateConnected:
      qInfo() << QStringLiteral("Call transfer succeeded.");
      emit callTransferSucceeded(call);
      break;

    // 4. Error.
    case linphone::CallStateEnd:
    case linphone::CallStateError:
      qWarning() << QStringLiteral("Call transfer failed.");
      emit callTransferFailed(call);
      break;
  }
}

void CoreHandlers::onVersionUpdateCheckResultReceived (
  const shared_ptr<linphone::Core> &,
  linphone::VersionUpdateCheckResult result,
  const string &version,
  const string &url
) {
  if (result == linphone::VersionUpdateCheckResultNewVersionAvailable)
    App::getInstance()->getNotifier()->notifyNewVersionAvailable(
      ::Utils::coreStringToAppString(version),
      ::Utils::coreStringToAppString(url)
    );
}
