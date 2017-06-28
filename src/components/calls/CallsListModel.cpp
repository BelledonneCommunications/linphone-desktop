/*
 * CallsListModel.cpp
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

#include <QTimer>

#include "../../app/App.hpp"
#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "CallsListModel.hpp"

/* Delay before removing call in ms. */
#define DELAY_BEFORE_REMOVE_CALL 3000

using namespace std;

// =============================================================================

inline int findCallIndex (QList<CallModel *> &list, const shared_ptr<linphone::Call> &call) {
  auto it = find_if(list.begin(), list.end(), [call](CallModel *callModel) {
        return call == callModel->getCall();
      });

  Q_ASSERT(it != list.end());

  return static_cast<int>(distance(list.begin(), it));
}

inline int findCallIndex (QList<CallModel *> &list, const CallModel &callModel) {
  return ::findCallIndex(list, callModel.getCall());
}

// -----------------------------------------------------------------------------

CallsListModel::CallsListModel (QObject *parent) : QAbstractListModel(parent) {
  mCoreHandlers = CoreManager::getInstance()->getHandlers();
  QObject::connect(
    mCoreHandlers.get(), &CoreHandlers::callStateChanged,
    this, &CallsListModel::handleCallStateChanged
  );
}

int CallsListModel::rowCount (const QModelIndex &) const {
  return mList.count();
}

QHash<int, QByteArray> CallsListModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$call";
  return roles;
}

QVariant CallsListModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mList.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(mList[row]);

  return QVariant();
}

// -----------------------------------------------------------------------------

void CallsListModel::askForTransfer (CallModel *callModel) {
  emit callTransferAsked(callModel);
}

// -----------------------------------------------------------------------------

void CallsListModel::launchAudioCall (const QString &sipUri) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  shared_ptr<linphone::Address> address = core->interpretUrl(::Utils::appStringToCoreString(sipUri));
  if (!address)
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
  params->enableVideo(false);
  CallModel::setRecordFile(params);

  core->inviteAddressWithParams(address, params);
}

void CallsListModel::launchVideoCall (const QString &sipUri) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  if (!core->videoSupported()) {
    qWarning() << QStringLiteral("Unable to launch video call. (Video not supported.) Launching audio call...");
    launchAudioCall(sipUri);
    return;
  }

  shared_ptr<linphone::Address> address = core->interpretUrl(::Utils::appStringToCoreString(sipUri));
  if (!address)
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
  params->enableEarlyMediaSending(true);
  params->enableVideo(true);
  CallModel::setRecordFile(params);

  core->inviteAddressWithParams(address, params);
}

// -----------------------------------------------------------------------------

int CallsListModel::getRunningCallsNumber () const {
  return CoreManager::getInstance()->getCore()->getCallsNb();
}

void CallsListModel::terminateAllCalls () const {
  CoreManager::getInstance()->getCore()->terminateAllCalls();
}

// -----------------------------------------------------------------------------

void CallsListModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::CallState state) {
  switch (state) {
    case linphone::CallStateIncomingReceived:
    case linphone::CallStateOutgoingInit:
      addCall(call);
      break;

    case linphone::CallStateEnd:
    case linphone::CallStateError:
      removeCall(call);
      break;

    case linphone::CallStateStreamsRunning: {
      int index = ::findCallIndex(mList, call);
      emit callRunning(index, &call->getData<CallModel>("call-model"));
    } break;

    default:
      break;
  }
}

bool CallsListModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool CallsListModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mList.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i)
    mList.takeAt(row)->deleteLater();

  endRemoveRows();

  return true;
}

// -----------------------------------------------------------------------------

void CallsListModel::addCall (const shared_ptr<linphone::Call> &call) {
  if (call->getDir() == linphone::CallDirOutgoing)
    App::smartShowWindow(App::getInstance()->getCallsWindow());

  CallModel *callModel = new CallModel(call);
  qInfo() << QStringLiteral("Add call:") << callModel;
  App::getInstance()->getEngine()->setObjectOwnership(callModel, QQmlEngine::CppOwnership);

  // This connection is (only) useful for `CallsListProxyModel`.
  QObject::connect(callModel, &CallModel::isInConferenceChanged, this, [this, callModel](bool) {
      int id = ::findCallIndex(mList, *callModel);
      emit dataChanged(index(id, 0), index(id, 0));
    });

  int row = mList.count();

  beginInsertRows(QModelIndex(), row, row);
  mList << callModel;
  endInsertRows();
}

void CallsListModel::removeCall (const shared_ptr<linphone::Call> &call) {
  CallModel *callModel;

  try {
    callModel = &call->getData<CallModel>("call-model");
  } catch (const out_of_range &) {
    // The call model not exists because the linphone call state
    // `CallStateIncomingReceived`/`CallStateOutgoingInit` was not notified.
    qWarning() << QStringLiteral("Unable to found linphone call:") << call.get();
    return;
  }

  QTimer::singleShot(DELAY_BEFORE_REMOVE_CALL, this, [this, callModel] {
    removeCallCb(callModel);
  });
}

void CallsListModel::removeCallCb (CallModel *callModel) {
  qInfo() << QStringLiteral("Removing call:") << callModel;

  int index = mList.indexOf(callModel);
  if (index == -1 || !removeRow(index))
    qWarning() << QStringLiteral("Unable to remove call:") << callModel;
}
