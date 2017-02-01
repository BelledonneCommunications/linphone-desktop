#include "../../app/App.hpp"

#include "Notifier.hpp"

#include <QQmlComponent>
#include <QQuickWindow>
#include <QtDebug>
#include <QTimer>

// Notifications QML properties/methods.
#define NOTIFICATION_SHOW_METHOD_NAME "show"

#define NOTIFICATION_HEIGHT_PROPERTY "notificationHeight"
#define NOTIFICATION_OFFSET_PROPERTY_NAME "notificationOffset"

#define QML_CALL_NOTIFICATION_PATH "qrc:/ui/modules/Linphone/Notifications/CallNotification.qml"
#define QML_MESSAGE_RECEIVED_NOTIFICATION_PATH "qrc:/ui/modules/Linphone/Notifications/ReceivedMessageNotification.qml"

// Arbitrary hardcoded values.
#define NOTIFICATION_SPACING 10
#define N_MAX_NOTIFICATIONS 15
#define MAX_TIMEOUT 60000

// =============================================================================

inline int getNotificationSize (const QObject &object, const char *property) {
  QVariant variant = object.property(property);
  bool so_far_so_good;

  int size = variant.toInt(&so_far_so_good);
  if (!so_far_so_good || size < 0) {
    qWarning() << "Unable to get notification size.";
    return -1;
  }

  return size;
}

template<class T>
bool setProperty (QObject &object, const char *property, const T &value) {
  QVariant qvariant(value);

  if (!object.setProperty(property, qvariant)) {
    qWarning() << QStringLiteral("Unable to set property: `%1`.").arg(property);
    return false;
  }

  return true;
}

// -----------------------------------------------------------------------------

Notifier::Notifier (QObject *parent) :
  QObject(parent) {
  QQmlEngine *engine = App::getInstance()->getEngine();

  // Build components.
  m_components[Notifier::Call] = new QQmlComponent(engine, QUrl(QML_CALL_NOTIFICATION_PATH));
  m_components[Notifier::MessageReceived] = new QQmlComponent(engine, QUrl(QML_MESSAGE_RECEIVED_NOTIFICATION_PATH));

  // Check errors.
  for (int i = 0; i < Notifier::MaxNbTypes; ++i) {
    QQmlComponent *component = m_components[i];
    if (component->isError()) {
      qWarning() << QStringLiteral("Errors found in `Notification` component %1:").arg(i) <<
        component->errors();
      abort();
    }
  }
}

Notifier::~Notifier () {
  for (int i = 0; i < Notifier::MaxNbTypes; i++)
    delete m_components[i];
}

// -----------------------------------------------------------------------------

QObject *Notifier::createNotification (Notifier::NotificationType type) {
  m_mutex.lock();

  // Check existing instances.
  if (m_n_instances >= N_MAX_NOTIFICATIONS) {
    qWarning() << "Unable to create another notification";
    m_mutex.unlock();
    return nullptr;
  }

  // Create instance and set attributes.
  QObject *object = m_components[type]->create();
  int offset = getNotificationSize(*object, NOTIFICATION_HEIGHT_PROPERTY);

  if (offset == -1 || !::setProperty(*object, NOTIFICATION_OFFSET_PROPERTY_NAME, m_offset)) {
    delete object;
    m_mutex.unlock();
    return nullptr;
  }

  m_offset = (offset + m_offset) + NOTIFICATION_SPACING;
  m_n_instances++;

  m_mutex.unlock();

  return object;
}

void Notifier::showNotification (QObject *notification, int timeout) {
  if (timeout > MAX_TIMEOUT) {
    timeout = MAX_TIMEOUT;
  }

  // Display notification.
  QMetaObject::invokeMethod(
    notification, NOTIFICATION_SHOW_METHOD_NAME,
    Qt::DirectConnection
  );

  QQuickWindow *window = notification->findChild<QQuickWindow *>();

  if (!window)
    qFatal("Cannot found a `QQuickWindow` instance in `notification`.");

  // Called explicitly (by a click on notification for example)
  // or when single shot happen and if notification is visible.
  QObject::connect(
    window, &QQuickWindow::visibleChanged, [this](const bool &visible) {
      qInfo() << "Update notifications counter, hidden notification detected.";

      if (visible)
        qFatal("A notification cannot be visible twice!");

      m_mutex.lock();

      m_n_instances--;

      if (m_n_instances == 0)
        m_offset = 0;

      m_mutex.unlock();
    }
  );

  // Destroy it after timeout.
  QTimer::singleShot(
    timeout, this, [notification]() {
      delete notification;
    }
  );
}

// -----------------------------------------------------------------------------

void Notifier::notifyReceivedMessage (
  int timeout,
  const shared_ptr<linphone::ChatRoom> &room,
  const shared_ptr<linphone::ChatMessage> &message
) {
  QObject *object = createNotification(Notifier::MessageReceived);

  if (object)
    showNotification(object, timeout);
}

void Notifier::showCallMessage (int timeout, const QString &) {
  QObject *object = createNotification(Notifier::Call);

  if (object)
    showNotification(object, timeout);
}
