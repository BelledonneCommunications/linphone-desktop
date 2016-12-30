#ifndef CORE_MANAGER_H_
#define CORE_MANAGER_H_

#include "../contacts/ContactsListModel.hpp"
#include "../sip-addresses/SipAddressesModel.hpp"

// =============================================================================

class CoreManager : public QObject {
  Q_OBJECT;

public:
  ~CoreManager () = default;

  std::shared_ptr<linphone::Core> getCore () {
    return m_core;
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

  static void init ();

  static CoreManager *getInstance () {
    return m_instance;
  }

  // Must be used in a qml scene.
  // Warning: The ownership of `VcardModel` is `QQmlEngine::JavaScriptOwnership` by default.
  Q_INVOKABLE VcardModel *createDetachedVcardModel ();

private:
  CoreManager (QObject *parent = Q_NULLPTR);

  void setDatabasesPaths ();

  std::shared_ptr<linphone::Core> m_core;
  ContactsListModel *m_contacts_list_model;
  SipAddressesModel *m_sip_addresses_model;

  static CoreManager *m_instance;
};

#endif // CORE_MANAGER_H_
