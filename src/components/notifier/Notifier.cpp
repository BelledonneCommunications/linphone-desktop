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

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "Notifier.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char NotificationsPath[] = "qrc:/ui/modules/Linphone/Notifications/";

  // ---------------------------------------------------------------------------
  // Notifications QML properties/methods.
  // ---------------------------------------------------------------------------

  constexpr char NotificationShowMethodName[] = "open";

  constexpr char NotificationPropertyData[] = "notificationData";

  constexpr char NotificationPropertyX[] = "popupX";
  constexpr char NotificationPropertyY[] = "popupY";

  constexpr char NotificationPropertyWindow[] = "__internalWindow";

  constexpr char NotificationPropertyTimer[] = "__timer";

  // ---------------------------------------------------------------------------
  // Arbitrary hardcoded values.
  // ---------------------------------------------------------------------------

  constexpr int NotificationSpacing = 10;
  constexpr int MaxNotificationsNumber = 5;
  constexpr int MaxTimeout = 30000;
}

// =============================================================================

template<class T>
void setProperty (QObject &object, const char *property, const T &value) {
  if (!object.setProperty(property, QVariant(value))) {
    qWarning() << QStringLiteral("Unable to set property: `%1`.").arg(property);
    abort();
  }
}

// =============================================================================
// Available notifications.
// =============================================================================

const QHash<int, Notifier::Notification> Notifier::Notifications = {
  { Notifier::ReceivedMessage, { "NotificationReceivedMessage.qml", 10 } },
  { Notifier::ReceivedFileMessage, { "NotificationReceivedFileMessage.qml", 10 } },
  { Notifier::ReceivedCall, { "NotificationReceivedCall.qml", 30 } },
  { Notifier::NewVersionAvailable, { "NotificationNewVersionAvailable.qml", 30 } },
  { Notifier::SnapshotWasTaken, { "NotificationSnapshotWasTaken.qml", 10 } },
  { Notifier::RecordingCompleted, { "NotificationRecordingCompleted.qml", 10 } }
};

// -----------------------------------------------------------------------------

Notifier::Notifier (QObject *parent) : QObject(parent) {
  const int nComponents = Notifications.size();
  mComponents = new QQmlComponent *[nComponents];

  QQmlEngine *engine = App::getInstance()->getEngine();
  for (const auto &key : Notifications.keys()) {
    QQmlComponent *component = new QQmlComponent(engine, QUrl(NotificationsPath + Notifier::Notifications[key].filename));
    if (Q_UNLIKELY(component->isError())) {
      qWarning() << QStringLiteral("Errors found in `Notification` component %1:").arg(key) << component->errors();
      abort();
    }
    mComponents[key] = component;
  }

  mMutex = new QMutex();
}

Notifier::~Notifier () {
  delete mMutex;

  const int nComponents = Notifications.size();
  for (int i = 0; i < nComponents; ++i)
    delete mComponents[i];
  delete[] mComponents;
}

// -----------------------------------------------------------------------------

QObject *Notifier::createNotification (Notifier::NotificationType type) {
  mMutex->lock();

  Q_ASSERT(mInstancesNumber <= MaxNotificationsNumber);

  // Check existing instances.
  if (mInstancesNumber == MaxNotificationsNumber) {
    qWarning() << QStringLiteral("Unable to create another notification.");
    mMutex->unlock();
    return nullptr;
  }

  // Create instance and set attributes.
  QObject *instance = mComponents[type]->create();
  qInfo() << QStringLiteral("Create notification:") << instance;

  mInstancesNumber++;

  {
    QQuickWindow *window = instance->findChild<QQuickWindow *>(NotificationPropertyWindow);
    Q_CHECK_PTR(window);

    QScreen *screen = window->screen();
    Q_CHECK_PTR(screen);

    QRect geometry = screen->availableGeometry();

    // Set X/Y. (Not Pokémon games.)
    int windowHeight = window->height();
    int offset = geometry.y() + geometry.height() - windowHeight;

    ::setProperty(*instance, NotificationPropertyX, geometry.x() + geometry.width() - window->width());
    ::setProperty(*instance, NotificationPropertyY, offset - (mOffset % offset));

    // Update offset.
    mOffset = (windowHeight + mOffset) + NotificationSpacing;
    if (mOffset - offset + geometry.y() >= 0)
      mOffset = 0;
  }

  mMutex->unlock();

  return instance;
}

// -----------------------------------------------------------------------------

