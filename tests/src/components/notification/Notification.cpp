#include <QTimer>
#include <QtDebug>

#include "../../app/App.hpp"
#include "Notification.hpp"

#define NOTIFICATION_SHOW_METHOD_NAME "show"
#define NOTIFICATION_EDGE_PROPERTY_NAME "edge"

#define NOTIFICATION_HEIGHT_PROPERTY "popupHeight"
#define NOTIFICATION_WIDTH_PROPERTY "popupWidth"

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

inline bool setNotificationEdge (QObject &object, int value) {
  QVariant edge(value);

  if (!object.setProperty("edge", edge)) {
    qWarning() << "Unable to set notification edge.";
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

  if (!setNotificationEdge(*object, m_edge)) {
    delete object;
    return;
  }

  QMetaObject::invokeMethod(object, "show", Qt::DirectConnection);
  QTimer::singleShot(timeout, object, [object]() {
    delete object;
  });
}
