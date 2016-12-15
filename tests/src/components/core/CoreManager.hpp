#ifndef CORE_MANAGER_H_
#define CORE_MANAGER_H_

#include <QObject>
#include <linphone++/linphone.hh>

#include "../contact/VcardModel.hpp"

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

public slots:
  VcardModel *createDetachedVcardModel ();

private:
  CoreManager (QObject *parent = Q_NULLPTR);

  void setDatabasesPaths ();

  std::shared_ptr<linphone::Core> m_core;
  static CoreManager *m_instance;
};

#endif // CORE_MANAGER_H_
