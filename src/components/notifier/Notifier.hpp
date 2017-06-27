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
#include <QObject>

// =============================================================================

class QMutex;
class QQmlComponent;

class Notifier : public QObject {
  Q_OBJECT;

public:
  Notifier (QObject *parent = Q_NULLPTR);
  ~Notifier ();

  enum NotificationType {
    ReceivedMessage,
    ReceivedFileMessage,
    ReceivedCall,
    NewVersionAvailable,
    SnapshotWasTaken,
    RecordingCompleted
  };

  void notifyReceivedMessage (const std::shared_ptr<linphone::ChatMessage> &message);
  void notifyReceivedFileMessage (const std::shared_ptr<linphone::ChatMessage> &message);
  void notifyReceivedCall (const std::shared_ptr<linphone::Call> &call);
  void notifyNewVersionAvailable (const QString &version, const QString &url);
  void notifySnapshotWasTaken (const QString &filePath);
  void notifyRecordingCompleted (const QString &filePath);

public slots:
  void deleteNotification (QVariant notification);

private:
  struct Notification {
    Notification (const QString &filename = QString(""), int timeout = 0) {
      this->filename = filename;
      this->timeout = timeout;
    }

    QString filename;
    int timeout;
  };

  QObject *createNotification (NotificationType type);
  void showNotification (QObject *notification, int timeout);

  int mOffset = 0;
  int mInstancesNumber = 0;

  QMutex *mMutex = nullptr;
  QQmlComponent **mComponents = nullptr;

  static const QHash<int, Notification> mNotifications;
};

#endif // NOTIFIER_H_
