#include "AccountSettingsModel.hpp"

// ===================================================================

AccountSettingsModel::AccountSettingsModel (QObject *parent) :
  QObject(parent) {
}

QString AccountSettingsModel::getUsername () const {
  return "Edward Miller ";
}

void AccountSettingsModel::setUsername (const QString &username) {
  // NOTHING TODO.
  (void)username;
}

Presence::PresenceLevel AccountSettingsModel::getPresenceLevel () const {
  return Presence::Green;
}

Presence::PresenceStatus AccountSettingsModel::getPresenceStatus () const {
  return Presence::Online;
}

QString AccountSettingsModel::getSipAddress () const {
  return QString("e.miller@sip-linphone.org");
}
