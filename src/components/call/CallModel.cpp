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
#include <QTimer>

#include "../../app/App.hpp"
#include "../../utils/LinphoneUtils.hpp"
#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "CallModel.hpp"

#define AUTO_ANSWER_OBJECT_NAME "auto-answer-timer"

using namespace std;

// =============================================================================

CallModel::CallModel (shared_ptr<linphone::Call> call) {
  Q_CHECK_PTR(call);
  mCall = call;
  mCall->setData("call-model", *this);

  updateIsInConference();

  // Deal with auto-answer.
  {
    SettingsModel *settings = CoreManager::getInstance()->getSettingsModel();

    if (settings->getAutoAnswerStatus()) {
      QTimer *timer = new QTimer(this);
      timer->setInterval(settings->getAutoAnswerDelay());
      timer->setSingleShot(true);
      timer->setObjectName(AUTO_ANSWER_OBJECT_NAME);

      QObject::connect(timer, &QTimer::timeout, this, &CallModel::acceptWithAutoAnswerDelay);
      timer->start();
    }
  }

  QObject::connect(
    CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::callStateChanged,
    this, &CallModel::handleCallStateChanged
  );
}

CallModel::~CallModel () {
  mCall->unsetData("call-model");
}

// -----------------------------------------------------------------------------

QString CallModel::getSipAddress () const {
  return ::Utils::coreStringToAppString(mCall->getRemoteAddress()->asStringUriOnly());
}

// -----------------------------------------------------------------------------

void CallModel::setRecordFile (shared_ptr<linphone::CallParams> &callParams) {
  callParams->setRecordFile(
    ::Utils::appStringToCoreString(
      QStringLiteral("%1%2.mkv")
      .arg(CoreManager::getInstance()->getSettingsModel()->getSavedVideosFolder())
      .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh:mm:ss"))
    )
  );
}

void CallModel::updateStats (const shared_ptr<const linphone::CallStats> &callStats) {
  switch (callStats->getType()) {
    case linphone::StreamTypeText:
    case linphone::StreamTypeUnknown:
      break;

    case linphone::StreamTypeAudio:
      updateStats(callStats, mAudioStats);
      break;
    case linphone::StreamTypeVideo:
      updateStats(callStats, mVideoStats);
      break;
  }

  emit statsUpdated();
}

// -----------------------------------------------------------------------------

void CallModel::notifyCameraFirstFrameReceived (unsigned int width, unsigned int height) {
  if (mNotifyCameraFirstFrameReceived) {
    mNotifyCameraFirstFrameReceived = false;
    emit cameraFirstFrameReceived(width, height);
  }
}

// -----------------------------------------------------------------------------

void CallModel::accept () {
  stopAutoAnswerTimer();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::CallParams> params = core->createCallParams(mCall);
  params->enableVideo(false);
  setRecordFile(params);

  App::smartShowWindow(App::getInstance()->getCallsWindow());
  mCall->acceptWithParams(params);
}

void CallModel::acceptWithVideo () {
  stopAutoAnswerTimer();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::CallParams> params = core->createCallParams(mCall);
  params->enableVideo(true);
  setRecordFile(params);

  App::smartShowWindow(App::getInstance()->getCallsWindow());
  mCall->acceptWithParams(params);
}

void CallModel::terminate () {
  CoreManager *core = CoreManager::getInstance();

  core->lockVideoRender();
  mCall->terminate();
  core->unlockVideoRender();
}

// -----------------------------------------------------------------------------

void CallModel::askForTransfer () {
  CoreManager::getInstance()->getCallsListModel()->askForTransfer(this);
}

bool CallModel::transferTo (const QString &sipAddress) {
  bool status = !!mCall->transfer(::Utils::appStringToCoreString(sipAddress));
  if (status)
    qWarning() << QStringLiteral("Unable to transfer: `%1`.").arg(sipAddress);
  return status;
}

// -----------------------------------------------------------------------------

void CallModel::acceptVideoRequest () {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::CallParams> params = core->createCallParams(mCall);
  params->enableVideo(true);

  mCall->acceptUpdate(params);
}

void CallModel::rejectVideoRequest () {
  mCall->acceptUpdate(mCall->getCurrentParams());
}

