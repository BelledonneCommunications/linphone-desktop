#include <QSet>

#include "../../app/App.hpp"

#include "ContactModel.hpp"

using namespace std;

// =============================================================================

ContactModel::ContactModel (shared_ptr<linphone::Friend> linphone_friend) {
  m_linphone_friend = linphone_friend;
  m_vcard = make_shared<VcardModel>(linphone_friend->getVcard());

  App::getInstance()->getEngine()->setObjectOwnership(m_vcard.get(), QQmlEngine::CppOwnership);
}

ContactModel::ContactModel (VcardModel *vcard) {
  QQmlEngine *engine = App::getInstance()->getEngine();
  if (engine->objectOwnership(vcard) == QQmlEngine::CppOwnership)
    throw invalid_argument("A contact is already linked to this vcard.");

  m_linphone_friend = linphone::Friend::newFromVcard(vcard->m_vcard);
  m_vcard.reset(vcard);

  engine->setObjectOwnership(vcard, QQmlEngine::CppOwnership);
}

void ContactModel::startEdit () {
  m_linphone_friend->edit();
  m_old_sip_addresses = m_vcard->getSipAddresses();
}

void ContactModel::endEdit () {
  m_linphone_friend->done();

  QVariantList sip_addresses = m_vcard->getSipAddresses();
  QSet<QString> done;

  for (const auto &variant_a : m_old_sip_addresses) {
next:
    const QString &sip_address = variant_a.toString();
    if (done.contains(sip_address))
      continue;
    done.insert(sip_address);

    // Check if old sip address exists in new set => No changes.
    for (const auto &variant_b : sip_addresses) {
      if (sip_address == variant_b.toString())
        goto next;
    }

    emit sipAddressRemoved(sip_address);
  }

  m_old_sip_addresses.clear();

  for (const auto &variant : sip_addresses) {
    const QString &sip_address = variant.toString();
    if (done.contains(sip_address))
      continue;
    done.insert(sip_address);

    emit sipAddressAdded(sip_address);
  }

  emit contactUpdated();
}

void ContactModel::abortEdit () {
  // TODO: call linphone friend abort function when available.
  // m_linphone_friend->abort();
  m_old_sip_addresses.clear();
}

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return Presence::PresenceStatus::Offline;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}
