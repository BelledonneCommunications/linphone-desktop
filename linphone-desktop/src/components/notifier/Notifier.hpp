#ifndef NOTIFIER_H_
#define NOTIFIER_H_

#include <linphone++/linphone.hh>

#include <QMutex>
#include <QObject>

// =============================================================================

class QQmlComponent;

class Notifier : public QObject {
  Q_OBJECT;

public:
  Notifier (QObject *parent = Q_NULLPTR);
  ~Notifier ();

  enum NotificationType {
    Call,
    MessageReceived,
    MaxNbTypes
  };

  void notifyReceivedMessage (
    int timeout,
    const std::shared_ptr<linphone::ChatRoom> &room,
    const std::shared_ptr<linphone::ChatMessage> &message
  );

  // TODO
  void showCallMessage (int timeout, const QString &);

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
