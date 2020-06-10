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

#include "components/call/CallModel.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/LinphoneUtils.hpp"
#include "utils/MediastreamerUtils.hpp"
#include "utils/Utils.hpp"

#include "ConferenceModel.hpp"

// =============================================================================

using namespace std;

ConferenceModel::ConferenceModel (QObject *parent) : QSortFilterProxyModel(parent) {
  QObject::connect(this, &ConferenceModel::rowsRemoved, [this] { // Warning : called before model remove its items
    emit countChanged(rowCount());
  });
  QObject::connect(this, &ConferenceModel::rowsInserted, [this] {
    emit countChanged(rowCount());
  });
  setSourceModel(CoreManager::getInstance()->getCallsListModel());
  emit conferenceChanged();

  QObject::connect(
    CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::callStateChanged,
    this, [this] { emit conferenceChanged(); });
}
// Show all paraticpants thar should be, will be or are still in conference
bool ConferenceModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  const CallModel *callModel = index.data().value<CallModel *>();
  return callModel->getCall()->getParams()->getLocalConferenceMode() || callModel->getCall()->getCurrentParams()->getLocalConferenceMode();
}
// -----------------------------------------------------------------------------

void ConferenceModel::terminate () {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  core->terminateConference();

  for (const auto &call : core->getCalls()) {
    if (call->getParams()->getLocalConferenceMode())// Terminate all call where participants are or will be in conference
      call->terminate();
  }
}

// -----------------------------------------------------------------------------

void ConferenceModel::startRecording () {
  if (mRecording)
    return;

  qInfo() << QStringLiteral("Start recording conference:") << this;

  CoreManager *coreManager = CoreManager::getInstance();
  coreManager->getCore()->startConferenceRecording(
    Utils::appStringToCoreString(
      QStringLiteral("%1%2.mkv")
        .arg(coreManager->getSettingsModel()->getSavedCallsFolder())
        .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss"))
    )
  );
  mRecording = true;

  emit recordingChanged(true);
}

void ConferenceModel::stopRecording () {
  if (!mRecording)
    return;

  qInfo() << QStringLiteral("Stop recording conference:") << this;

  mRecording = false;
  CoreManager::getInstance()->getCore()->stopConferenceRecording();

  emit recordingChanged(false);
}

// -----------------------------------------------------------------------------

bool ConferenceModel::getMicroMuted () const {
  return !CoreManager::getInstance()->getCore()->micEnabled();
}

void ConferenceModel::setMicroMuted (bool status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  if (status == core->micEnabled()) {
    core->enableMic(!status);
    emit microMutedChanged(status);
  }
}

// -----------------------------------------------------------------------------

bool ConferenceModel::getRecording () const {
  return mRecording;
}

// -----------------------------------------------------------------------------

float ConferenceModel::getMicroVu () const {
  return MediastreamerUtils::computeVu(
    CoreManager::getInstance()->getCore()->getConferenceLocalInputVolume()
  );
}

// -----------------------------------------------------------------------------

void ConferenceModel::leave () {
  CoreManager::getInstance()->getCore()->leaveConference();
  emit conferenceChanged();
}

void ConferenceModel::join () {
  CoreManager::getInstance()->getCore()->enterConference();
  emit conferenceChanged();
}

bool ConferenceModel::isInConference () const {
  return CoreManager::getInstance()->getCore()->isInConference();
}
