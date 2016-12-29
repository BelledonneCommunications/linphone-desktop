#include "../../app/App.hpp"

#include "ContactModel.hpp"

using namespace std;

// =============================================================================

ContactModel::ContactModel (shared_ptr<linphone::Friend> linphone_friend) {
  m_linphone_friend = linphone_friend;
  m_vcard = make_shared<VcardModel>(linphone_friend->getVcard());

  App::getInstance()->getEngine()->setObjectOwnership(m_vcard.get(), QQmlEngine::CppOwnership);
  QObject::connect(m_vcard.get(), &VcardModel::vcardUpdated, this, &ContactModel::contactUpdated);
}

ContactModel::ContactModel (VcardModel *vcard) {
  QQmlEngine *engine = App::getInstance()->getEngine();
  if (engine->objectOwnership(vcard) == QQmlEngine::CppOwnership)
    throw invalid_argument("A contact is already linked to this vcard.");

  m_linphone_friend = linphone::Friend::newFromVcard(vcard->m_vcard);
  m_vcard.reset(vcard);

  engine->setObjectOwnership(vcard, QQmlEngine::CppOwnership);
  QObject::connect(vcard, &VcardModel::vcardUpdated, this, &ContactModel::contactUpdated);
}

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return Presence::PresenceStatus::Offline;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}
