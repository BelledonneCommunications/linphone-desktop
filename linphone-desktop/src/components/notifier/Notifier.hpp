/*
 * Notifier.hpp
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

#ifndef NOTIFIER_H_
#define NOTIFIER_H_

#include <linphone++/linphone.hh>

#include <QMutex>
#include <QObject>

// =============================================================================

class QQmlComponent;

class Notifier : public QObject {
  Q_OBJECT;

public:
  Notifier (QObject *parent = Q_NULLPTR);
  ~Notifier ();

  enum NotificationType {
    Call,
    MessageReceived,
    MaxNbTypes
  };

  void notifyReceivedMessage (
    int timeout,
    const std::shared_ptr<linphone::ChatRoom> &room,
    const std::shared_ptr<linphone::ChatMessage> &message
  );

  // TODO
  void showCallMessage (int timeout, const QString &);

private:
  QObject *createNotification (NotificationType type);
  void handleNotificationHidden ();
  void showNotification (QObject *notification, int timeout);

  QQmlComponent *m_components[MaxNbTypes];

  int m_offset = 0;
  unsigned int m_n_instances = 0;
  QMutex m_mutex;
};

#endif // NOTIFIER_H_