void CallModel::takeSnapshot () {
  static QString oldName;
  QString newName = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh:mm:ss") + ".jpg";

  if (newName == oldName) {
    qWarning() << QStringLiteral("Unable to take snapshot. Wait one second.");
    return;
  }

  oldName = newName;

  qInfo() << QStringLiteral("Take snapshot of call:") << this;

  const QString filePath = CoreManager::getInstance()->getSettingsModel()->getSavedScreenshotsFolder() + newName;
  mCall->takeVideoSnapshot(::Utils::appStringToCoreString(filePath));
  App::getInstance()->getNotifier()->notifySnapshotWasTaken(filePath);
}

void CallModel::startRecording () {
  if (mRecording)
    return;

  qInfo() << QStringLiteral("Start recording call:") << this;

  mCall->startRecording();
  mRecording = true;

  emit recordingChanged(true);
}

void CallModel::stopRecording () {
  if (!mRecording)
    return;

  qInfo() << QStringLiteral("Stop recording call:") << this;

  mRecording = false;
  mCall->stopRecording();

  App::getInstance()->getNotifier()->notifyRecordingCompleted(
    ::Utils::coreStringToAppString(mCall->getParams()->getRecordFile())
  );

  emit recordingChanged(false);
}

// -----------------------------------------------------------------------------

void CallModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::CallState state) {
  if (call != mCall)
    return;

  updateIsInConference();

  switch (state) {
    case linphone::CallStateError:
    case linphone::CallStateEnd:
      setCallErrorFromReason(call->getReason());
      stopAutoAnswerTimer();
      mPausedByRemote = false;
      break;

    case linphone::CallStateConnected:
    case linphone::CallStateRefered:
    case linphone::CallStateReleased:
    case linphone::CallStateStreamsRunning:
      mPausedByRemote = false;
      break;

    case linphone::CallStatePausedByRemote:
      mNotifyCameraFirstFrameReceived = true;
      mPausedByRemote = true;
      break;

    case linphone::CallStatePausing:
      mNotifyCameraFirstFrameReceived = true;
      mPausedByUser = true;
      break;

    case linphone::CallStateResuming:
      mPausedByUser = false;
      break;

    case linphone::CallStateUpdatedByRemote:
      if (!mCall->getCurrentParams()->videoEnabled() && mCall->getRemoteParams()->videoEnabled()) {
        mCall->deferUpdate();
        emit videoRequested();
      }

      break;

    case linphone::CallStateIdle:
    case linphone::CallStateIncomingReceived:
    case linphone::CallStateOutgoingInit:
    case linphone::CallStateOutgoingProgress:
    case linphone::CallStateOutgoingRinging:
    case linphone::CallStateOutgoingEarlyMedia:
    case linphone::CallStatePaused:
    case linphone::CallStateIncomingEarlyMedia:
    case linphone::CallStateUpdating:
    case linphone::CallStateEarlyUpdatedByRemote:
    case linphone::CallStateEarlyUpdating:
      break;
  }

  emit securityUpdated();
  emit statusChanged(getStatus());
}

// -----------------------------------------------------------------------------

