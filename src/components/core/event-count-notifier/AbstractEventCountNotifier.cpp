/*
 * AbstractEventCountNotifier.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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
 *  Created on: June 29, 2017
 *      Author: Ronan Abhamon
 */

#include "components/call/CallModel.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/chat/ChatModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"

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
  emit eventCountChanged(mUnreadMessageCount);
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
    this, [this, chatModelPtr]() { handleChatModelFocused(chatModelPtr); }
  );
}

void AbstractEventCountNotifier::handleChatModelFocused (ChatModel *chatModel) {
  auto it = mMissedCalls.find({ chatModel->getPeerAddress(), chatModel->getLocalAddress() });
  if (it != mMissedCalls.cend()) {
    mMissedCalls.erase(it);
    internalnotifyEventCount();
  }
}

void AbstractEventCountNotifier::handleCallMissed (CallModel *callModel) {
  Q_UNUSED(callModel);
  ++mMissedCalls[{ callModel->getPeerAddress(), callModel->getLocalAddress() }];
  internalnotifyEventCount();
}
