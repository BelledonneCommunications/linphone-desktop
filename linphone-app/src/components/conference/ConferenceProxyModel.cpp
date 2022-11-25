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

#include <QDateTime>
#include <QtDebug>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/MediastreamerUtils.hpp"
#include "utils/Utils.hpp"

#include "ConferenceProxyModel.hpp"

// =============================================================================

using namespace std;

ConferenceProxyModel::ConferenceProxyModel (QObject *parent) : SortFilterProxyModel(parent) {
  mDeleteSourceModel = false;
  setSourceModel(CoreManager::getInstance()->getCallsListModel());
  emit conferenceChanged();

  QObject::connect(
    CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::callStateChanged,
    this, [this] { emit conferenceChanged(); });
}
// Show all paraticpants thar should be, will be or are still in conference
bool ConferenceProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  const CallModel *callModel = index.data().value<CallModel *>();
  return callModel->getCall() && (callModel->getCall()->getParams()->getLocalConferenceMode() || callModel->getCall()->getCurrentParams()->getLocalConferenceMode());
}
// -----------------------------------------------------------------------------

void ConferenceProxyModel::terminate () {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  core->terminateConference();

  for (const auto &call : core->getCalls()) {
    if (call->getParams()->getLocalConferenceMode())// Terminate all call where participants are or will be in conference
      call->terminate();
  }
}

// -----------------------------------------------------------------------------

void ConferenceProxyModel::startRecording () {
  if (mRecording)
    return;

  qInfo() << QStringLiteral("Start recording conference:") << this;

  CoreManager *coreManager = CoreManager::getInstance();
  mLastRecordFile = 
      QStringLiteral("%1%2.mkv")
        .arg(coreManager->getSettingsModel()->getSavedCallsFolder())
        .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss"));
  coreManager->getCore()->startConferenceRecording(Utils::appStringToCoreString(mLastRecordFile) );
  mRecording = true;

  emit recordingChanged(true);
}

void ConferenceProxyModel::stopRecording () {
  if (!mRecording)
    return;

  qInfo() << QStringLiteral("Stop recording conference:") << this;

  mRecording = false;
  
  CoreManager::getInstance()->getCore()->stopConferenceRecording();
  App::getInstance()->getNotifier()->notifyRecordingCompleted(mLastRecordFile);

  emit recordingChanged(false);
}

// -----------------------------------------------------------------------------

bool ConferenceProxyModel::getMicroMuted () const {
  return !CoreManager::getInstance()->getCore()->micEnabled();
}

void ConferenceProxyModel::setMicroMuted (bool status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  if (status == core->micEnabled()) {
    core->enableMic(!status);
    emit microMutedChanged(status);
  }
}

// -----------------------------------------------------------------------------

bool ConferenceProxyModel::getRecording () const {
  return mRecording;
}

// -----------------------------------------------------------------------------

float ConferenceProxyModel::getMicroVu () const {
  return MediastreamerUtils::computeVu(
    CoreManager::getInstance()->getCore()->getConferenceLocalInputVolume()
  );
}

// -----------------------------------------------------------------------------

void ConferenceProxyModel::leave () {
  CoreManager::getInstance()->getCore()->leaveConference();
  emit conferenceChanged();
}

void ConferenceProxyModel::join () {
  CoreManager::getInstance()->getCore()->enterConference();
  emit conferenceChanged();
}

bool ConferenceProxyModel::isInConference () const {
  return CoreManager::getInstance()->getCore()->isInConference();
}
