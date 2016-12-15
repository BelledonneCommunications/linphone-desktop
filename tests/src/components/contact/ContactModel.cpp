#include <QtDebug>

#include "../../app/App.hpp"

#include "ContactModel.hpp"

using namespace std;

// =============================================================================

const char *ContactModel::NAME = "contact-model";

ContactModel::ContactModel (shared_ptr<linphone::Friend> linphone_friend) {
  linphone_friend->setData(NAME, *this);
  m_linphone_friend = linphone_friend;
  m_vcard = make_shared<VcardModel>(linphone_friend->getVcard());

  App::getInstance()->getEngine()->setObjectOwnership(m_vcard.get(), QQmlEngine::CppOwnership);
}

ContactModel::ContactModel (VcardModel *vcard) {
  QQmlEngine *engine = App::getInstance()->getEngine();
  if (engine->objectOwnership(vcard) == QQmlEngine::CppOwnership)
    throw std::invalid_argument("A contact is already linked to this vcard.");

  m_linphone_friend = linphone::Friend::newFromVcard(vcard->m_vcard);
  m_linphone_friend->setData(NAME, *this);
  m_vcard.reset(vcard);

  engine->setObjectOwnership(vcard, QQmlEngine::CppOwnership);
}

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return Presence::PresenceStatus::Offline;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}
