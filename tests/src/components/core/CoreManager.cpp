#include "../../app/Database.hpp"

#include "CoreManager.hpp"

using namespace std;

// =============================================================================

CoreManager *CoreManager::m_instance = nullptr;

CoreManager::CoreManager (QObject *parent) : QObject(parent),
  m_core(linphone::Factory::get()->createCore(nullptr, "", "", nullptr)) {
  setDatabasesPaths();
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
