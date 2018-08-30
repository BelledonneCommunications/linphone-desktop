/*
 * AbstractMessageCountNotifier.cpp
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

#include "components/chat/ChatModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"

#include "AbstractMessageCountNotifier.hpp"

// =============================================================================

using namespace std;

AbstractMessageCountNotifier::AbstractMessageCountNotifier (QObject *parent) : QObject(parent) {
  CoreManager *coreManager = CoreManager::getInstance();
  QObject::connect(
    coreManager, &CoreManager::chatModelCreated,
    this, &AbstractMessageCountNotifier::handleChatModelCreated
  );
  QObject::connect(
    coreManager->getHandlers().get(), &CoreHandlers::messageReceived,
    this, &AbstractMessageCountNotifier::updateUnreadMessageCount
  );
  QObject::connect(
    coreManager->getSettingsModel(), &SettingsModel::chatEnabledChanged,
    this, &AbstractMessageCountNotifier::internalNotifyUnreadMessageCount
  );
}

// -----------------------------------------------------------------------------

void AbstractMessageCountNotifier::updateUnreadMessageCount () {
  mUnreadMessageCount = CoreManager::getInstance()->getCore()->getUnreadChatMessageCountFromActiveLocals();
  internalNotifyUnreadMessageCount();
}

void AbstractMessageCountNotifier::internalNotifyUnreadMessageCount () {
  qInfo() << QStringLiteral("Notify unread messages count: %1.").arg(mUnreadMessageCount);
  int n = mUnreadMessageCount > 99 ? 99 : mUnreadMessageCount;

  notifyUnreadMessageCount(CoreManager::getInstance()->getSettingsModel()->getChatEnabled() ? n : 0);
  unreadMessageCountChanged(mUnreadMessageCount);
}

// -----------------------------------------------------------------------------

void AbstractMessageCountNotifier::handleChatModelCreated (const shared_ptr<ChatModel> &chatModel) {
  QObject::connect(
    chatModel.get(), &ChatModel::messageCountReset,
    this, &AbstractMessageCountNotifier::updateUnreadMessageCount
  );
}
