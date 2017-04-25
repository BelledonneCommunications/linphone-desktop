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

#include <QDebug>
#include <QTimer>

#include "../../app/App.hpp"
#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "CallsListModel.hpp"

/* Delay before removing call in ms. */
#define DELAY_BEFORE_REMOVE_CALL 3000

using namespace std;

// =============================================================================

inline QList<CallModel *>::iterator findCall (
  QList<CallModel *> &list,
  const shared_ptr<linphone::Call> &linphoneCall
) {
  return find_if(
    list.begin(), list.end(), [linphoneCall](CallModel *call) {
      return linphoneCall == call->getLinphoneCall();
    }
  );
}

// -----------------------------------------------------------------------------

CallsListModel::CallsListModel (QObject *parent) : QAbstractListModel(parent) {
  mCoreHandlers = CoreManager::getInstance()->getHandlers();
  QObject::connect(
    &(*mCoreHandlers), &CoreHandlers::callStateChanged,
    this, [this](const shared_ptr<linphone::Call> &linphoneCall, linphone::CallState state) {
      switch (state) {
        case linphone::CallStateIncomingReceived:
        case linphone::CallStateOutgoingInit:
          addCall(linphoneCall);
          break;

        case linphone::CallStateEnd:
        case linphone::CallStateError:
          removeCall(linphoneCall);
          break;

        case linphone::CallStateStreamsRunning: {
          int index = static_cast<int>(distance(mList.begin(), findCall(mList, linphoneCall)));
          emit callRunning(index, &linphoneCall->getData<CallModel>("call-model"));
        }
        break;

        default:
          break;
      }
    }
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

CallModel *CallsListModel::getCall (const shared_ptr<linphone::Call> &linphoneCall) const {
  auto it = findCall(*(const_cast<QList<CallModel *> *>(&mList)), linphoneCall);
  return it != mList.end() ? *it : nullptr;
}

// -----------------------------------------------------------------------------

void CallsListModel::launchAudioCall (const QString &sipUri) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> address = core->interpretUrl(::Utils::qStringToLinphoneString(sipUri));

  if (!address)
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
  params->enableVideo(false);
  CallModel::setRecordFile(params);

  core->inviteAddressWithParams(address, params);
}

void CallsListModel::launchVideoCall (const QString &sipUri) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> address = core->interpretUrl(::Utils::qStringToLinphoneString(sipUri));

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

void CallsListModel::addCall (const shared_ptr<linphone::Call> &linphoneCall) {
  if (linphoneCall->getDir() == linphone::CallDirOutgoing)
    Utils::smartShowWindow(App::getInstance()->getCallsWindow());

  CallModel *call = new CallModel(linphoneCall);

  qInfo() << "Add call:" << call;

  App::getInstance()->getEngine()->setObjectOwnership(call, QQmlEngine::CppOwnership);

  int row = mList.count();

  beginInsertRows(QModelIndex(), row, row);
  mList << call;
  endInsertRows();
}

void CallsListModel::removeCall (const shared_ptr<linphone::Call> &linphoneCall) {
  // TODO: It will be (maybe) necessary to use a single scheduled function in the future.
  QTimer::singleShot(
    DELAY_BEFORE_REMOVE_CALL, this, [this, linphoneCall]() {
      CallModel *call = &linphoneCall->getData<CallModel>("call-model");

      qInfo() << "Removing call:" << call;

      int index = mList.indexOf(call);
      if (index == -1 || !removeRow(index))
        qWarning() << "Unable to remove call:" << call;

      if (mList.empty())
        App::getInstance()->getCallsWindow()->close();
    }
  );
}
