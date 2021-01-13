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

#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/conference/ConferenceAddModel.hpp"
#include "components/conference/ConferenceHelperModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

#include "CallsListModel.hpp"

// =============================================================================

using namespace std;

namespace {
  // Delay before removing call in ms.
  constexpr int DelayBeforeRemoveCall = 3000;
}

static inline int findCallIndex (QList<CallModel *> &list, const shared_ptr<linphone::Call> &call) {
  auto it = find_if(list.begin(), list.end(), [call](CallModel *callModel) {
    return call == callModel->getCall();
  });

  Q_ASSERT(it != list.end());

  return int(distance(list.begin(), it));
}

static inline int findCallIndex (QList<CallModel *> &list, const CallModel &callModel) {
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

void CallsListModel::launchAudioCall (const QString &sipAddress, const QHash<QString, QString> &headers) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  shared_ptr<linphone::Address> address = core->interpretUrl(Utils::appStringToCoreString(sipAddress));
  if (!address)
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
  params->enableVideo(false);

  QHashIterator<QString, QString> iterator(headers);
  while (iterator.hasNext()) {
    iterator.next();
    params->addCustomHeader(Utils::appStringToCoreString(iterator.key()), Utils::appStringToCoreString(iterator.value()));
  }
  params->setProxyConfig(core->getDefaultProxyConfig());
  CallModel::setRecordFile(params, QString::fromStdString(address->getUsername()));
  shared_ptr<linphone::ProxyConfig> currentProxyConfig = core->getDefaultProxyConfig();
  if(currentProxyConfig){
    if(currentProxyConfig->getState() == linphone::RegistrationState::Ok)
      core->inviteAddressWithParams(address, params);
    else{
            QObject * context = new QObject();
            QObject::connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::registrationStateChanged,context,
            [address,core,params,currentProxyConfig, context](const std::shared_ptr<linphone::ProxyConfig> &proxyConfig, linphone::RegistrationState state) mutable {
              if(context && proxyConfig==currentProxyConfig && state==linphone::RegistrationState::Ok){
                delete context;
                context = nullptr;
                core->inviteAddressWithParams(address, params);
              }
            });
    }
  }else
    core->inviteAddressWithParams(address, params);
}

void CallsListModel::launchVideoCall (const QString &sipAddress) const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  if (!core->videoSupported()) {
    qWarning() << QStringLiteral("Unable to launch video call. (Video not supported.) Launching audio call...");
    launchAudioCall(sipAddress);
    return;
  }

  shared_ptr<linphone::Address> address = core->interpretUrl(Utils::appStringToCoreString(sipAddress));
  if (!address)
    return;

  shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
  params->enableVideo(true);
  params->setProxyConfig(core->getDefaultProxyConfig());
  CallModel::setRecordFile(params, QString::fromStdString(address->getUsername()));
  core->inviteAddressWithParams(address, params);
}

// -----------------------------------------------------------------------------

int CallsListModel::getRunningCallsNumber () const {
  return CoreManager::getInstance()->getCore()->getCallsNb();
}

void CallsListModel::terminateAllCalls () const {
  CoreManager::getInstance()->getCore()->terminateAllCalls();
}
void CallsListModel::terminateCall (const QString& sipAddress) const{
	auto coreManager = CoreManager::getInstance();
	shared_ptr<linphone::Address> address = coreManager->getCore()->interpretUrl(Utils::appStringToCoreString(sipAddress));
	if (!address)
		qWarning() << "Cannot terminate Call. The address cannot be parsed : " << sipAddress;
	else{
		std::shared_ptr<linphone::Call> call = coreManager->getCore()->getCallByRemoteAddress2(address);
		if( call){
			coreManager->lockVideoRender();
			call->terminate();
			coreManager->unlockVideoRender();
		}else{
			qWarning() << "Cannot terminate call as it doesn't exist : " << sipAddress;
		}
	}
}
// -----------------------------------------------------------------------------

static void joinConference (const shared_ptr<linphone::Call> &call) {
  if (call->getToHeader("method") != "join-conference")
    return;

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  if (!core->getConference()) {
    qWarning() << QStringLiteral("Not in a conference. => Responding to `join-conference` as a simple call...");
    return;
  }

  shared_ptr<linphone::Conference> conference = core->getConference();
  const QString conferenceId = Utils::coreStringToAppString(call->getToHeader("conference-id"));

  if (conference->getId() != Utils::appStringToCoreString(conferenceId)) {
    qWarning() << QStringLiteral("Trying to join conference with an invalid conference id: `%1`. Responding as a simple call...")
      .arg(conferenceId);
    return;
  }
  qInfo() << QStringLiteral("Join conference: `%1`.").arg(conferenceId);

  ConferenceHelperModel helperModel;
  ConferenceHelperModel::ConferenceAddModel *addModel = helperModel.getConferenceAddModel();

  CallModel *callModel = &call->getData<CallModel>("call-model");
  callModel->accept();
  addModel->addToConference(call->getRemoteAddress());
  addModel->update();
}

void CallsListModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::Call::State state) {
  switch (state) {
    case linphone::Call::State::IncomingReceived:
      addCall(call);
      joinConference(call);
      break;

    case linphone::Call::State::OutgoingInit:
      addCall(call);
      break;

    case linphone::Call::State::End:
    case linphone::Call::State::Error:
      if (call->getCallLog()->getStatus() == linphone::Call::Status::Missed)
        emit callMissed(&call->getData<CallModel>("call-model"));
      removeCall(call);
      break;

    case linphone::Call::State::StreamsRunning: {
      int index = findCallIndex(mList, call);
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
  if (call->getDir() == linphone::Call::Dir::Outgoing) {
    QQuickWindow *callsWindow = App::getInstance()->getCallsWindow();
    if (callsWindow) {
      if (CoreManager::getInstance()->getSettingsModel()->getKeepCallsWindowInBackground()) {
        if (!callsWindow->isVisible())
          callsWindow->showMinimized();
      } else
        App::smartShowWindow(callsWindow);
    }
  }

  CallModel *callModel = new CallModel(call);
  qInfo() << QStringLiteral("Add call:") << callModel->getFullLocalAddress() << callModel->getFullPeerAddress();
  App::getInstance()->getEngine()->setObjectOwnership(callModel, QQmlEngine::CppOwnership);

  // This connection is (only) useful for `CallsListProxyModel`.
  QObject::connect(callModel, &CallModel::isInConferenceChanged, this, [this, callModel](bool) {
    int id = findCallIndex(mList, *callModel);
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
    qWarning() << QStringLiteral("Unable to find call:") << call.get();
    return;
  }

  QTimer::singleShot(DelayBeforeRemoveCall, this, [this, callModel] {
    removeCallCb(callModel);
  });
}

void CallsListModel::removeCallCb (CallModel *callModel) {
  qInfo() << QStringLiteral("Removing call:") << callModel;

  int index = mList.indexOf(callModel);
  if (index == -1 || !removeRow(index))
    qWarning() << QStringLiteral("Unable to remove call:") << callModel;
}
