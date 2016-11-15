#include <QTimer>
#include <QtDebug>

#include "../../app/App.hpp"
#include "Notification.hpp"

#define NOTIFICATION_SHOW_METHOD_NAME "show"

#define NOTIFICATION_EDGE_PROPERTY_NAME "edge"
#define NOTIFICATION_HEIGHT_PROPERTY "popupHeight"
#define NOTIFICATION_OFFSET_PROPERTY_NAME "edgeOffset"

#define NOTIFICATION_SPACING 10

#define N_MAX_NOTIFICATIONS 3

// ===================================================================

// Helpers.
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
    qWarning() << "Unable to set property `" << property << "`.";
    return false;
  }

  return true;
}

// -------------------------------------------------------------------

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

void Notification::showCallMessage (
  int timeout,
  const QString &sip_address
) {
  qDebug() << "Show call notification message. (addr=" <<
    sip_address << ")";

  m_mutex.lock();

  // Check existing instances.
  if (m_n_instances >= N_MAX_NOTIFICATIONS) {
    qWarning() << "Unable to create another notification";
    m_mutex.unlock();
    return;
  }

  // Create instance and set attributes.
  QObject *object = m_components[Notification::Call]->create();
  int offset = getNotificationSize(*object, NOTIFICATION_HEIGHT_PROPERTY);

  if (
    offset == -1 ||
    !::setProperty(*object, NOTIFICATION_EDGE_PROPERTY_NAME, m_edge) ||
    !::setProperty(*object, NOTIFICATION_OFFSET_PROPERTY_NAME, m_offset)
  ) {
    delete object;
    m_mutex.unlock();
    return;
  }

  m_offset = (m_n_instances == 0 ? offset : offset + m_offset) + NOTIFICATION_SPACING;
  m_n_instances++;

  m_mutex.unlock();

  // Display popup.
  QMetaObject::invokeMethod(object, "show", Qt::DirectConnection);

  // Destroy it after timeout.
  QTimer::singleShot(timeout, this, [object,this]() {
    delete object;

    m_mutex.lock();
    m_n_instances--;

    if (m_n_instances == 0)
      m_offset = 0;

    m_mutex.unlock();
  });
}