void CallModel::updateIsInConference () {
  if (mIsInConference != mCall->getParams()->getLocalConferenceMode()) {
    mIsInConference = !mIsInConference;
    emit isInConferenceChanged(mIsInConference);
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

// -----------------------------------------------------------------------------

CallModel::CallStatus CallModel::getStatus () const {
  switch (mCall->getState()) {
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
      return mPausedByRemote ? CallStatusPaused : CallStatusConnected;

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

  return mCall->getDir() == linphone::CallDirIncoming ? CallStatusIncoming : CallStatusOutgoing;
}

// -----------------------------------------------------------------------------

void CallModel::acceptWithAutoAnswerDelay () {
  // Use auto-answer if activated and it's the only call.
  CoreManager *coreManager = CoreManager::getInstance();
  if (coreManager->getSettingsModel()->getAutoAnswerStatus() && coreManager->getCore()->getCallsNb() == 1)
    accept();
}

// -----------------------------------------------------------------------------

QString CallModel::getCallError () const {
  return mCallError;
}

void CallModel::setCallErrorFromReason (linphone::Reason reason) {
  switch (reason) {
    case linphone::ReasonDeclined:
      mCallError = tr("callErrorDeclined");
      break;
    case linphone::ReasonNotFound:
      mCallError = tr("callErrorNotFound");
      break;
    case linphone::ReasonBusy:
      mCallError = tr("callErrorBusy");
      break;
    case linphone::ReasonNotAcceptable:
      mCallError = tr("callErrorNotAcceptable");
      break;
    default:
      break;
  }

  if (!mCallError.isEmpty())
    qInfo() << QStringLiteral("Call terminated with error (%1):").arg(mCallError) << this;

  emit callErrorChanged(mCallError);
}

// -----------------------------------------------------------------------------

int CallModel::getDuration () const {
  return mCall->getDuration();
}

float CallModel::getQuality () const {
  return mCall->getCurrentQuality();
}

// -----------------------------------------------------------------------------

float CallModel::getMicroVu () const {
  return LinphoneUtils::computeVu(mCall->getRecordVolume());
}

float CallModel::getSpeakerVu () const {
  return LinphoneUtils::computeVu(mCall->getPlayVolume());
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
  return mPausedByUser;
}

void CallModel::setPausedByUser (bool status) {
  switch (mCall->getState()) {
    case linphone::CallStateConnected:
    case linphone::CallStateStreamsRunning:
    case linphone::CallStatePaused:
    case linphone::CallStatePausedByRemote:
      break;
    default: return;
  }

  if (status) {
    if (!mPausedByUser)
      mCall->pause();

    return;
  }

  if (mPausedByUser)
    mCall->resume();
}

// -----------------------------------------------------------------------------

bool CallModel::getVideoEnabled () const {
  shared_ptr<const linphone::CallParams> params = mCall->getCurrentParams();
  return params && params->videoEnabled() && getStatus() == CallStatusConnected;
}

void CallModel::setVideoEnabled (bool status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  if (!core->videoSupported()) {
    qWarning() << QStringLiteral("Unable to update video call property. (Video not supported.)");
    return;
  }

  switch (mCall->getState()) {
    case linphone::CallStateConnected:
    case linphone::CallStateStreamsRunning:
      break;
    default: return;
  }

  if (status == getVideoEnabled())
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(mCall);
  params->enableVideo(status);

  mCall->update(params);
}

// -----------------------------------------------------------------------------

bool CallModel::getUpdating () const {
  switch (mCall->getState()) {
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
  return mRecording;
}

// -----------------------------------------------------------------------------

void CallModel::sendDtmf (const QString &dtmf) {
  qInfo() << QStringLiteral("Send dtmf: `%1`.").arg(dtmf);
  mCall->sendDtmf(dtmf.constData()[0].toLatin1());
}

// -----------------------------------------------------------------------------

void CallModel::verifyAuthenticationToken (bool verify) {
  mCall->setAuthenticationTokenVerified(verify);
  emit securityUpdated();
}

// -----------------------------------------------------------------------------

CallModel::CallEncryption CallModel::getEncryption () const {
  return static_cast<CallEncryption>(mCall->getCurrentParams()->getMediaEncryption());
}

bool CallModel::isSecured () const {
  shared_ptr<const linphone::CallParams> params = mCall->getCurrentParams();
  linphone::MediaEncryption encryption = params->getMediaEncryption();
  return (
    encryption == linphone::MediaEncryptionZRTP && mCall->getAuthenticationTokenVerified()
  ) || encryption == linphone::MediaEncryptionSRTP || encryption == linphone::MediaEncryptionDTLS;
}

// -----------------------------------------------------------------------------

QString CallModel::getLocalSas () const {
  QString token = ::Utils::coreStringToAppString(mCall->getAuthenticationToken());
  return mCall->getDir() == linphone::CallDirIncoming ? token.left(2).toUpper() : token.right(2).toUpper();
}

QString CallModel::getRemoteSas () const {
  QString token = ::Utils::coreStringToAppString(mCall->getAuthenticationToken());
  return mCall->getDir() != linphone::CallDirIncoming ? token.left(2).toUpper() : token.right(2).toUpper();
}

// -----------------------------------------------------------------------------

QString CallModel::getSecuredString () const {
  switch (mCall->getCurrentParams()->getMediaEncryption()) {
    case linphone::MediaEncryptionSRTP:
      return QStringLiteral("SRTP");
    case linphone::MediaEncryptionZRTP:
      return QStringLiteral("ZRTP");
    case linphone::MediaEncryptionDTLS:
      return QStringLiteral("DTLS");
    case linphone::MediaEncryptionNone:
      break;
  }

  return QString("");
}

// -----------------------------------------------------------------------------

QVariantList CallModel::getAudioStats () const {
  return mAudioStats;
}

QVariantList CallModel::getVideoStats () const {
  return mVideoStats;
}

// -----------------------------------------------------------------------------

inline QVariantMap createStat (const QString &key, const QString &value) {
  QVariantMap m;
  m["key"] = key;
  m["value"] = value;
  return m;
}

void CallModel::updateStats (const shared_ptr<const linphone::CallStats> &callStats, QVariantList &statsList) {
  shared_ptr<const linphone::CallParams> params = mCall->getCurrentParams();
  shared_ptr<const linphone::PayloadType> payloadType;

  switch (callStats->getType()) {
    case linphone::StreamTypeAudio:
      payloadType = params->getUsedAudioPayloadType();
      break;
    case linphone::StreamTypeVideo:
      payloadType = params->getUsedVideoPayloadType();
      break;
    default:
      return;
  }

  QString family;
  switch (callStats->getIpFamilyOfRemote()) {
    case linphone::AddressFamilyInet:
      family = QStringLiteral("IPv4");
      break;
    case linphone::AddressFamilyInet6:
      family = QStringLiteral("IPv6");
      break;
    default:
      family = QStringLiteral("Unknown");
      break;
  }

  statsList.clear();

  statsList << ::createStat(tr("callStatsCodec"), payloadType
    ? QStringLiteral("%1 / %2kHz").arg(Utils::coreStringToAppString(payloadType->getMimeType())).arg(payloadType->getClockRate() / 1000)
    : QString(""));
  statsList << ::createStat(tr("callStatsUploadBandwidth"), QStringLiteral("%1 kbits/s").arg(int(callStats->getUploadBandwidth())));
  statsList << ::createStat(tr("callStatsDownloadBandwidth"), QStringLiteral("%1 kbits/s").arg(int(callStats->getDownloadBandwidth())));
  statsList << ::createStat(tr("callStatsIceState"), iceStateToString(callStats->getIceState()));
  statsList << ::createStat(tr("callStatsIpFamily"), family);
  statsList << ::createStat(tr("callStatsSenderLossRate"), QStringLiteral("%1 %").arg(callStats->getSenderLossRate()));
  statsList << ::createStat(tr("callStatsReceiverLossRate"), QStringLiteral("%1 %").arg(callStats->getReceiverLossRate()));

  switch (callStats->getType()) {
    case linphone::StreamTypeAudio:
      statsList << ::createStat(tr("callStatsJitterBuffer"), QStringLiteral("%1 ms").arg(callStats->getJitterBufferSizeMs()));
      break;
    case linphone::StreamTypeVideo: {
      const QString sentVideoDefinitionName = ::Utils::coreStringToAppString(params->getSentVideoDefinition()->getName());
      const QString sentVideoDefinition = QStringLiteral("%1x%2")
        .arg(params->getSentVideoDefinition()->getWidth())
        .arg(params->getSentVideoDefinition()->getHeight());

      statsList << ::createStat(tr("callStatsSentVideoDefinition"), sentVideoDefinition == sentVideoDefinitionName
        ? sentVideoDefinition
        : QStringLiteral("%1 (%2)").arg(sentVideoDefinition).arg(sentVideoDefinitionName));

      const QString receivedVideoDefinitionName = ::Utils::coreStringToAppString(params->getReceivedVideoDefinition()->getName());
      const QString receivedVideoDefinition = QString("%1x%2")
        .arg(params->getReceivedVideoDefinition()->getWidth())
        .arg(params->getReceivedVideoDefinition()->getHeight());

      statsList << ::createStat(tr("callStatsReceivedVideoDefinition"), receivedVideoDefinition == receivedVideoDefinitionName
        ? receivedVideoDefinition
        : QString("%1 (%2)").arg(receivedVideoDefinition).arg(receivedVideoDefinitionName));

      statsList << ::createStat(tr("callStatsReceivedFramerate"), QStringLiteral("%1 FPS").arg(params->getReceivedFramerate()));
      statsList << ::createStat(tr("callStatsSentFramerate"), QStringLiteral("%1 FPS").arg(params->getSentFramerate()));
    } break;

    default:
      break;
  }
}

// -----------------------------------------------------------------------------

QString CallModel::iceStateToString (linphone::IceState state) const {
  switch (state) {
    case linphone::IceStateNotActivated:
      return tr("iceStateNotActivated");
    case linphone::IceStateFailed:
      return tr("iceStateFailed");
    case linphone::IceStateInProgress:
      return tr("iceStateInProgress");
    case linphone::IceStateReflexiveConnection:
      return tr("iceStateReflexiveConnection");
    case linphone::IceStateHostConnection:
      return tr("iceStateHostConnection");
    case linphone::IceStateRelayConnection:
      return tr("iceStateRelayConnection");
  }

  return tr("iceStateInvalid");
}
