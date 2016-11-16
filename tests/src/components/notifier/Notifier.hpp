#ifndef NOTIFIER_H_
#define NOTIFIER_H_

#include <QMutex>
#include <QObject>
#include <QQmlComponent>

// ===================================================================

class Notifier : public QObject {
  Q_OBJECT;

public:
  Notifier (QObject *parent = Q_NULLPTR);
  virtual ~Notifier ();

  enum NotificationType {
    Call,
    MaxNbTypes
  };

public slots:
  void showCallMessage (int timeout, const QString &sip_address);

private:
  QObject *createNotification (NotificationType type);
  void handleNotificationHidden ();
  void showNotification (QObject *notification, int timeout);

  QQmlComponent *m_components[MaxNbTypes];

  int m_offset = 0;
  unsigned int m_n_instances = 0;
  QMutex m_mutex;
};

#endif // NOTIFIER_H_
