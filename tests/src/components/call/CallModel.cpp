#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "CallModel.hpp"

// =============================================================================

CallModel::CallModel (shared_ptr<linphone::Call> linphone_call) {
  m_linphone_call = linphone_call;
}

// -----------------------------------------------------------------------------

void CallModel::acceptAudioCall () {
  CoreManager::getInstance()->getCore()->acceptCall(m_linphone_call);
}

void CallModel::terminateCall () {
  CoreManager::getInstance()->getCore()->terminateCall(m_linphone_call);
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
      return CallStatusPaused;

    default:
      break;
  }

  return m_linphone_call->getDir() == linphone::CallDirIncoming ? CallStatusIncoming : CallStatusOutgoing;
}

bool CallModel::getPausedByUser () const {
  return m_linphone_call->getState() == linphone::CallStatePaused;
}

void CallModel::setPausedByUser (bool status) {
  bool paused = getPausedByUser();

  if (status) {
    if (!paused) {
      CoreManager::getInstance()->getCore()->pauseCall(m_linphone_call);
      emit pausedByUserChanged(true);
    }

    return;
  }

  if (paused) {
    CoreManager::getInstance()->getCore()->resumeCall(m_linphone_call);
    emit pausedByUserChanged(false);
  }
}
