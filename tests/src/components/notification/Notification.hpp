#ifndef NOTIFICATION_H_
#define NOTIFICATION_H_

#include <QMutex>
#include <QObject>
#include <QQmlComponent>

// ===================================================================

class Notification : public QObject {
  Q_OBJECT;

public:
  Notification (QObject *parent = Q_NULLPTR);
  virtual ~Notification ();

  enum Type {
    Call,
    MaxNbTypes
  };
  Q_ENUM(Type);

  void setEdge (Qt::Edges edge) {
    m_edge = edge;
  }

public slots:
  void showCallMessage (int timeout, const QString &sip_address);

private:
  Qt::Edges m_edge = Qt::RightEdge | Qt::TopEdge;
  QQmlComponent *m_components[MaxNbTypes];

  int m_offset = 0;
  int m_n_instances = 0;
  QMutex m_mutex;
};

#endif // NOTIFICATION_H_
