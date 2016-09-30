#include "AccountSettingsModel.hpp"

typedef AccountSettingsModel::Presence Presence;

// ===================================================================

AccountSettingsModel::AccountSettingsModel (QObject *parent) :
  QObject(parent) {
}

QString AccountSettingsModel::getUsername () const {
  return "Toto";
}

void AccountSettingsModel::setUsername (const QString &username) {
  // NOTHING TODO.
  (void)username;
}


Presence AccountSettingsModel::getPresence () const {
  return Presence::Away;
}

void AccountSettingsModel::setPresence (Presence presence) {
  // NOTHING TODO.
  (void)presence;
}
