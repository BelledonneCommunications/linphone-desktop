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

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return Presence::PresenceStatus::Offline;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}
