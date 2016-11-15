#include <QDesktopWidget>
#include <QTimer>
#include <QtDebug>

#include "../../app/App.hpp"
#include "Notification.hpp"

#define NOTIFICATION_X_PROPERTY "popupX"
#define NOTIFICATION_Y_PROPERTY "popupY"

#define NOTIFICATION_HEIGHT_PROPERTY "popupHeight"
#define NOTIFICATION_WIDTH_PROPERTY "popupWidth"

#define NOTIFICATION_SHOW_METHOD_NAME "show"

#define N_MAX_NOTIFICATIONS 3

// ===================================================================

Notification::Notification (QObject *parent) :
  QObject(parent) {
  QQmlEngine *engine = App::getInstance()->getEngine();

  // Build components.
  m_components[Notification::Call] = new QQmlComponent(
    engine, QUrl("qrc:/ui/modules/Linphone/Notifications/CallNotification.qml")
  );

  // Check errors.
  for (int i = 0; i < Notification::MaxNbTypes; i++) {
    QQmlComponent &component = *m_components[i];
    if (component.isError()) {
      qWarning() << "Errors found in `Notification` component "
                 << i << ":" << component.errors();
      abort();
    }
  }
}

Notification::~Notification () {
  for (int i = 0; i < Notification::MaxNbTypes; i++)
    delete m_components[i];
}

// -------------------------------------------------------------------

inline int getNotificationSize (const QObject &object, const char *size_property) {
  QVariant variant = object.property(size_property);
  bool so_far_so_good;
  int size = variant.toInt(&so_far_so_good);

  if (!so_far_so_good || size < 0) {
    qWarning() << "Unable to get notification size.";
    return -1;
  }

  return size;
}

inline bool setNotificationPosition (
  QObject &object, const char *position_property, int value
) {
  QVariant position(value);

  if (!object.setProperty(position_property, position)) {
    qWarning() << "Unable to set notification position.";
    return false;
  }

  return true;
}

void Notification::showCallMessage (
  int timeout,
  const QString &sip_address
) {
  qDebug() << "Show call notification message. (addr=" <<
    sip_address << ")";

  QObject *object = m_components[Notification::Call]->create();
  int width, height;

  if (
    (width = getNotificationSize(*object, NOTIFICATION_WIDTH_PROPERTY)) == -1 ||
    (height = getNotificationSize(*object, NOTIFICATION_HEIGHT_PROPERTY)) == -1
  ) {
    delete object;
    return;
  }

  QRect screen_rect = QApplication::desktop()->screenGeometry(m_screen_number);

  int x = (m_edge & Qt::LeftEdge) ? 5 : screen_rect.width() - 5 - width;
  int y = (m_edge & Qt::TopEdge) ? 5 : screen_rect.height() - 5 - height;

  if (
    !setNotificationPosition(*object, NOTIFICATION_X_PROPERTY, x) ||
    !setNotificationPosition(*object, NOTIFICATION_Y_PROPERTY, y)
  ) {
    delete object;
    return;
  }




  QMetaObject::invokeMethod(object, "show", Qt::DirectConnection);
  QTimer::singleShot(timeout, object, [object]() {
    delete object;
  });
}
