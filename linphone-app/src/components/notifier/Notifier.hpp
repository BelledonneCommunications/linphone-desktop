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

#ifndef NOTIFIER_H_
#define NOTIFIER_H_

#include <memory>

#include <QObject>
#include <QHash>

// =============================================================================

class QMutex;
class QQmlComponent;

namespace linphone {
  class Call;
  class ChatMessage;
}

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

  QObject *createNotification (NotificationType type, QVariantMap data);
  void showNotification (QObject *notification, int timeout);

  QHash<QString,int> mScreenHeightOffset;
  int mInstancesNumber = 0;

  QMutex *mMutex = nullptr;
  QQmlComponent **mComponents = nullptr;

  static const QHash<int, Notification> Notifications;
};

#endif // NOTIFIER_H_
