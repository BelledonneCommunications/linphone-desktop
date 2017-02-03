/*
 * CallModel.cpp
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

#include <QDateTime>
#include <QtDebug>

#include "../../app/Paths.hpp"
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

void CallModel::setRecordFile (shared_ptr<linphone::CallParams> &call_params) {
  call_params->setRecordFile(
    Paths::getCapturesDirPath() +
    ::Utils::qStringToLinphoneString(
      QDateTime::currentDateTime().toString("yyyy-MM-dd_hh:mm:ss")
    ) + ".mkv"
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
  shared_ptr<linphone::CallParams> params = CoreManager::getInstance()->getCore()->createCallParams(m_linphone_call);
  params->enableVideo(true);

  CoreManager::getInstance()->getCore()->acceptCallUpdate(m_linphone_call, params);
}

void CallModel::rejectVideoRequest () {
  CoreManager::getInstance()->getCore()->acceptCallUpdate(m_linphone_call, m_linphone_call->getCurrentParams());
}

void CallModel::takeSnapshot () {
  static QString old_name;
  QString new_name = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh:mm:ss") + ".jpg";

  if (new_name == old_name) {
    qWarning() << "Unable to take snapshot. Wait one second.";
    return;
  }

  old_name = new_name;

  qInfo() << "Take snapshot of call:" << &m_linphone_call;

  m_linphone_call->takeVideoSnapshot(
    Paths::getCapturesDirPath() + ::Utils::qStringToLinphoneString(new_name)
  );
}

void CallModel::startRecording () {
  if (m_recording)
    return;

  qInfo() << "Start recording call:" << &m_linphone_call;

  m_linphone_call->startRecording();
  m_recording = true;

  emit recordingChanged(true);
}

void CallModel::stopRecording () {
  if (m_recording) {
    qInfo() << "Stop recording call:" << &m_linphone_call;

    m_recording = false;
    m_linphone_call->stopRecording();

    emit recordingChanged(false);
  }
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

bool CallModel::getUpdating () const {
  switch (m_linphone_call->getState()) {
    case linphone::CallStateConnected:
    case linphone::CallStateStreamsRunning:
    case linphone::CallStatePaused:
    case linphone::CallStatePausedByRemote:
      return false;

    default:
      break;
  }

  return true;
}

bool CallModel::getRecording () const {
  return m_recording;
}
