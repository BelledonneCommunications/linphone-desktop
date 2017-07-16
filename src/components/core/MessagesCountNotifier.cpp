/*
 * MessagesCountNotifier.cpp
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
 *  Created on: June 29, 2017
 *      Author: Ronan Abhamon
 */

#include "../core/CoreManager.hpp"

#if defined(Q_OS_LINUX)
  // TODO.
#elif defined(Q_OS_MACOS)
  #include "MessagesCountNotifierMacOS.h"
#elif defined(Q_OS_WIN)
  // TODO.
#endif // if defined(Q_OS_LINUX)

#include "MessagesCountNotifier.hpp"

using namespace std;

// =============================================================================

MessagesCountNotifier::MessagesCountNotifier (QObject *parent) : QObject(parent) {
  CoreManager *coreManager = CoreManager::getInstance();
  QObject::connect(
    coreManager, &CoreManager::chatModelCreated,
    this, &MessagesCountNotifier::handleChatModelCreated
  );
  QObject::connect(
    coreManager->getHandlers().get(), &CoreHandlers::messageReceived,
    this, &MessagesCountNotifier::handleMessageReceived
  );

  updateUnreadMessagesCount();
}

// -----------------------------------------------------------------------------

void MessagesCountNotifier::updateUnreadMessagesCount () {
  mUnreadMessagesCount = 0;
  for (const auto &chatRoom : CoreManager::getInstance()->getCore()->getChatRooms())
    mUnreadMessagesCount += chatRoom->getUnreadMessagesCount();

  notifyUnreadMessagesCount();
}

void MessagesCountNotifier::notifyUnreadMessagesCount () {
  qInfo() << QStringLiteral("Notify unread messages count: %1.").arg(mUnreadMessagesCount);
  int count = mUnreadMessagesCount > 99 ? 99 : mUnreadMessagesCount;

  #if defined(Q_OS_LINUX)
    (void)count;
  #elif defined(Q_OS_MACOS)
    ::notifyUnreadMessagesCountMacOS(count);
  #elif defined(Q_OS_WIN)
    (void)count;
  #endif // if defined(Q_OS_LINUX)
}

// -----------------------------------------------------------------------------

void MessagesCountNotifier::handleChatModelCreated (const shared_ptr<ChatModel> &chatModel) {
  QObject::connect(
    chatModel.get(), &ChatModel::messagesCountReset,
    this, &MessagesCountNotifier::updateUnreadMessagesCount
  );
}

void MessagesCountNotifier::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &) {
  mUnreadMessagesCount++;
  notifyUnreadMessagesCount();
}
