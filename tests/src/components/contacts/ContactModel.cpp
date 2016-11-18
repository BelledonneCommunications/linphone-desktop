#include "ContactModel.hpp"

// ===================================================================

QString ContactModel::getUsername () const {
  return m_username;
}

void ContactModel::setUsername (const QString &username) {
  m_username = username;
}

QString ContactModel::getAvatar () const {
  return m_avatar;
}

void ContactModel::setAvatar (const QString &avatar) {
  m_avatar = avatar;
}

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return m_presence_status;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(m_presence_status);
}
