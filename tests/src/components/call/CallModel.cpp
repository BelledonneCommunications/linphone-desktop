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
        case linphone::CallStatePaused:
        case linphone::CallStateRefered:
        case linphone::CallStateReleased:
        case linphone::CallStateStreamsRunning:
          m_linphone_call_status = state;
          break;

        case linphone::CallStatePausedByRemote:
          if (m_linphone_call_status != linphone::CallStatePaused)
            m_linphone_call_status = state;
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

// -----------------------------------------------------------------------------

QString CallModel::getSipAddress () const {
  return ::Utils::linphoneStringToQString(m_linphone_call->getRemoteAddress()->asStringUriOnly());
}

CallModel::CallStatus CallModel::getStatus () const {
  switch (m_linphone_call_status) {
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
      return CallStatusPaused;

    default:
      break;
  }

  return m_linphone_call->getDir() == linphone::CallDirIncoming ? CallStatusIncoming : CallStatusOutgoing;
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
  return m_linphone_call_status == linphone::CallStatePaused;
}

void CallModel::setPausedByUser (bool status) {
  bool paused = getPausedByUser();

  if (status) {
    if (!paused)
      CoreManager::getInstance()->getCore()->pauseCall(m_linphone_call);

    return;
  }

  if (paused)
    CoreManager::getInstance()->getCore()->resumeCall(m_linphone_call);
}

bool CallModel::getVideoInputEnabled () const {
  // TODO
  return false;
}

void CallModel::setVideoInputEnabled (bool status) {
  // TODO
}

bool CallModel::getVideoOutputEnabled () const {
  // TODO
  return false;
}

void CallModel::setVideoOutputEnabled (bool status) {
  // TODO
}
