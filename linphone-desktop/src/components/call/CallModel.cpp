#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "CallModel.hpp"

// =============================================================================

CallModel::CallModel (shared_ptr<linphone::Call> linphone_call) {
  m_linphone_call = linphone_call;

  QObject::connect(
    &(*CoreManager::getInstance()->getHandlers()), &CoreHandlers::callStateChanged,
    this, [this](const std::shared_ptr<linphone::Call> &call, linphone::CallState state) {
      if (call != m_linphone_call)
        return;

      switch (state) {
        case linphone::CallStateConnected:
        case linphone::CallStateEnd:
        case linphone::CallStateError:
        case linphone::CallStateRefered:
        case linphone::CallStateReleased:
        case linphone::CallStateStreamsRunning:
          m_paused_by_remote = false;
          break;

        case linphone::CallStatePausedByRemote:
          m_paused_by_remote = true;
          break;

        case linphone::CallStatePausing:
          m_paused_by_user = true;
          break;

        case linphone::CallStateResuming:
          m_paused_by_user = false;
          break;

        case linphone::CallStateUpdatedByRemote: {
          shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

          if (
            !m_linphone_call->getCurrentParams()->videoEnabled() &&
            m_linphone_call->getRemoteParams()->videoEnabled()
          ) {
            CoreManager::getInstance()->getCore()->deferCallUpdate(m_linphone_call);
            emit videoRequested();
          }
        }

        break;

        default:
          break;
      }

      emit statusChanged(getStatus());
    }
  );
}

// -----------------------------------------------------------------------------

void CallModel::accept () {
  CoreManager::getInstance()->getCore()->acceptCall(m_linphone_call);
}

void CallModel::acceptWithVideo () {
  // TODO
}

void CallModel::terminate () {
  CoreManager::getInstance()->getCore()->terminateCall(m_linphone_call);
}

void CallModel::transfer () {
  // TODO
}

void CallModel::acceptVideoRequest () {
  shared_ptr<linphone::CallParams> params = m_linphone_call->getCurrentParams()->copy();
  params->enableVideo(true);
  CoreManager::getInstance()->getCore()->acceptCallUpdate(m_linphone_call, params);
}

void CallModel::rejectVideoRequest () {
  CoreManager::getInstance()->getCore()->acceptCallUpdate(m_linphone_call, m_linphone_call->getCurrentParams());
}

// -----------------------------------------------------------------------------

QString CallModel::getSipAddress () const {
  return ::Utils::linphoneStringToQString(m_linphone_call->getRemoteAddress()->asStringUriOnly());
}

CallModel::CallStatus CallModel::getStatus () const {
  switch (m_linphone_call->getState()) {
    case linphone::CallStateConnected:
    case linphone::CallStateStreamsRunning:
      return CallStatusConnected;

    case linphone::CallStateEnd:
    case linphone::CallStateError:
    case linphone::CallStateRefered:
    case linphone::CallStateReleased:
      return CallStatusEnded;

    case linphone::CallStatePaused:
    case linphone::CallStatePausedByRemote:
    case linphone::CallStatePausing:
    case linphone::CallStateResuming:
      return CallStatusPaused;

    case linphone::CallStateUpdating:
    case linphone::CallStateUpdatedByRemote:
      return m_paused_by_remote ? CallStatusPaused : CallStatusConnected;

    case linphone::CallStateEarlyUpdatedByRemote:
    case linphone::CallStateEarlyUpdating:
    case linphone::CallStateIdle:
    case linphone::CallStateIncomingEarlyMedia:
    case linphone::CallStateIncomingReceived:
    case linphone::CallStateOutgoingEarlyMedia:
    case linphone::CallStateOutgoingInit:
    case linphone::CallStateOutgoingProgress:
    case linphone::CallStateOutgoingRinging:
      break;
  }

  return m_linphone_call->getDir() == linphone::CallDirIncoming ? CallStatusIncoming : CallStatusOutgoing;
}

int CallModel::getDuration () const {
  return m_linphone_call->getDuration();
}

float CallModel::getQuality () const {
  return m_linphone_call->getCurrentQuality();
}

bool CallModel::getMicroMuted () const {
  return m_micro_muted;
}

void CallModel::setMicroMuted (bool status) {
  if (m_micro_muted != status) {
    m_micro_muted = status;

    shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
    if (m_micro_muted == core->micEnabled())
      core->enableMic(!m_micro_muted);

    emit microMutedChanged(m_micro_muted);
  }
}

bool CallModel::getPausedByUser () const {
  return m_paused_by_user;
}

void CallModel::setPausedByUser (bool status) {
  switch (m_linphone_call->getState()) {
    case linphone::CallStateConnected:
    case linphone::CallStateStreamsRunning:
    case linphone::CallStatePaused:
    case linphone::CallStatePausedByRemote:
      break;
    default: return;
  }

  if (status) {
    if (!m_paused_by_user)
      CoreManager::getInstance()->getCore()->pauseCall(m_linphone_call);

    return;
  }

  if (m_paused_by_user)
    CoreManager::getInstance()->getCore()->resumeCall(m_linphone_call);
}

bool CallModel::getVideoEnabled () const {
  shared_ptr<linphone::CallParams> params = m_linphone_call->getCurrentParams();
  return params && params->videoEnabled() && getStatus() == CallStatusConnected;
}

void CallModel::setVideoEnabled (bool status) {
  switch (m_linphone_call->getState()) {
    case linphone::CallStateConnected:
    case linphone::CallStateStreamsRunning:
      break;
    default: return;
  }

  if (status == getVideoEnabled())
    return;

  shared_ptr<linphone::CallParams> params = CoreManager::getInstance()->getCore()->createCallParams(m_linphone_call);
  params->enableVideo(status);

  CoreManager::getInstance()->getCore()->updateCall(m_linphone_call, params);
}
