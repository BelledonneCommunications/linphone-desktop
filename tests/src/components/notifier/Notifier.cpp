#include <QTimer>
#include <QtDebug>

#include "../../app/App.hpp"
#include "Notifier.hpp"

// Notifications QML properties/methods.
#define NOTIFICATION_SHOW_METHOD_NAME "show"

#define NOTIFICATION_EDGE_PROPERTY_NAME "edge"
#define NOTIFICATION_HEIGHT_PROPERTY "popupHeight"
#define NOTIFICATION_OFFSET_PROPERTY_NAME "edgeOffset"

// Arbitrary hardcoded values.
#define NOTIFICATION_SPACING 10
#define NOTIFICATION_START_OFFSET 30
#define N_MAX_NOTIFICATIONS 3

// ===================================================================

// Helpers.
inline int getNotificationSize (const QObject &object, const char *property) {
  QVariant variant(object.property(property));
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

Notifier::Notifier (QObject *parent) :
  QObject(parent), m_offset(NOTIFICATION_START_OFFSET) {
  QQmlEngine *engine = App::getInstance()->getEngine();

  // Build components.
  m_components[Notifier::Call] = new QQmlComponent(
    engine, QUrl("qrc:/ui/modules/Linphone/Notifications/CallNotification.qml")
  );

  // Check errors.
  for (int i = 0; i < Notifier::MaxNbTypes; i++) {
    QQmlComponent &component = *m_components[i];
    if (component.isError()) {
      qWarning() << "Errors found in `Notification` component "
                 << i << ":" << component.errors();
      abort();
    }
  }
}

Notifier::~Notifier () {
  for (int i = 0; i < Notifier::MaxNbTypes; i++)
    delete m_components[i];
}

// -------------------------------------------------------------------

void Notifier::showCallMessage (
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
  QObject *object = m_components[Notifier::Call]->create();
  int offset = getNotificationSize(*object, NOTIFICATION_HEIGHT_PROPERTY);

  if (
    offset == -1 ||
    !::setProperty(*object, NOTIFICATION_EDGE_PROPERTY_NAME, Qt::TopEdge | Qt::RightEdge) ||
    !::setProperty(*object, NOTIFICATION_OFFSET_PROPERTY_NAME, m_offset)
  ) {
    delete object;
    m_mutex.unlock();
    return;
  }

  m_offset = (offset + m_offset) + NOTIFICATION_SPACING;
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
      m_offset = NOTIFICATION_START_OFFSET;

    m_mutex.unlock();
  });
}
