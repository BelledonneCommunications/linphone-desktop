/*
 * AbstractMessagesCountNotifier.cpp
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

#include "../CoreManager.hpp"

#include "AbstractMessagesCountNotifier.hpp"

using namespace std;

// =============================================================================

AbstractMessagesCountNotifier::AbstractMessagesCountNotifier (QObject *parent) : QObject(parent) {
  CoreManager *coreManager = CoreManager::getInstance();
  QObject::connect(
    coreManager, &CoreManager::chatModelCreated,
    this, &AbstractMessagesCountNotifier::handleChatModelCreated
  );
  QObject::connect(
    coreManager->getHandlers().get(), &CoreHandlers::messageReceived,
    this, &AbstractMessagesCountNotifier::handleMessageReceived
  );
  QObject::connect(
    coreManager->getSettingsModel(), &SettingsModel::chatEnabledChanged,
    this, &AbstractMessagesCountNotifier::internalNotifyUnreadMessagesCount
  );
}

// -----------------------------------------------------------------------------

void AbstractMessagesCountNotifier::updateUnreadMessagesCount () {
  mUnreadMessagesCount = 0;
  for (const auto &chatRoom : CoreManager::getInstance()->getCore()->getChatRooms())
    mUnreadMessagesCount += chatRoom->getUnreadMessagesCount();

  internalNotifyUnreadMessagesCount();
}

void AbstractMessagesCountNotifier::internalNotifyUnreadMessagesCount () {
  qInfo() << QStringLiteral("Notify unread messages count: %1.").arg(mUnreadMessagesCount);
  int n = mUnreadMessagesCount > 99 ? 99 : mUnreadMessagesCount;

  notifyUnreadMessagesCount(CoreManager::getInstance()->getSettingsModel()->getChatEnabled() ? n : 0);
}

// -----------------------------------------------------------------------------

void AbstractMessagesCountNotifier::handleChatModelCreated (const shared_ptr<ChatModel> &chatModel) {
  QObject::connect(
    chatModel.get(), &ChatModel::messagesCountReset,
    this, &AbstractMessagesCountNotifier::updateUnreadMessagesCount
  );
}

void AbstractMessagesCountNotifier::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &) {
  mUnreadMessagesCount++;
  internalNotifyUnreadMessagesCount();
}
