/*
 * Notifier.cpp
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

#include <QQmlComponent>
#include <QQuickWindow>
#include <QScreen>
#include <QtDebug>
#include <QTimer>

#include "../../app/App.hpp"
#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "Notifier.hpp"

// -----------------------------------------------------------------------------
// Notifications QML properties/methods.
// -----------------------------------------------------------------------------

#define NOTIFICATION_SHOW_METHOD_NAME "open"

#define NOTIFICATION_PROPERTY_DATA "notificationData"

#define NOTIFICATION_PROPERTY_X "popupX"
#define NOTIFICATION_PROPERTY_Y "popupY"

#define NOTIFICATION_PROPERTY_WINDOW "__internalWindow"

#define NOTIFICATION_PROPERTY_TIMER "__timer"

// -----------------------------------------------------------------------------
// Paths.
// -----------------------------------------------------------------------------

#define QML_NOTIFICATION_PATH_RECEIVED_MESSAGE "qrc:/ui/modules/Linphone/Notifications/NotificationReceivedMessage.qml"
#define QML_NOTIFICATION_PATH_RECEIVED_FILE_MESSAGE "qrc:/ui/modules/Linphone/Notifications/NotificationReceivedFileMessage.qml"
#define QML_NOTIFICATION_PATH_RECEIVED_CALL "qrc:/ui/modules/Linphone/Notifications/NotificationReceivedCall.qml"
#define QML_NOTIFICATION_PATH_NEW_VERSION_AVAILABLE "qrc:/ui/modules/Linphone/Notifications/NotificationNewVersionAvailable.qml"

// -----------------------------------------------------------------------------
// Timeouts.
// -----------------------------------------------------------------------------

#define NOTIFICATION_TIMEOUT_RECEIVED_MESSAGE 10000
#define NOTIFICATION_TIMEOUT_RECEIVED_FILE_MESSAGE 10000
#define NOTIFICATION_TIMEOUT_RECEIVED_CALL 30000
#define NOTIFICATION_TIMEOUT_NEW_VERSION_AVAILABLE 30000

// -----------------------------------------------------------------------------
// Arbitrary hardcoded values.
// -----------------------------------------------------------------------------

#define NOTIFICATION_SPACING 10
#define N_MAX_NOTIFICATIONS 5
#define MAX_TIMEOUT 30000

using namespace std;

// =============================================================================

inline int getIntegerFromNotification (const QObject &object, const char *property) {
  QVariant variant = object.property(property);
  bool soFarSoGood;

  int value = variant.toInt(&soFarSoGood);
  if (!soFarSoGood) {
    qWarning() << QStringLiteral("Unable to get int from: `%1`.").arg(property);
    abort();
  }

  return value;
}

template<class T>
void setProperty (QObject &object, const char *property, const T &value) {
  if (!object.setProperty(property, QVariant(value))) {
    qWarning() << QStringLiteral("Unable to set property: `%1`.").arg(property);
    abort();
  }
}

// -----------------------------------------------------------------------------

Notifier::Notifier (QObject *parent) :
  QObject(parent) {
  QQmlEngine *engine = App::getInstance()->getEngine();

  // Build components.
  mComponents[Notifier::MessageReceived] = new QQmlComponent(engine, QUrl(QML_NOTIFICATION_PATH_RECEIVED_MESSAGE));
  mComponents[Notifier::FileMessageReceived] = new QQmlComponent(engine, QUrl(QML_NOTIFICATION_PATH_RECEIVED_FILE_MESSAGE));
  mComponents[Notifier::CallReceived] = new QQmlComponent(engine, QUrl(QML_NOTIFICATION_PATH_RECEIVED_CALL));
  mComponents[Notifier::NewVersionAvailable] = new QQmlComponent(engine, QUrl(QML_NOTIFICATION_PATH_NEW_VERSION_AVAILABLE));

  // Check errors.
  for (int i = 0; i < Notifier::MaxNbTypes; ++i) {
    QQmlComponent *component = mComponents[i];
    if (component->isError()) {
      qWarning() << QStringLiteral("Errors found in `Notification` component %1:").arg(i) << component->errors();
      abort();
    }
  }
}

Notifier::~Notifier () {
  for (int i = 0; i < Notifier::MaxNbTypes; ++i)
    delete mComponents[i];
}

// -----------------------------------------------------------------------------

QObject *Notifier::createNotification (Notifier::NotificationType type) {
  mMutex.lock();

  Q_ASSERT(mInstancesNumber <= N_MAX_NOTIFICATIONS);

  // Check existing instances.
  if (mInstancesNumber == N_MAX_NOTIFICATIONS) {
    qWarning() << QStringLiteral("Unable to create another notification.");
    mMutex.unlock();
    return nullptr;
  }

  // Create instance and set attributes.
  QObject *instance = mComponents[type]->create();
  qInfo() << QStringLiteral("Create notification:") << instance;

  mInstancesNumber++;

  {
    QQuickWindow *window = instance->findChild<QQuickWindow *>(NOTIFICATION_PROPERTY_WINDOW);
    Q_ASSERT(window != nullptr);

    QScreen *screen = window->screen();
    Q_ASSERT(screen != nullptr);

    QRect geometry = screen->availableGeometry();

    // Set X/Y. (Not Pokémon games.)
    int windowHeight = window->height();
    int offset = geometry.y() + geometry.height() - windowHeight;

    ::setProperty(*instance, NOTIFICATION_PROPERTY_X, geometry.x() + geometry.width() - window->width());
    ::setProperty(*instance, NOTIFICATION_PROPERTY_Y, offset - (mOffset % offset));

    // Update offset.
    mOffset = (windowHeight + mOffset) + NOTIFICATION_SPACING;
    if (mOffset - offset + geometry.y() >= 0)
      mOffset = 0;
  }

  mMutex.unlock();

  return instance;
}

// -----------------------------------------------------------------------------

void Notifier::showNotification (QObject *notification, int timeout) {
  // Display notification.
  QMetaObject::invokeMethod(notification, NOTIFICATION_SHOW_METHOD_NAME, Qt::DirectConnection);

  QTimer *timer = new QTimer(notification);
  timer->setInterval(timeout > MAX_TIMEOUT ? MAX_TIMEOUT : timeout);
  timer->setSingleShot(true);
  notification->setProperty(NOTIFICATION_PROPERTY_TIMER, QVariant::fromValue(timer));

  // Destroy it after timeout.
  QObject::connect(
    timer, &QTimer::timeout, this, [this, notification]() {
      deleteNotification(QVariant::fromValue(notification));
    }
  );

  // Called explicitly (by a click on notification for example)
  QObject::connect(notification, SIGNAL(deleteNotification(QVariant)), this, SLOT(deleteNotification(QVariant)));

  timer->start();
}

// -----------------------------------------------------------------------------

void Notifier::deleteNotification (QVariant notification) {
  mMutex.lock();

  QObject *instance = notification.value<QObject *>();

  // Notification marked destroyed.
  if (instance->property("__valid").isValid()) {
    mMutex.unlock();
    return;
  }

  qInfo() << QStringLiteral("Delete notification:") << instance;

  instance->setProperty("__valid", true);
  instance->property(NOTIFICATION_PROPERTY_TIMER).value<QTimer *>()->stop();

  mInstancesNumber--;
  Q_ASSERT(mInstancesNumber >= 0);

  if (mInstancesNumber == 0)
    mOffset = 0;

  mMutex.unlock();

  instance->deleteLater();
}

// =============================================================================

void Notifier::notifyReceivedMessage (const shared_ptr<linphone::ChatMessage> &message) {
  QObject *notification = createNotification(Notifier::MessageReceived);
  if (!notification)
    return;

  QVariantMap map;
  map["message"] = ::Utils::coreStringToAppString(message->getText());
  map["sipAddress"] = ::Utils::coreStringToAppString(message->getFromAddress()->asStringUriOnly());
  map["window"].setValue(App::getInstance()->getMainWindow());

  ::setProperty(*notification, NOTIFICATION_PROPERTY_DATA, map);
  showNotification(notification, NOTIFICATION_TIMEOUT_RECEIVED_MESSAGE);
}

void Notifier::notifyReceivedFileMessage (const shared_ptr<linphone::ChatMessage> &message) {
  QObject *notification = createNotification(Notifier::FileMessageReceived);
  if (!notification)
    return;

  QVariantMap map;
  map["fileUri"] = ::Utils::coreStringToAppString(message->getFileTransferFilepath());
  map["fileSize"] = static_cast<quint64>(message->getFileTransferInformation()->getSize());

  ::setProperty(*notification, NOTIFICATION_PROPERTY_DATA, map);
  showNotification(notification, NOTIFICATION_TIMEOUT_RECEIVED_FILE_MESSAGE);
}

void Notifier::notifyReceivedCall (const shared_ptr<linphone::Call> &call) {
  QObject *notification = createNotification(Notifier::CallReceived);
  if (!notification)
    return;

  CallModel *callModel = &call->getData<CallModel>("call-model");

  QObject::connect(
    callModel, &CallModel::statusChanged, notification, [this, notification](CallModel::CallStatus status) {
      if (status == CallModel::CallStatusEnded || status == CallModel::CallStatusConnected)
        deleteNotification(QVariant::fromValue(notification));
    }
  );

  QVariantMap map;
  map["call"].setValue(callModel);

  ::setProperty(*notification, NOTIFICATION_PROPERTY_DATA, map);
  showNotification(notification, NOTIFICATION_TIMEOUT_RECEIVED_CALL);
}

void Notifier::notifyNewVersionAvailable (const std::string &version, const std::string &url) {
  QObject *notification = createNotification(Notifier::NewVersionAvailable);
  if (!notification)
    return;

  QVariantMap map;
  map["message"] = tr("newVersionAvailable").arg(::Utils::coreStringToAppString(version));
  map["url"] = ::Utils::coreStringToAppString(url);

  ::setProperty(*notification, NOTIFICATION_PROPERTY_DATA, map);
  showNotification(notification, NOTIFICATION_TIMEOUT_NEW_VERSION_AVAILABLE);
}