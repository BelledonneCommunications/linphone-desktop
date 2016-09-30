#ifndef NOTIFICATION_H_
#define NOTIFICATION_H_

#include <QObject>

// ===================================================================

class Notification : public QObject {
  Q_OBJECT

public:
  Notification (QObject *parent = Q_NULLPTR);

public slots:
  void showMessage (
    const QString &summary,
    const QString &body,
    const QString &icon = "",
    int timeout = 10000
  );
};

#endif // NOTIFICATION_H_
