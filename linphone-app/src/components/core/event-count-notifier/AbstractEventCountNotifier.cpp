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

#include <QtDebug>

#include "components/call/CallModel.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/chat/ChatModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/history/HistoryModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

#include "AbstractEventCountNotifier.hpp"

// =============================================================================

using namespace std;

AbstractEventCountNotifier::AbstractEventCountNotifier (QObject *parent) : QObject(parent) {
  CoreManager *coreManager = CoreManager::getInstance();
  QObject::connect(
    coreManager, &CoreManager::chatModelCreated,
    this, &AbstractEventCountNotifier::handleChatModelCreated
  );
  QObject::connect(
    coreManager, &CoreManager::historyModelCreated,
    this, &AbstractEventCountNotifier::handleHistoryModelCreated
  );
  QObject::connect(
    coreManager->getHandlers().get(), &CoreHandlers::messageReceived,
    this, &AbstractEventCountNotifier::updateUnreadMessageCount
  );
  QObject::connect(
    coreManager->getSettingsModel(), &SettingsModel::chatEnabledChanged,
    this, &AbstractEventCountNotifier::internalnotifyEventCount
  );
  QObject::connect(
    coreManager->getCallsListModel(), &CallsListModel::callMissed,
    this, &AbstractEventCountNotifier::handleCallMissed
  );
}

// -----------------------------------------------------------------------------

void AbstractEventCountNotifier::updateUnreadMessageCount () {
  mUnreadMessageCount = CoreManager::getInstance()->getCore()->getUnreadChatMessageCountFromActiveLocals();
  internalnotifyEventCount();
}

void AbstractEventCountNotifier::internalnotifyEventCount () {
  int n = mUnreadMessageCount + getMissedCallCount();
  qInfo() << QStringLiteral("Notify event count: %1.").arg(n);
  n = n > 99 ? 99 : n;

  notifyEventCount(CoreManager::getInstance()->getSettingsModel()->getChatEnabled() ? n : 0);
  emit eventCountChanged(n);
}

// Get missed call from a chat (useful for showing bubbles on Timelines)
int AbstractEventCountNotifier::getMissedCallCount(const QString &peerAddress, const QString &localAddress) const{
	auto it = mMissedCalls.find({ Utils::cleanSipAddress(peerAddress), Utils::cleanSipAddress(localAddress) });
	if (it != mMissedCalls.cend()) 
		return *it;
	else
		return 0;
}
// Get missed call from a chat (useful for showing bubbles on Timelines)
int AbstractEventCountNotifier::getMissedCallCountFromLocal(const QString &localAddress) const{
	QString cleanAddress = Utils::cleanSipAddress(localAddress);
	int count = 0;
	for(auto it = mMissedCalls.cbegin() ; it != mMissedCalls.cend() ; ++it){
		if(it.key().second == cleanAddress)
			count += *it;
	}
	return count;
}
// -----------------------------------------------------------------------------

void AbstractEventCountNotifier::handleChatModelCreated (const shared_ptr<ChatModel> &chatModel) {
  ChatModel *chatModelPtr = chatModel.get();
  QObject::connect(
    chatModelPtr, &ChatModel::messageCountReset,
    this, &AbstractEventCountNotifier::updateUnreadMessageCount
  );
  QObject::connect(
    chatModelPtr, &ChatModel::focused,
    this, [this, chatModelPtr]() { handleResetMissedCalls(chatModelPtr); }
  );
  QObject::connect(
    chatModelPtr, &ChatModel::messageCountReset,
    this, [this, chatModelPtr]() { handleResetMissedCalls(chatModelPtr); }
  );
}

void AbstractEventCountNotifier::handleHistoryModelCreated (HistoryModel *historyModel) {
  QObject::connect(historyModel, &HistoryModel::callCountReset
    , this, &AbstractEventCountNotifier::handleResetAllMissedCalls);
}

void AbstractEventCountNotifier::handleResetAllMissedCalls () {
  mMissedCalls.clear();
  internalnotifyEventCount();
}


void AbstractEventCountNotifier::handleResetMissedCalls (ChatModel *chatModel) {
  auto it = mMissedCalls.find({ Utils::cleanSipAddress(chatModel->getPeerAddress()), Utils::cleanSipAddress(chatModel->getLocalAddress()) });
  if (it != mMissedCalls.cend()) {
    mMissedCalls.erase(it);
    internalnotifyEventCount();
  }
}
void AbstractEventCountNotifier::handleCallMissed (CallModel *callModel) {
  ++mMissedCalls[{ Utils::cleanSipAddress(callModel->getPeerAddress()), Utils::cleanSipAddress(callModel->getLocalAddress()) }];
  internalnotifyEventCount();
}
