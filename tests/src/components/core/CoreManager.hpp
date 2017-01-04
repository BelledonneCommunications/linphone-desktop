#ifndef CORE_MANAGER_H_
#define CORE_MANAGER_H_

#include "../contacts/ContactsListModel.hpp"
#include "../sip-addresses/SipAddressesModel.hpp"
#include "CoreHandlers.hpp"

// =============================================================================

class QTimer;

class CoreManager : public QObject {
  Q_OBJECT;

public:
  ~CoreManager () = default;

  void enableHandlers ();

  std::shared_ptr<linphone::Core> getCore () {
    return m_core;
  }

  std::shared_ptr<CoreHandlers> getHandlers () {
    return m_handlers;
  }

  // ---------------------------------------------------------------------------
  // Singleton models.
  // ---------------------------------------------------------------------------

  ContactsListModel *getContactsListModel () {
    return m_contacts_list_model;
  }

  SipAddressesModel *getSipAddressesModel () {
    return m_sip_addresses_model;
  }

  // ---------------------------------------------------------------------------
  // Initialization.
  // ---------------------------------------------------------------------------

  static void init ();

  static CoreManager *getInstance () {
    return m_instance;
  }

  // ---------------------------------------------------------------------------

  // Must be used in a qml scene.
  // Warning: The ownership of `VcardModel` is `QQmlEngine::JavaScriptOwnership` by default.
  Q_INVOKABLE VcardModel *createDetachedVcardModel ();

private:
  CoreManager (QObject *parent = Q_NULLPTR);

  void setDatabasesPaths ();

  std::shared_ptr<linphone::Core> m_core;
  std::shared_ptr<CoreHandlers> m_handlers;

  ContactsListModel *m_contacts_list_model;
  SipAddressesModel *m_sip_addresses_model;

  QTimer *m_cbs_timer;

  static CoreManager *m_instance;
};

#endif // CORE_MANAGER_H_
