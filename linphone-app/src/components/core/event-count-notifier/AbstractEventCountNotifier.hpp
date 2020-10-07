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
class HistoryModel;

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
  int getMissedCallCount(const QString &peerAddress, const QString &localAddress) const;// Get missed call count from a chat (useful for showing bubbles on Timelines)
  int getMissedCallCountFromLocal(const QString &localAddress) const;// Get missed call count from a chat (useful for showing bubbles on Timelines)

signals:
  void eventCountChanged (int count);

protected:
  virtual void notifyEventCount (int n) = 0;

private:
  using ConferenceId = QPair<QString, QString>;

  void internalnotifyEventCount ();

  void handleChatModelCreated (const std::shared_ptr<ChatModel> &chatModel);
  void handleHistoryModelCreated (HistoryModel *historyModel);
  
  
  void handleResetAllMissedCalls ();
  void handleResetMissedCalls (ChatModel *chatModel);
  void handleCallMissed (CallModel *callModel);

  QHash<ConferenceId, int> mMissedCalls;
  int mUnreadMessageCount = 0;
};

#endif // ABSTRACT_EVENT_COUNT_NOTIFIER_H_
