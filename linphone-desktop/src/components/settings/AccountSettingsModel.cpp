/*
 * AccountSettingsModel.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include <QtDebug>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "AccountSettingsModel.hpp"

using namespace std;

// =============================================================================

inline AccountSettingsModel::RegistrationState mapLinphoneRegistrationStateToUi (linphone::RegistrationState state) {
  switch (state) {
    case linphone::RegistrationStateNone:
    case linphone::RegistrationStateCleared:
    case linphone::RegistrationStateFailed:
      return AccountSettingsModel::RegistrationStateNotRegistered;

    case linphone::RegistrationStateProgress:
      return AccountSettingsModel::RegistrationStateInProgress;

    case linphone::RegistrationStateOk:
      break;
  }

  return AccountSettingsModel::RegistrationStateRegistered;
}

// -----------------------------------------------------------------------------

AccountSettingsModel::AccountSettingsModel (QObject *parent) : QObject(parent) {
  QObject::connect(
    &(*CoreManager::getInstance()->getHandlers()), &CoreHandlers::registrationStateChanged,
    this, &AccountSettingsModel::handleRegistrationStateChanged
  );
}

// -----------------------------------------------------------------------------

bool AccountSettingsModel::addOrUpdateProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxy_config) {
  Q_ASSERT(proxy_config != nullptr);

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  list<shared_ptr<linphone::ProxyConfig> > proxy_configs = core->getProxyConfigList();
  if (find(proxy_configs.cbegin(), proxy_configs.cend(), proxy_config) != proxy_configs.cend()) {
    if (proxy_config->done() == -1) {
      qWarning() << QStringLiteral("Unable to update proxy config: `%1`.")
        .arg(::Utils::linphoneStringToQString(proxy_config->getIdentityAddress()->asString()));
      return false;
    }
  } else if (core->addProxyConfig(proxy_config) == -1) {
    qWarning() << QStringLiteral("Unable to add proxy config: `%1`.")
      .arg(::Utils::linphoneStringToQString(proxy_config->getIdentityAddress()->asString()));
    return false;
  }

  emit accountSettingsUpdated();

  return true;
}

QVariantMap AccountSettingsModel::getProxyConfigDescription (const shared_ptr<linphone::ProxyConfig> &proxy_config) {
  Q_ASSERT(proxy_config != nullptr);

  QVariantMap map;

  {
    const shared_ptr<const linphone::Address> address = proxy_config->getIdentityAddress();
    map["sipAddress"] = address
      ? ::Utils::linphoneStringToQString(proxy_config->getIdentityAddress()->asStringUriOnly())
      : "";
  }

  map["serverAddress"] = ::Utils::linphoneStringToQString(proxy_config->getServerAddr());
  map["registrationDuration"] = proxy_config->getPublishExpires();
  map["transport"] = ::Utils::linphoneStringToQString(proxy_config->getTransport());
  map["route"] = ::Utils::linphoneStringToQString(proxy_config->getRoute());
  map["contactParams"] = ::Utils::linphoneStringToQString(proxy_config->getContactParameters());
  map["avpfInterval"] = proxy_config->getAvpfRrInterval();
  map["registerEnabled"] = proxy_config->registerEnabled();
  map["publishPresence"] = proxy_config->publishEnabled();
  map["avpfEnabled"] = proxy_config->getAvpfMode() == linphone::AVPFMode::AVPFModeEnabled;
  map["registrationState"] = mapLinphoneRegistrationStateToUi(proxy_config->getState());

  return map;
}

void AccountSettingsModel::setDefaultProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxy_config) {
  Q_ASSERT(proxy_config != nullptr);

  CoreManager::getInstance()->getCore()->setDefaultProxyConfig(proxy_config);
  emit accountSettingsUpdated();
}

void AccountSettingsModel::removeProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxy_config) {
  Q_ASSERT(proxy_config != nullptr);

  CoreManager::getInstance()->getCore()->removeProxyConfig(proxy_config);
  emit accountSettingsUpdated();
}

bool AccountSettingsModel::addOrUpdateProxyConfig (
  const shared_ptr<linphone::ProxyConfig> &proxy_config,
  const QVariantMap &data
) {
  Q_ASSERT(proxy_config != nullptr);

  QString literal = data["sipAddress"].toString();

  // Sip address.
  {
    shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
        ::Utils::qStringToLinphoneString(literal)
      );
    if (!address) {
      qWarning() << QStringLiteral("Unable to create sip address object from: `%1`.").arg(literal);
      return false;
    }

    proxy_config->setIdentityAddress(address);
  }

  // Server address.
  {
    QString server_address = data["serverAddress"].toString();

    if (proxy_config->setServerAddr(::Utils::qStringToLinphoneString(server_address))) {
      qWarning() << QStringLiteral("Unable to add server address: `%1`.").arg(server_address);
      return false;
    }
  }

  proxy_config->setPublishExpires(data["registrationDuration"].toInt());
  proxy_config->setRoute(::Utils::qStringToLinphoneString(data["route"].toString()));
  proxy_config->setContactParameters(::Utils::qStringToLinphoneString(data["contactParams"].toString()));
  proxy_config->setAvpfRrInterval(static_cast<uint8_t>(data["avpfInterval"].toInt()));
  proxy_config->enableRegister(data["registerEnabled"].toBool());
  proxy_config->enablePublish(data["publishEnabled"].toBool());
  proxy_config->setAvpfMode(data["avpfEnabled"].toBool()
    ? linphone::AVPFMode::AVPFModeEnabled
    : linphone::AVPFMode::AVPFModeDefault
  );

  return addOrUpdateProxyConfig(proxy_config);
}

shared_ptr<linphone::ProxyConfig> AccountSettingsModel::createProxyConfig () {
  return CoreManager::getInstance()->getCore()->createProxyConfig();
}

void AccountSettingsModel::eraseAllPasswords () {
  CoreManager::getInstance()->getCore()->clearAllAuthInfo();
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getUsername () const {
  shared_ptr<const linphone::Address> address = getUsedSipAddress();
  const string &display_name = address->getDisplayName();

  return ::Utils::linphoneStringToQString(
    display_name.empty() ? address->getUsername() : display_name
  );
}

void AccountSettingsModel::setUsername (const QString &username) {
  shared_ptr<const linphone::Address> address = getUsedSipAddress();
  shared_ptr<linphone::Address> new_address = address->clone();

  if (new_address->setDisplayName(::Utils::qStringToLinphoneString(username))) {
    qWarning() << QStringLiteral("Unable to set displayName on sip address: `%1`.")
      .arg(::Utils::linphoneStringToQString(new_address->asStringUriOnly()));
  } else {
    setUsedSipAddress(new_address);
  }

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getSipAddress () const {
  return ::Utils::linphoneStringToQString(getUsedSipAddress()->asStringUriOnly());
}

AccountSettingsModel::RegistrationState AccountSettingsModel::getRegistrationState () const {
  shared_ptr<linphone::ProxyConfig> proxy_config = CoreManager::getInstance()->getCore()->getDefaultProxyConfig();
  return proxy_config ? mapLinphoneRegistrationStateToUi(proxy_config->getState()) : RegistrationStateNotRegistered;
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getPrimaryUsername () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getPrimaryContactParsed()->getUsername()
  );
}

void AccountSettingsModel::setPrimaryUsername (const QString &username) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> primary = core->getPrimaryContactParsed();

  primary->setUsername(
    username.isEmpty() ? "linphone" : ::Utils::qStringToLinphoneString(username)
  );
  core->setPrimaryContact(primary->asString());

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getPrimaryDisplayname () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getPrimaryContactParsed()->getDisplayName()
  );
}

void AccountSettingsModel::setPrimaryDisplayname (const QString &displayname) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> primary = core->getPrimaryContactParsed();

  primary->setDisplayName(::Utils::qStringToLinphoneString(displayname));
  core->setPrimaryContact(primary->asString());

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getPrimarySipAddress () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getPrimaryContactParsed()->asString()
  );
}

// -----------------------------------------------------------------------------

QVariantList AccountSettingsModel::getAccounts () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  QVariantList accounts;

  {
    QVariantMap account;
    account["sipAddress"] = ::Utils::linphoneStringToQString(core->getPrimaryContactParsed()->asStringUriOnly());
    accounts << account;
  }

  for (const auto &proxy_config : core->getProxyConfigList()) {
    QVariantMap account;
    account["sipAddress"] = ::Utils::linphoneStringToQString(proxy_config->getIdentityAddress()->asStringUriOnly());
    account["proxyConfig"].setValue(proxy_config);
    accounts << account;
  }

  return accounts;
}

// -----------------------------------------------------------------------------

void AccountSettingsModel::setUsedSipAddress (const shared_ptr<const linphone::Address> &address) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::ProxyConfig> proxy_config = core->getDefaultProxyConfig();

  proxy_config ? proxy_config->setIdentityAddress(address) : core->setPrimaryContact(address->asString());
}

shared_ptr<const linphone::Address> AccountSettingsModel::getUsedSipAddress () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::ProxyConfig> proxy_config = core->getDefaultProxyConfig();

  return proxy_config ? proxy_config->getIdentityAddress() : core->getPrimaryContactParsed();
}

// -----------------------------------------------------------------------------

void AccountSettingsModel::handleRegistrationStateChanged (
  const shared_ptr<linphone::ProxyConfig> &,
  linphone::RegistrationState
) {
  emit accountSettingsUpdated();
}
