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
#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "CallsListModel.hpp"

/* Delay before removing call in ms. */
#define DELAY_BEFORE_REMOVE_CALL 3000

using namespace std;

// =============================================================================

CallsListModel::CallsListModel (QObject *parent) : QAbstractListModel(parent) {
  m_core_handlers = CoreManager::getInstance()->getHandlers();
  QObject::connect(
    &(*m_core_handlers), &CoreHandlers::callStateChanged,
    this, [this](const shared_ptr<linphone::Call> &linphone_call, linphone::CallState state) {
      switch (state) {
        case linphone::CallStateIncomingReceived:
        case linphone::CallStateOutgoingInit:
          addCall(linphone_call);
          break;

        case linphone::CallStateEnd:
        case linphone::CallStateError:
          removeCall(linphone_call);
          break;

        default:
          break;
      }
    }
  );
}

int CallsListModel::rowCount (const QModelIndex &) const {
  return m_list.count();
}

QHash<int, QByteArray> CallsListModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$call";
  return roles;
}

QVariant CallsListModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= m_list.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(m_list[row]);

  return QVariant();
}

CallModel *CallsListModel::getCall (const shared_ptr<linphone::Call> &linphone_call) const {
  auto it = find_if(
      m_list.begin(), m_list.end(), [linphone_call](CallModel *call) {
        return linphone_call == call->getLinphoneCall();
      }
    );

  return it != m_list.end() ? *it : nullptr;
}

// -----------------------------------------------------------------------------

void CallsListModel::launchAudioCall (const QString &sip_uri) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> address = core->interpretUrl(::Utils::qStringToLinphoneString(sip_uri));

  if (!address)
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
  params->enableVideo(false);
  CallModel::setRecordFile(params);

  core->inviteAddressWithParams(address, params);
}

void CallsListModel::launchVideoCall (const QString &sip_uri) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> address = core->interpretUrl(::Utils::qStringToLinphoneString(sip_uri));

  if (!address)
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
  params->enableEarlyMediaSending(true);
  params->enableVideo(true);
  CallModel::setRecordFile(params);

  core->inviteAddressWithParams(address, params);
}

// -----------------------------------------------------------------------------

bool CallsListModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool CallsListModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= m_list.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i)
    m_list.takeAt(row)->deleteLater();

  endRemoveRows();

  return true;
}

// -----------------------------------------------------------------------------

void CallsListModel::addCall (const shared_ptr<linphone::Call> &linphone_call) {
  if (linphone_call->getDir() == linphone::CallDirOutgoing)
    App::getInstance()->getCallsWindow()->show();

  CallModel *call = new CallModel(linphone_call);

  qInfo() << "Add call:" << call;

  App::getInstance()->getEngine()->setObjectOwnership(call, QQmlEngine::CppOwnership);
  linphone_call->setData("call-model", *call);

  int row = m_list.count();

  beginInsertRows(QModelIndex(), row, row);
  m_list << call;
  endInsertRows();
}

void CallsListModel::removeCall (const shared_ptr<linphone::Call> &linphone_call) {
  // TODO: It will be (maybe) necessary to use a single scheduled function in the future.
  QTimer::singleShot(
    DELAY_BEFORE_REMOVE_CALL, this, [this, linphone_call]() {
      CallModel *call = &linphone_call->getData<CallModel>("call-model");
      linphone_call->unsetData("call-model");

      qInfo() << "Removing call:" << call;

      int index = m_list.indexOf(call);
      if (index == -1 || !removeRow(index))
        qWarning() << "Unable to remove call:" << call;

      if (m_list.empty())
        App::getInstance()->getCallsWindow()->close();
    }
  );
}
