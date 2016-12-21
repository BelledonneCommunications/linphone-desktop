#include "../../app/Database.hpp"

#include "CoreManager.hpp"

using namespace std;

// =============================================================================

CoreManager *CoreManager::m_instance = nullptr;

CoreManager::CoreManager (QObject *parent) : QObject(parent),
  m_core(linphone::Factory::get()->createCore(nullptr, "", "", nullptr)) {
  setDatabasesPaths();
}

void CoreManager::init () {
  if (!m_instance) {
    m_instance = new CoreManager();

    m_instance->m_contacts_list_model = new ContactsListModel(m_instance);
    m_instance->m_sip_addresses_model = new SipAddressesModel(m_instance);
    m_instance->m_unregistered_sip_addresses_model = new UnregisteredSipAddressesModel(m_instance);
  }
}

VcardModel *CoreManager::createDetachedVcardModel () {
  return new VcardModel(linphone::Factory::get()->createVcard());
}

void CoreManager::setDatabasesPaths () {
  string database_path;

  database_path = Database::getFriendsListPath();
  if (database_path.length() == 0)
    qFatal("Unable to get friends list database path.");
  m_core->setFriendsDatabasePath(database_path);

  database_path = Database::getCallHistoryPath();
  if (database_path.length() == 0)
    qFatal("Unable to get call history database path.");
  m_core->setCallLogsDatabasePath(database_path);

  database_path = Database::getMessageHistoryPath();
  if (database_path.length() == 0)
    qFatal("Unable to get message history database path.");
  m_core->setChatDatabasePath(database_path);
}
