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

QStringList ContactModel::getSipAddresses () const {
  return m_sip_addresses;
}

void ContactModel::setSipAddresses (const QStringList &sip_addresses) {
  m_sip_addresses = sip_addresses;
}
