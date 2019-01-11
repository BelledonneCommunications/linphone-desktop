/*
 * AbstractEventCountNotifier.hpp
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

#ifndef ABSTRACT_EVENT_COUNT_NOTIFIER_H_
#define ABSTRACT_EVENT_COUNT_NOTIFIER_H_

#include <memory>

#include <QHash>
#include <QObject>
#include <QPair>

// =============================================================================

namespace linphone {
  class ChatMessage;
}

class CallModel;
class ChatModel;

class AbstractEventCountNotifier : public QObject {
  Q_OBJECT;

public:
  AbstractEventCountNotifier (QObject *parent = Q_NULLPTR);

  void updateUnreadMessageCount ();

  int getUnreadMessageCount () const { return mUnreadMessageCount; }
  int getMissedCallCount () const {
    int t = 0;
    for (int n : mMissedCalls) t += n;
    return t;
  }

  int getEventCount () const { return mUnreadMessageCount + getMissedCallCount(); }

signals:
  void eventCountChanged (int count);

protected:
  virtual void notifyEventCount (int n) = 0;

private:
  using ConferenceId = QPair<QString, QString>;

  void internalnotifyEventCount ();

  void handleChatModelCreated (const std::shared_ptr<ChatModel> &chatModel);

  void handleChatModelFocused (ChatModel *chatModel);
  void handleCallMissed (CallModel *callModel);

  QHash<ConferenceId, int> mMissedCalls;
  int mUnreadMessageCount = 0;
};

#endif // ABSTRACT_EVENT_COUNT_NOTIFIER_H_
