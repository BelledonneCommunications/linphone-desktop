#include "AccountSettingsModel.hpp"

// ===================================================================

AccountSettingsModel::AccountSettingsModel (QObject *parent) :
  QObject(parent) {}

QString AccountSettingsModel::getUsername () const {
  return "Edward Miller ";
}

void AccountSettingsModel::setUsername (const QString &username) {
  // NOTHING TODO.
  (void) username;
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

bool AccountSettingsModel::getAutoAnswerStatus () const {
  return true;
}

// TODO: TMP
/*
   shared_ptr<linphone::ProxyConfig> cfg = m_core->getDefaultProxyConfig();
   shared_ptr<linphone::Address> address = cfg->getIdentityAddress();
   shared_ptr<linphone::AuthInfo> auth_info = m_core->findAuthInfo("", address->getUsername(), cfg->getDomain());

   if (auth_info)
   qDebug() << "OK";
   else
   qDebug() << "FAIL";

 */
