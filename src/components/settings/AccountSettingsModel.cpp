/*
 * AccountSettingsModel.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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

#include "config.h"

#include "app/paths/Paths.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "AccountSettingsModel.hpp"
#include "SettingsModel.hpp"

// =============================================================================

using namespace std;

static inline AccountSettingsModel::RegistrationState mapLinphoneRegistrationStateToUi (linphone::RegistrationState state) {
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
    CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::registrationStateChanged,
    this, &AccountSettingsModel::handleRegistrationStateChanged
  );
}

// -----------------------------------------------------------------------------

bool AccountSettingsModel::addOrUpdateProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  Q_CHECK_PTR(proxyConfig);

  CoreManager *coreManager = CoreManager::getInstance();
  shared_ptr<linphone::Core> core = coreManager->getCore();

  list<shared_ptr<linphone::ProxyConfig>> proxyConfigs = core->getProxyConfigList();
  if (find(proxyConfigs.cbegin(), proxyConfigs.cend(), proxyConfig) != proxyConfigs.cend()) {
    if (proxyConfig->done() == -1) {
      qWarning() << QStringLiteral("Unable to update proxy config: `%1`.")
        .arg(Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asString()));
      return false;
    }
    coreManager->getSettingsModel()->configureRlsUri();
  } else {
    if (core->addProxyConfig(proxyConfig) == -1) {
      qWarning() << QStringLiteral("Unable to add proxy config: `%1`.")
        .arg(Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asString()));
      return false;
    }
    coreManager->getSettingsModel()->configureRlsUri(proxyConfig);
  }
  emit accountSettingsUpdated();

  return true;
}

QVariantMap AccountSettingsModel::getProxyConfigDescription (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  Q_CHECK_PTR(proxyConfig);

  QVariantMap map;

  {
    const shared_ptr<const linphone::Address> address = proxyConfig->getIdentityAddress();
    map["sipAddress"] = address
      ? Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asString())
      : QString("");
  }
  map["serverAddress"] = Utils::coreStringToAppString(proxyConfig->getServerAddr());
  map["registrationDuration"] = proxyConfig->getPublishExpires();
  map["transport"] = Utils::coreStringToAppString(proxyConfig->getTransport());
  map["route"] = Utils::coreStringToAppString(proxyConfig->getRoute());
  map["contactParams"] = Utils::coreStringToAppString(proxyConfig->getContactParameters());
  map["avpfInterval"] = proxyConfig->getAvpfRrInterval();
  map["registerEnabled"] = proxyConfig->registerEnabled();
  map["publishPresence"] = proxyConfig->publishEnabled();
  map["avpfEnabled"] = proxyConfig->getAvpfMode() == linphone::AVPFMode::AVPFModeEnabled;
  map["registrationState"] = mapLinphoneRegistrationStateToUi(proxyConfig->getState());

  shared_ptr<linphone::NatPolicy> natPolicy = proxyConfig->getNatPolicy();
  if (!natPolicy)
    natPolicy = proxyConfig->getCore()->createNatPolicy();
  map["iceEnabled"] = natPolicy->iceEnabled();
  map["turnEnabled"] = natPolicy->turnEnabled();
  map["stunServer"] = Utils::coreStringToAppString(natPolicy->getStunServer());
  map["turnUser"] = Utils::coreStringToAppString(natPolicy->getStunServerUsername());
  shared_ptr<const linphone::AuthInfo> authInfo = proxyConfig->findAuthInfo();
  map["turnPassword"] = authInfo ? Utils::coreStringToAppString(authInfo->getPasswd()) : QString("");

  return map;
}

void AccountSettingsModel::setDefaultProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  CoreManager::getInstance()->getCore()->setDefaultProxyConfig(proxyConfig);
  emit accountSettingsUpdated();
}

void AccountSettingsModel::removeProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  Q_CHECK_PTR(proxyConfig);

  CoreManager *coreManager = CoreManager::getInstance();
  coreManager->getCore()->removeProxyConfig(proxyConfig);
  coreManager->getSettingsModel()->configureRlsUri();

  emit accountSettingsUpdated();
}

bool AccountSettingsModel::addOrUpdateProxyConfig (
  const shared_ptr<linphone::ProxyConfig> &proxyConfig,
  const QVariantMap &data
) {
  Q_CHECK_PTR(proxyConfig);

  QString literal = data["sipAddress"].toString();

  // Sip address.
  {
    shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
      Utils::appStringToCoreString(literal)
    );
    if (!address) {
      qWarning() << QStringLiteral("Unable to create sip address object from: `%1`.").arg(literal);
      return false;
    }

    if (proxyConfig->setIdentityAddress(address)) {
      qWarning() << QStringLiteral("Unable to set identity address: `%1`.")
        .arg(Utils::coreStringToAppString(address->asStringUriOnly()));
      return false;
    }
  }

  // Server address.
  {
    QString serverAddress = data["serverAddress"].toString();

    if (proxyConfig->setServerAddr(Utils::appStringToCoreString(serverAddress))) {
      qWarning() << QStringLiteral("Unable to add server address: `%1`.").arg(serverAddress);
      return false;
    }
  }

  proxyConfig->setPublishExpires(data["registrationDuration"].toInt());
  proxyConfig->setRoute(Utils::appStringToCoreString(data["route"].toString()));
  proxyConfig->setContactParameters(Utils::appStringToCoreString(data["contactParams"].toString()));
  proxyConfig->setAvpfRrInterval(uint8_t(data["avpfInterval"].toInt()));
  proxyConfig->enableRegister(data["registerEnabled"].toBool());
  proxyConfig->enablePublish(data["publishPresence"].toBool());
  proxyConfig->setAvpfMode(data["avpfEnabled"].toBool()
    ? linphone::AVPFMode::AVPFModeEnabled
    : linphone::AVPFMode::AVPFModeDefault
  );

  shared_ptr<linphone::NatPolicy> natPolicy = proxyConfig->getNatPolicy();
  if (!natPolicy)
    natPolicy = proxyConfig->getCore()->createNatPolicy();
  natPolicy->enableIce(data["iceEnabled"].toBool());
  natPolicy->enableStun(data["iceEnabled"].toBool());
  natPolicy->enableTurn(data["turnEnabled"].toBool());
  natPolicy->setStunServer(Utils::appStringToCoreString(data["stunServer"].toString()));
  natPolicy->setStunServerUsername(Utils::appStringToCoreString(data["turnUser"].toString()));

  shared_ptr<const linphone::AuthInfo> authInfo = proxyConfig->findAuthInfo();
  shared_ptr<linphone::Core> core = proxyConfig->getCore();
  if (authInfo) {
    shared_ptr<linphone::AuthInfo> clonedAuthInfo = authInfo->clone();
    clonedAuthInfo->setPasswd(Utils::appStringToCoreString(data["turnPassword"].toString()));

    core->removeAuthInfo(authInfo);
    core->addAuthInfo(clonedAuthInfo);
  } else {
    authInfo = linphone::Factory::get()->createAuthInfo(
      Utils::appStringToCoreString(data["turnUser"].toString()),
      Utils::appStringToCoreString(data["turnUser"].toString()),
      Utils::appStringToCoreString(data["turnPassword"].toString()),
      "",
      "",
      ""
    );
    core->addAuthInfo(authInfo);
  }

  return addOrUpdateProxyConfig(proxyConfig);
}

shared_ptr<linphone::ProxyConfig> AccountSettingsModel::createProxyConfig () {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  core->getConfig()->loadFromXmlFile(
    Paths::getAssistantConfigDirPath() + "create-linphone-sip-account.rc"
  );

  return core->createProxyConfig();
}

void AccountSettingsModel::addAuthInfo (
  const shared_ptr<linphone::AuthInfo> &authInfo,
  const QString &password,
  const QString &userId
) {
  authInfo->setPasswd(Utils::appStringToCoreString(password));
  authInfo->setUserid(Utils::appStringToCoreString(userId));

  CoreManager::getInstance()->getCore()->addAuthInfo(authInfo);
}

void AccountSettingsModel::eraseAllPasswords () {
  CoreManager::getInstance()->getCore()->clearAllAuthInfo();
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getUsername () const {
  shared_ptr<const linphone::Address> address = getUsedSipAddress();
  const string displayName = address->getDisplayName();

  return Utils::coreStringToAppString(
    displayName.empty() ? address->getUsername() : displayName
  );
}

void AccountSettingsModel::setUsername (const QString &username) {
  shared_ptr<const linphone::Address> address = getUsedSipAddress();
  shared_ptr<linphone::Address> newAddress = address->clone();

  if (newAddress->setDisplayName(Utils::appStringToCoreString(username))) {
    qWarning() << QStringLiteral("Unable to set displayName on sip address: `%1`.")
      .arg(Utils::coreStringToAppString(newAddress->asStringUriOnly()));
  } else {
    setUsedSipAddress(newAddress);
  }

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getSipAddress () const {
  return Utils::coreStringToAppString(getUsedSipAddress()->asStringUriOnly());
}

AccountSettingsModel::RegistrationState AccountSettingsModel::getRegistrationState () const {
  shared_ptr<linphone::ProxyConfig> proxyConfig = CoreManager::getInstance()->getCore()->getDefaultProxyConfig();
  return proxyConfig ? mapLinphoneRegistrationStateToUi(proxyConfig->getState()) : RegistrationStateNotRegistered;
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getPrimaryUsername () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getPrimaryContactParsed()->getUsername()
  );
}

void AccountSettingsModel::setPrimaryUsername (const QString &username) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> primary = core->getPrimaryContactParsed();

  primary->setUsername(Utils::appStringToCoreString(
    username.isEmpty() ? APPLICATION_NAME : username
  ));
  core->setPrimaryContact(primary->asString());

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getPrimaryDisplayName () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getPrimaryContactParsed()->getDisplayName()
  );
}

void AccountSettingsModel::setPrimaryDisplayName (const QString &displayName) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> primary = core->getPrimaryContactParsed();

  primary->setDisplayName(Utils::appStringToCoreString(displayName));
  core->setPrimaryContact(primary->asString());

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getPrimarySipAddress () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getPrimaryContactParsed()->asString()
  );
}

// -----------------------------------------------------------------------------

QVariantList AccountSettingsModel::getAccounts () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  QVariantList accounts;

  {
    QVariantMap account;
    account["sipAddress"] = Utils::coreStringToAppString(core->getPrimaryContactParsed()->asStringUriOnly());
    accounts << account;
  }

  for (const auto &proxyConfig : core->getProxyConfigList()) {
    QVariantMap account;
    account["sipAddress"] = Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asStringUriOnly());
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
