#ifndef LINPHONE_CORE_H_
#define LINPHONE_CORE_H_

#include <QObject>

// ===================================================================

class LinphoneCore : public QObject {
  Q_OBJECT;

public:
  static void init () {
    if (!m_instance) {
      m_instance = new LinphoneCore();
    }
  }

  static LinphoneCore *getInstance () {
    return m_instance;
  }

private:
  LinphoneCore (QObject *parent = Q_NULLPTR) {};

  static LinphoneCore *m_instance;
};

#endif // LINPHONE_CORE_H_
