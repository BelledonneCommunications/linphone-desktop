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

#include "../../Utils.hpp"
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

bool AccountSettingsModel::addOrUpdateProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  Q_ASSERT(proxyConfig != nullptr);

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  list<shared_ptr<linphone::ProxyConfig> > proxyConfigs = core->getProxyConfigList();
  if (find(proxyConfigs.cbegin(), proxyConfigs.cend(), proxyConfig) != proxyConfigs.cend()) {
    if (proxyConfig->done() == -1) {
      qWarning() << QStringLiteral("Unable to update proxy config: `%1`.")
        .arg(::Utils::linphoneStringToQString(proxyConfig->getIdentityAddress()->asString()));
      return false;
    }
  } else if (core->addProxyConfig(proxyConfig) == -1) {
    qWarning() << QStringLiteral("Unable to add proxy config: `%1`.")
      .arg(::Utils::linphoneStringToQString(proxyConfig->getIdentityAddress()->asString()));
    return false;
  }

  emit accountSettingsUpdated();

  return true;
}

QVariantMap AccountSettingsModel::getProxyConfigDescription (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  Q_ASSERT(proxyConfig != nullptr);

  QVariantMap map;

  {
    const shared_ptr<const linphone::Address> address = proxyConfig->getIdentityAddress();
    map["sipAddress"] = address
      ? ::Utils::linphoneStringToQString(proxyConfig->getIdentityAddress()->asStringUriOnly())
      : "";
  }

  map["serverAddress"] = ::Utils::linphoneStringToQString(proxyConfig->getServerAddr());
  map["registrationDuration"] = proxyConfig->getPublishExpires();
  map["transport"] = ::Utils::linphoneStringToQString(proxyConfig->getTransport());
  map["route"] = ::Utils::linphoneStringToQString(proxyConfig->getRoute());
  map["contactParams"] = ::Utils::linphoneStringToQString(proxyConfig->getContactParameters());
  map["avpfInterval"] = proxyConfig->getAvpfRrInterval();
  map["registerEnabled"] = proxyConfig->registerEnabled();
  map["publishPresence"] = proxyConfig->publishEnabled();
  map["avpfEnabled"] = proxyConfig->getAvpfMode() == linphone::AVPFMode::AVPFModeEnabled;
  map["registrationState"] = mapLinphoneRegistrationStateToUi(proxyConfig->getState());

  return map;
}

void AccountSettingsModel::setDefaultProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  CoreManager::getInstance()->getCore()->setDefaultProxyConfig(proxyConfig);
  emit accountSettingsUpdated();
}

void AccountSettingsModel::removeProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  Q_ASSERT(proxyConfig != nullptr);

  CoreManager::getInstance()->getCore()->removeProxyConfig(proxyConfig);
  emit accountSettingsUpdated();
}

bool AccountSettingsModel::addOrUpdateProxyConfig (
  const shared_ptr<linphone::ProxyConfig> &proxyConfig,
  const QVariantMap &data
) {
  Q_ASSERT(proxyConfig != nullptr);

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

    proxyConfig->setIdentityAddress(address);
  }

  // Server address.
  {
    QString serverAddress = data["serverAddress"].toString();

    if (proxyConfig->setServerAddr(::Utils::qStringToLinphoneString(serverAddress))) {
      qWarning() << QStringLiteral("Unable to add server address: `%1`.").arg(serverAddress);
      return false;
    }
  }

  proxyConfig->setPublishExpires(data["registrationDuration"].toInt());
  proxyConfig->setRoute(::Utils::qStringToLinphoneString(data["route"].toString()));
  proxyConfig->setContactParameters(::Utils::qStringToLinphoneString(data["contactParams"].toString()));
  proxyConfig->setAvpfRrInterval(static_cast<uint8_t>(data["avpfInterval"].toInt()));
  proxyConfig->enableRegister(data["registerEnabled"].toBool());
  proxyConfig->enablePublish(data["publishEnabled"].toBool());
  proxyConfig->setAvpfMode(data["avpfEnabled"].toBool()
    ? linphone::AVPFMode::AVPFModeEnabled
    : linphone::AVPFMode::AVPFModeDefault
  );

  return addOrUpdateProxyConfig(proxyConfig);
}

shared_ptr<linphone::ProxyConfig> AccountSettingsModel::createProxyConfig () {
  return CoreManager::getInstance()->getCore()->createProxyConfig();
}

void AccountSettingsModel::addAuthInfo (
  const shared_ptr<linphone::AuthInfo> &authInfo,
  const QString &password,
  const QString &userId
) {
  authInfo->setPasswd(::Utils::qStringToLinphoneString(password));
  authInfo->setUserid(::Utils::qStringToLinphoneString(userId));

  CoreManager::getInstance()->getCore()->addAuthInfo(authInfo);
}

void AccountSettingsModel::eraseAllPasswords () {
  CoreManager::getInstance()->getCore()->clearAllAuthInfo();
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getUsername () const {
  shared_ptr<const linphone::Address> address = getUsedSipAddress();
  const string &displayName = address->getDisplayName();

  return ::Utils::linphoneStringToQString(
    displayName.empty() ? address->getUsername() : displayName
  );
}

void AccountSettingsModel::setUsername (const QString &username) {
  shared_ptr<const linphone::Address> address = getUsedSipAddress();
  shared_ptr<linphone::Address> newAddress = address->clone();

  if (newAddress->setDisplayName(::Utils::qStringToLinphoneString(username))) {
    qWarning() << QStringLiteral("Unable to set displayName on sip address: `%1`.")
      .arg(::Utils::linphoneStringToQString(newAddress->asStringUriOnly()));
  } else {
    setUsedSipAddress(newAddress);
  }

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getSipAddress () const {
  return ::Utils::linphoneStringToQString(getUsedSipAddress()->asStringUriOnly());
}

AccountSettingsModel::RegistrationState AccountSettingsModel::getRegistrationState () const {
  shared_ptr<linphone::ProxyConfig> proxyConfig = CoreManager::getInstance()->getCore()->getDefaultProxyConfig();
  return proxyConfig ? mapLinphoneRegistrationStateToUi(proxyConfig->getState()) : RegistrationStateNotRegistered;
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

QString AccountSettingsModel::getPrimaryDisplayName () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getPrimaryContactParsed()->getDisplayName()
  );
}

void AccountSettingsModel::setPrimaryDisplayName (const QString &displayName) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> primary = core->getPrimaryContactParsed();

  primary->setDisplayName(::Utils::qStringToLinphoneString(displayName));
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

  for (const auto &proxyConfig : core->getProxyConfigList()) {
    QVariantMap account;
    account["sipAddress"] = ::Utils::linphoneStringToQString(proxyConfig->getIdentityAddress()->asStringUriOnly());
    account["proxyConfig"].setValue(proxyConfig);
    accounts << account;
  }

  return accounts;
}

// -----------------------------------------------------------------------------

void AccountSettingsModel::setUsedSipAddress (const shared_ptr<const linphone::Address> &address) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();

  proxyConfig ? proxyConfig->setIdentityAddress(address) : core->setPrimaryContact(address->asString());
}

shared_ptr<const linphone::Address> AccountSettingsModel::getUsedSipAddress () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();

  return proxyConfig ? proxyConfig->getIdentityAddress() : core->getPrimaryContactParsed();
}

// -----------------------------------------------------------------------------

void AccountSettingsModel::handleRegistrationStateChanged (
  const shared_ptr<linphone::ProxyConfig> &,
  linphone::RegistrationState
) {
  emit accountSettingsUpdated();
}
