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
#include <QTimer>

#include "../../app/App.hpp"
#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "CallModel.hpp"

#define AUTO_ANSWER_OBJECT_NAME "auto-answer-timer"

using namespace std;

// =============================================================================

CallModel::CallModel (shared_ptr<linphone::Call> linphone_call) {
  Q_ASSERT(linphone_call != nullptr);
  m_linphone_call = linphone_call;

  // Deal with auto-answer.
  {
    SettingsModel *settings = CoreManager::getInstance()->getSettingsModel();

    if (settings->getAutoAnswerStatus()) {
      QTimer *timer = new QTimer(this);
      timer->setInterval(settings->getAutoAnswerDelay());
      timer->setSingleShot(true);
      timer->setObjectName(AUTO_ANSWER_OBJECT_NAME);

      QObject::connect(timer, &QTimer::timeout, this, &CallModel::accept);
      timer->start();
    }
  }

  QObject::connect(
    &(*CoreManager::getInstance()->getHandlers()), &CoreHandlers::callStateChanged,
    this, [this](const std::shared_ptr<linphone::Call> &call, linphone::CallState state) {
      if (call != m_linphone_call)
        return;

      switch (state) {
        case linphone::CallStateEnd:
        case linphone::CallStateError:
          stopAutoAnswerTimer();
          m_paused_by_remote = false;
          break;

        case linphone::CallStateConnected:
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

        case linphone::CallStateUpdatedByRemote:
          if (
            !m_linphone_call->getCurrentParams()->videoEnabled() &&
            m_linphone_call->getRemoteParams()->videoEnabled()
          ) {
            m_linphone_call->deferUpdate();
            emit videoRequested();
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
    ::Utils::qStringToLinphoneString(
      CoreManager::getInstance()->getSettingsModel()->getSavedVideosFolder() +
      QDateTime::currentDateTime().toString("yyyy-MM-dd_hh:mm:ss")
    ) + ".mkv"
  );
}

// -----------------------------------------------------------------------------

void CallModel::accept () {
  stopAutoAnswerTimer();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::CallParams> params = core->createCallParams(m_linphone_call);
  params->enableVideo(false);
  setRecordFile(params);

  App::getInstance()->getCallsWindow()->show();
  m_linphone_call->acceptWithParams(params);
}

void CallModel::acceptWithVideo () {
  stopAutoAnswerTimer();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::CallParams> params = core->createCallParams(m_linphone_call);
  params->enableVideo(true);
  setRecordFile(params);

  App::getInstance()->getCallsWindow()->show();
  m_linphone_call->acceptWithParams(params);
}

void CallModel::terminate () {
  CoreManager *core = CoreManager::getInstance();

  core->lockVideoRender();
  m_linphone_call->terminate();
  core->unlockVideoRender();
}

void CallModel::transfer () {
  // TODO
}

void CallModel::acceptVideoRequest () {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::CallParams> params = core->createCallParams(m_linphone_call);
  params->enableVideo(true);

  m_linphone_call->acceptUpdate(params);
}

void CallModel::rejectVideoRequest () {
  m_linphone_call->acceptUpdate(m_linphone_call->getCurrentParams());
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
    ::Utils::qStringToLinphoneString(
      CoreManager::getInstance()->getSettingsModel()->getSavedScreenshotsFolder() + new_name
    )
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

void CallModel::stopAutoAnswerTimer () const {
  QTimer *timer = findChild<QTimer *>(AUTO_ANSWER_OBJECT_NAME, Qt::FindDirectChildrenOnly);
  if (timer) {
    timer->stop();
    timer->deleteLater();
  }
}

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

// -----------------------------------------------------------------------------

int CallModel::getDuration () const {
  return m_linphone_call->getDuration();
}

float CallModel::getQuality () const {
  return m_linphone_call->getCurrentQuality();
}

// -----------------------------------------------------------------------------

#define VU_MIN (-20.f)
#define VU_MAX (4.f)

inline float computeVu (float volume) {
  if (volume < VU_MIN)
    return 0.f;
  if (volume > VU_MAX)
    return 1.f;

  return (volume - VU_MIN) / (VU_MAX - VU_MIN);
}

float CallModel::getMicroVu () const {
  return computeVu(m_linphone_call->getRecordVolume());
}

float CallModel::getSpeakerVu () const {
  return computeVu(m_linphone_call->getPlayVolume());
}

// -----------------------------------------------------------------------------

bool CallModel::getMicroMuted () const {
  return !CoreManager::getInstance()->getCore()->micEnabled();
}

void CallModel::setMicroMuted (bool status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  if (status == core->micEnabled()) {
    core->enableMic(!status);
    emit microMutedChanged(status);
  }
}

// -----------------------------------------------------------------------------

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
      m_linphone_call->pause();

    return;
  }

  if (m_paused_by_user)
    m_linphone_call->resume();
}

// -----------------------------------------------------------------------------

bool CallModel::getVideoEnabled () const {
  shared_ptr<const linphone::CallParams> params = m_linphone_call->getCurrentParams();
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

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::CallParams> params = core->createCallParams(m_linphone_call);
  params->enableVideo(status);

  m_linphone_call->update(params);
}

// -----------------------------------------------------------------------------

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