void Notifier::showNotification (QObject *notification, int timeout) {
  // Display notification.
  QMetaObject::invokeMethod(notification, NotificationShowMethodName, Qt::DirectConnection);

  QTimer *timer = new QTimer(notification);
  timer->setInterval(timeout > MaxTimeout ? MaxTimeout : timeout);
  timer->setSingleShot(true);
  notification->setProperty(NotificationPropertyTimer, QVariant::fromValue(timer));

  // Destroy it after timeout.
  QObject::connect(timer, &QTimer::timeout, this, [this, notification]() {
    deleteNotification(QVariant::fromValue(notification));
  });

  // Called explicitly (by a click on notification for example)
  QObject::connect(notification, SIGNAL(deleteNotification(QVariant)), this, SLOT(deleteNotification(QVariant)));

  timer->start();
}

// -----------------------------------------------------------------------------

void Notifier::deleteNotification (QVariant notification) {
  mMutex->lock();

  QObject *instance = notification.value<QObject *>();

  // Notification marked destroyed.
  if (instance->property("__valid").isValid()) {
    mMutex->unlock();
    return;
  }

  qInfo() << QStringLiteral("Delete notification:") << instance;

  instance->setProperty("__valid", true);
  instance->property(NotificationPropertyTimer).value<QTimer *>()->stop();

  mInstancesNumber--;
  Q_ASSERT(mInstancesNumber >= 0);

  if (mInstancesNumber == 0)
    mOffset = 0;

  mMutex->unlock();

  instance->deleteLater();
}

// =============================================================================

#define CREATE_NOTIFICATION(TYPE) \
  QObject * notification = createNotification(TYPE); \
  if (!notification) \
    return; \
  const int timeout = Notifications[TYPE].timeout * 1000;

#define SHOW_NOTIFICATION(DATA) \
  ::setProperty(*notification, NotificationPropertyData, DATA); \
  showNotification(notification, timeout);

// -----------------------------------------------------------------------------
// Notification functions.
// -----------------------------------------------------------------------------

void Notifier::notifyReceivedMessage (const shared_ptr<linphone::ChatMessage> &message) {
  CREATE_NOTIFICATION(Notifier::ReceivedMessage);

  QVariantMap map;
  map["message"] = message->getFileTransferInformation()
    ? tr("newFileMessage")
    : Utils::coreStringToAppString(message->getText());

  shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
  map["peerAddress"] = Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly());
  map["localAddress"] = Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly());
  map["window"].setValue(App::getInstance()->getMainWindow());

  SHOW_NOTIFICATION(map);
}

void Notifier::notifyReceivedFileMessage (const shared_ptr<linphone::ChatMessage> &message) {
  CREATE_NOTIFICATION(Notifier::ReceivedFileMessage);

  QVariantMap map;
  map["fileUri"] = Utils::coreStringToAppString(message->getFileTransferFilepath());
  map["fileSize"] = quint64(message->getFileTransferInformation()->getSize());

  SHOW_NOTIFICATION(map);
}

void Notifier::notifyReceivedCall (const shared_ptr<linphone::Call> &call) {
  CREATE_NOTIFICATION(Notifier::ReceivedCall);

  CallModel *callModel = &call->getData<CallModel>("call-model");

  QObject::connect(callModel, &CallModel::statusChanged, notification, [this, notification](CallModel::CallStatus status) {
      if (status == CallModel::CallStatusEnded || status == CallModel::CallStatusConnected)
        deleteNotification(QVariant::fromValue(notification));
    });

  QVariantMap map;
  map["call"].setValue(callModel);

  SHOW_NOTIFICATION(map);
}

void Notifier::notifyNewVersionAvailable (const QString &version, const QString &url) {
  CREATE_NOTIFICATION(Notifier::NewVersionAvailable);

  QVariantMap map;
  map["message"] = tr("newVersionAvailable").arg(version);
  map["url"] = url;

  SHOW_NOTIFICATION(map);
}

void Notifier::notifySnapshotWasTaken (const QString &filePath) {
  CREATE_NOTIFICATION(Notifier::SnapshotWasTaken);

  QVariantMap map;
  map["filePath"] = filePath;

  SHOW_NOTIFICATION(map);
}

void Notifier::notifyRecordingCompleted (const QString &filePath) {
  CREATE_NOTIFICATION(Notifier::RecordingCompleted);

  QVariantMap map;
  map["filePath"] = filePath;

  SHOW_NOTIFICATION(map);
}

#undef SHOW_NOTIFICATION
#undef CREATE_NOTIFICATION
