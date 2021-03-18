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

#include <QMutex>
#include <QtDebug>
#include <QThread>
#include <QTimer>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

#include "CoreHandlers.hpp"
#include "CoreManager.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

CoreHandlers::CoreHandlers (CoreManager *coreManager) {
    Q_UNUSED(coreManager)
}

CoreHandlers::~CoreHandlers () {
}

// -----------------------------------------------------------------------------
void CoreHandlers::onAuthenticationRequested (
  const shared_ptr<linphone::Core> & core,
  const shared_ptr<linphone::AuthInfo> &authInfo,
  linphone::AuthMethod method
) {
  Q_UNUSED(core)
  Q_UNUSED(method)
  if( authInfo ) {
      emit authenticationRequested(authInfo);
  }
}

void CoreHandlers::onCallEncryptionChanged (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Call> &call,
  bool,
  const string &
) {
  emit callEncryptionChanged(call);
}

void CoreHandlers::onCallStateChanged (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Call> &call,
  linphone::Call::State state,
  const string &
) {
  emit callStateChanged(call, state);

  SettingsModel *settingsModel = CoreManager::getInstance()->getSettingsModel();
  if (
    call->getState() == linphone::Call::State::IncomingReceived && (
      !settingsModel->getAutoAnswerStatus() ||
      settingsModel->getAutoAnswerDelay() > 0
    )
  )
    App::getInstance()->getNotifier()->notifyReceivedCall(call);
}

void CoreHandlers::onCallStatsUpdated (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Call> &call,
  const shared_ptr<const linphone::CallStats> &stats
) {
  call->getData<CallModel>("call-model").updateStats(stats);
}

void CoreHandlers::onCallCreated(const shared_ptr<linphone::Core> &,
				  const shared_ptr<linphone::Call> &call) {
  emit callCreated(call);
}

void CoreHandlers::onConfiguringStatus(
  const std::shared_ptr<linphone::Core> & core,
  linphone::ConfiguringState status,
  const std::string & message){
  Q_UNUSED(core)
  emit setLastRemoteProvisioningState(status);
  if(status == linphone::ConfiguringState::Failed){
	  qWarning() << "Remote provisioning has failed and was removed : "<< QString::fromStdString(message);
	  core->setProvisioningUri("");
  }
}

void CoreHandlers::onDtmfReceived(
    const std::shared_ptr<linphone::Core> & lc,
    const std::shared_ptr<linphone::Call> & call,
    int dtmf) {
    Q_UNUSED(lc)
    Q_UNUSED(call)
    CoreManager::getInstance()->getCore()->playDtmf((char)dtmf, CallModel::DtmfSoundDelay);
}
void CoreHandlers::onGlobalStateChanged (
  const shared_ptr<linphone::Core> &core,
  linphone::GlobalState gstate,
  const string & message
) {
    Q_UNUSED(core)
    Q_UNUSED(message)
    switch(gstate){
        case linphone::GlobalState::On :
            qInfo() << "Core is running " << QString::fromStdString(message);
            emit coreStarted();
            break;
        case linphone::GlobalState::Off :
            qInfo() << "Core is stopped " << QString::fromStdString(message);
            emit coreStopped();
            break;
        case linphone::GlobalState::Startup : // Usefull to start core iterations
            qInfo() << "Core is starting " << QString::fromStdString(message);
            emit coreStarting();
            break;
        default:{}
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
  linphone::Core::LogCollectionUploadState state,
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
  const shared_ptr<linphone::Core> &core,
  const shared_ptr<linphone::ChatRoom> &chatRoom,
  const shared_ptr<linphone::ChatMessage> &message
) {
  const string contentType = message->getContentType();

  if (contentType == "text/plain" || contentType == "application/vnd.gsma.rcs-ft-http+xml") {
    emit messageReceived(message);

    // 1. Do not notify if chat is not activated.
    CoreManager *coreManager = CoreManager::getInstance();
    SettingsModel *settingsModel = coreManager->getSettingsModel();
    if (!settingsModel->getChatEnabled())
      return;

    // 2. Notify with Notification popup.
    const App *app = App::getInstance();
    if (!app->hasFocus() || !chatRoom->getLocalAddress()->weakEqual(coreManager->getAccountSettingsModel()->getUsedSipAddress()))
      app->getNotifier()->notifyReceivedMessage(message);

    // 3. Notify with sound.
    if (!settingsModel->getChatNotificationSoundEnabled())
      return;

    if (
      !app->hasFocus() ||
      !CoreManager::getInstance()->chatModelExists(
        Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly()),
        Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly())
      )
    )
      core->playLocal(Utils::appStringToCoreString(settingsModel->getChatNotificationSoundPath()));
  }
}

void CoreHandlers::onNotifyPresenceReceivedForUriOrTel (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Friend> &,
  const string &uriOrTel,
  const shared_ptr<const linphone::PresenceModel> &presenceModel
) {
  emit presenceReceived(Utils::coreStringToAppString(uriOrTel), presenceModel);
}

void CoreHandlers::onNotifyPresenceReceived (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Friend> &linphoneFriend
) {
  // Ignore friend without vcard because the `contact-model` data doesn't exist.
  if (linphoneFriend->getVcard() && linphoneFriend->dataExists("contact-model"))
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
  linphone::Call::State state
) {
  switch (state) {
    case linphone::Call::State::EarlyUpdatedByRemote:
    case linphone::Call::State::EarlyUpdating:
    case linphone::Call::State::Idle:
    case linphone::Call::State::IncomingEarlyMedia:
    case linphone::Call::State::IncomingReceived:
    case linphone::Call::State::OutgoingEarlyMedia:
    case linphone::Call::State::OutgoingRinging:
    case linphone::Call::State::Paused:
    case linphone::Call::State::PausedByRemote:
    case linphone::Call::State::Pausing:
    case linphone::Call::State::PushIncomingReceived:
    case linphone::Call::State::Referred:
    case linphone::Call::State::Released:
    case linphone::Call::State::Resuming:
    case linphone::Call::State::StreamsRunning:
    case linphone::Call::State::UpdatedByRemote:
    case linphone::Call::State::Updating:
      break; // Nothing.

    // 1. Init.
    case linphone::Call::State::OutgoingInit:
      qInfo() << QStringLiteral("Call transfer init.");
      break;

    // 2. In progress.
    case linphone::Call::State::OutgoingProgress:
      qInfo() << QStringLiteral("Call transfer in progress.");
      break;

    // 3. Done.
    case linphone::Call::State::Connected:
      qInfo() << QStringLiteral("Call transfer succeeded.");
      emit callTransferSucceeded(call);
      break;

    // 4. Error.
    case linphone::Call::State::End:
    case linphone::Call::State::Error:
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
  if (result == linphone::VersionUpdateCheckResult::NewVersionAvailable)
    App::getInstance()->getNotifier()->notifyNewVersionAvailable(
      Utils::coreStringToAppString(version),
      Utils::coreStringToAppString(url)
    );
}
void CoreHandlers::onEcCalibrationResult(
    const std::shared_ptr<linphone::Core> &,
    linphone::EcCalibratorStatus status,
    int delayMs
  ) {
  emit ecCalibrationResult(status, delayMs);
}
