#ifndef CORE_MANAGER_H_
#define CORE_MANAGER_H_

#include <QObject>
#include <linphone++/linphone.hh>

// ===================================================================

class CoreManager : public QObject {
  Q_OBJECT;

public:
  static void init () {
    if (!m_instance) {
      m_instance = new CoreManager();
    }
  }

  static CoreManager *getInstance () {
    return m_instance;
  }

  std::shared_ptr<linphone::Core> getCore () {
    return m_core;
  }

private:
  CoreManager (QObject *parent = Q_NULLPTR);

  void setDatabasesPaths ();

  static CoreManager *m_instance;

  std::shared_ptr<linphone::Core> m_core;
};

#endif // CORE_MANAGER_H_
