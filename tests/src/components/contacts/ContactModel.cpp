#include "../../utils.hpp"

#include "ContactModel.hpp"

// ===================================================================

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return m_presence_status;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(m_presence_status);
}

QString ContactModel::getUsername () const {
  return Utils::linphoneStringToQString(
    m_linphone_friend->getName()
  );
}

QString ContactModel::getSipAddress () const {
  return Utils::linphoneStringToQString(
    m_linphone_friend->getAddress()->asString()
  );
}
