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

  enum Type {
    Call,
    MaxNbTypes
  };
  Q_ENUM(Type);

public slots:
  void showCallMessage (int timeout, const QString &sip_address);

private:
  QQmlComponent *m_components[MaxNbTypes];

  int m_offset = 0;
  int m_n_instances = 0;
  QMutex m_mutex;
};

#endif // NOTIFIER_H_
