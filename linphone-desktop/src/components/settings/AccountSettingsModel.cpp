#include <QtDebug>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "AccountSettingsModel.hpp"

// =============================================================================

AccountSettingsModel::AccountSettingsModel (QObject *parent) : QObject(parent) {
  m_default_proxy = CoreManager::getInstance()->getCore()->getDefaultProxyConfig();
}

QString AccountSettingsModel::getUsername () const {
  shared_ptr<linphone::Address> address = getDefaultSipAddress();
  const string &display_name = address->getDisplayName();

  return ::Utils::linphoneStringToQString(
    display_name.empty() ? address->getUsername() : display_name
  );
}

void AccountSettingsModel::setUsername (const QString &username) {
  shared_ptr<linphone::Address> address = getDefaultSipAddress();

  if (address->setDisplayName(::Utils::qStringToLinphoneString(username)))
    qWarning() << QStringLiteral("Unable to set displayName on sip address: `%1`.")
      .arg(::Utils::linphoneStringToQString(address->asStringUriOnly()));

  emit accountUpdated();
}

Presence::PresenceLevel AccountSettingsModel::getPresenceLevel () const {
  return Presence::Green;
}

Presence::PresenceStatus AccountSettingsModel::getPresenceStatus () const {
  return Presence::Online;
}

QString AccountSettingsModel::getSipAddress () const {
  return ::Utils::linphoneStringToQString(getDefaultSipAddress()->asStringUriOnly());
}

// -----------------------------------------------------------------------------

shared_ptr<linphone::Address> AccountSettingsModel::getDefaultSipAddress () const {
  if (m_default_proxy)
    return m_default_proxy->getIdentityAddress();

  return CoreManager::getInstance()->getCore()->getPrimaryContactParsed();
}
