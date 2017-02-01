#include <QTimer>

#include "../../app/Paths.hpp"

#include "CoreManager.hpp"

using namespace std;

// =============================================================================

CoreManager *CoreManager::m_instance = nullptr;

CoreManager::CoreManager (QObject *parent) : QObject(parent), m_handlers(make_shared<CoreHandlers>()) {
  m_core = linphone::Factory::get()->createCore(m_handlers, Paths::getConfigFilepath(), "");

  m_core->setVideoDisplayFilter("MSOGL");
  m_core->usePreviewWindow(true);

  setDatabasesPaths();
}

void CoreManager::enableHandlers () {
  m_cbs_timer->start();
}

void CoreManager::init () {
  if (!m_instance) {
    m_instance = new CoreManager();

    m_instance->m_contacts_list_model = new ContactsListModel(m_instance);
    m_instance->m_sip_addresses_model = new SipAddressesModel(m_instance);

    QTimer *timer = m_instance->m_cbs_timer = new QTimer(m_instance);
    timer->setInterval(20);

    QObject::connect(
      timer, &QTimer::timeout, m_instance, []() {
        m_instance->m_core->iterate();
      }
    );
  }
}

VcardModel *CoreManager::createDetachedVcardModel () {
  return new VcardModel(linphone::Factory::get()->createVcard());
}

void CoreManager::setDatabasesPaths () {
  m_core->setFriendsDatabasePath(Paths::getFriendsListFilepath());
  m_core->setCallLogsDatabasePath(Paths::getCallHistoryFilepath());
  m_core->setChatDatabasePath(Paths::getMessageHistoryFilepath());
}
