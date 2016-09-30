#include <QtDebug>

#include "Notification.hpp"

// ===================================================================

Notification::Notification (QObject *parent) :
  QObject(parent) {
}

void Notification::showMessage (
  const QString &summary,
  const QString &body,
  const QString &icon,
  int timeout
) {
  qDebug() <<
    "Notification.showMessage(" << summary << ", " <<
    body << ", " << icon << ", " << timeout << ")";
}
