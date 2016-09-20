#ifndef NOTIFICATION_MODEL_H_
#define NOTIFICATION_MODEL_H_

#include <QObject>

// ===================================================================

class NotificationModel : public QObject {
  Q_OBJECT

public:
  NotificationModel (QObject *parent = Q_NULLPTR);

public slots:
  void showMessage (
    const QString &summary,
    const QString &body,
    const QString &icon = "",
    int timeout = 10000
  );
};

#endif // NOTIFICATION_MODEL_H_
