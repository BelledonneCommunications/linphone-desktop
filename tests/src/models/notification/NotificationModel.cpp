#include <QtDebug>

#include "NotificationModel.hpp"

// ===================================================================

NotificationModel::NotificationModel (QObject *parent) :
  QObject(parent) {
}

void NotificationModel::showMessage (
  const QString &summary,
  const QString &body,
  const QString &icon,
  int timeout
) {
  qDebug() <<
    "Notification.showMessage(" << summary << ", " <<
    body << ", " << icon << ", " << timeout << ")";
}
