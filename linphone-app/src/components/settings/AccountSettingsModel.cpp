/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QtDebug>

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
    case linphone::RegistrationState::None:
    case linphone::RegistrationState::Cleared:
    case linphone::RegistrationState::Failed:
      return AccountSettingsModel::RegistrationStateNotRegistered;

    case linphone::RegistrationState::Progress:
      return AccountSettingsModel::RegistrationStateInProgress;

    case linphone::RegistrationState::Ok:
      break;
  }

  return AccountSettingsModel::RegistrationStateRegistered;
}

// -----------------------------------------------------------------------------

AccountSettingsModel::AccountSettingsModel (QObject *parent) : QObject(parent) {
  CoreManager *coreManager = CoreManager::getInstance();
  QObject::connect(
    coreManager->getHandlers().get(), &CoreHandlers::registrationStateChanged,
    this, &AccountSettingsModel::handleRegistrationStateChanged
  );
  QObject::connect(coreManager, &CoreManager::eventCountChanged, this, [this]() { emit accountSettingsUpdated(); });
}

// -----------------------------------------------------------------------------

shared_ptr<const linphone::Address> AccountSettingsModel::getUsedSipAddress () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();

  return proxyConfig?proxyConfig->getIdentityAddress():core->createPrimaryContactParsed();
}

void AccountSettingsModel::setUsedSipAddress (const shared_ptr<const linphone::Address> &address) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();

  proxyConfig ? proxyConfig->setIdentityAddress(address) : core->setPrimaryContact(address->asString());
}

QString AccountSettingsModel::getUsedSipAddressAsStringUriOnly () const {
	return Utils::coreStringToAppString(getUsedSipAddress()->asStringUriOnly());
}

QString AccountSettingsModel::getUsedSipAddressAsString () const {
	return Utils::coreStringToAppString(getUsedSipAddress()->asString());
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

  if( map["serverAddress"].toString().toUpper().contains("TRANSPORT="))// transport has been specified : let the RFC select the transport
		map["transport"] = Utils::coreStringToAppString(proxyConfig->getTransport());
  else// Set to TLS as default
      map["transport"] = "tls";
  if( proxyConfig->getRoutes().size() > 0)
	map["route"] = Utils::coreStringToAppString(proxyConfig->getRoutes().front());
  else
    map["route"] = "";
  map["contactParams"] = Utils::coreStringToAppString(proxyConfig->getContactParameters());
  map["avpfInterval"] = proxyConfig->getAvpfRrInterval();
  map["registerEnabled"] = proxyConfig->registerEnabled();
  map["publishPresence"] = proxyConfig->publishEnabled();
  map["avpfEnabled"] = proxyConfig->getAvpfMode() == linphone::AVPFMode::Enabled;
  map["registrationState"] = mapLinphoneRegistrationStateToUi(proxyConfig->getState());

  shared_ptr<linphone::NatPolicy> natPolicy = proxyConfig->getNatPolicy();
  bool createdNat = !natPolicy;
  if (createdNat)
        natPolicy = proxyConfig->getCore()->createNatPolicy();
  map["iceEnabled"] = natPolicy->iceEnabled();
  map["turnEnabled"] = natPolicy->turnEnabled();

  const string &turnUser(natPolicy->getStunServerUsername());
  const string &stunServer(natPolicy->getStunServer());

  map["turnUser"] = Utils::coreStringToAppString(turnUser);
  map["stunServer"] = Utils::coreStringToAppString(stunServer);

  if (createdNat)
        proxyConfig->setNatPolicy(natPolicy);

  shared_ptr<const linphone::AuthInfo> authInfo = CoreManager::getInstance()->getCore()->findAuthInfo(
    "", turnUser, stunServer
  );
  map["turnPassword"] = authInfo ? Utils::coreStringToAppString(authInfo->getPassword()) : QString("");

  return map;
}

void AccountSettingsModel::setDefaultProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  if (core->getDefaultProxyConfig() != proxyConfig) {
    core->setDefaultProxyConfig(proxyConfig);
    emit accountSettingsUpdated();
  }
}

void AccountSettingsModel::setDefaultProxyConfigFromSipAddress (const QString &sipAddress) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  if (Utils::coreStringToAppString(core->createPrimaryContactParsed()->asStringUriOnly()) == sipAddress) {
    setDefaultProxyConfig(nullptr);
    return;
  }

  for (const auto &proxyConfig : core->getProxyConfigList())
    if (Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asStringUriOnly()) == sipAddress) {
      setDefaultProxyConfig(proxyConfig);
      return;
    }

  qWarning() << "Unable to set default proxy config from:" << sipAddress;
}
void AccountSettingsModel::removeProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
  Q_CHECK_PTR(proxyConfig);
  
  CoreManager *coreManager = CoreManager::getInstance();
  std::list<std::shared_ptr<linphone::ProxyConfig>> allProxies = coreManager->getCore()->getProxyConfigList();
  std::shared_ptr<const linphone::Address> proxyAddress = proxyConfig->getIdentityAddress();

  coreManager->getCore()->removeProxyConfig(proxyConfig);// Remove first to avoid requesting password when deleting it
  if(proxyConfig->findAuthInfo())
	coreManager->getCore()->removeAuthInfo(proxyConfig->findAuthInfo());// Remove passwords

  coreManager->getSettingsModel()->configureRlsUri();

  emit accountSettingsUpdated();
}

bool AccountSettingsModel::addOrUpdateProxyConfig (
  const shared_ptr<linphone::ProxyConfig> &proxyConfig,
  const QVariantMap &data
) {
  Q_CHECK_PTR(proxyConfig);
  bool newPublishPresence = false;

  proxyConfig->edit();

  QString literal = data["sipAddress"].toString();

  // Sip address.
  {
      shared_ptr<linphone::Address> address = CoreManager::getInstance()->getCore()->interpretUrl(literal.toStdString());
    if (!address) {
      qWarning() << QStringLiteral("Unable to create sip address object from: `%1`.").arg(literal);
      return false;
    }

    if (proxyConfig->setIdentityAddress(address)) {
      qWarning() << QStringLiteral("Unable to set identity address: `%1`.")
        .arg(Utils::coreStringToAppString(address->asStringUriOnly()));
      return false;
    }
	qWarning() << QStringLiteral("Set identity address: `%1`.")
	  .arg(Utils::coreStringToAppString(address->asStringUriOnly()));
  }

  // Server address.
  {
    QString serverAddress = data["serverAddress"].toString();

    if (proxyConfig->setServerAddr(Utils::appStringToCoreString(serverAddress))) {
      qWarning() << QStringLiteral("Unable to add server address: `%1`.").arg(serverAddress);
      return false;
    }
  }
  if(data.count("registrationDuration") >0)
	proxyConfig->setPublishExpires(data["registrationDuration"].toInt());
  if(data.count("route") >0)
	proxyConfig->setRoute(Utils::appStringToCoreString(data["route"].toString()));
  if(data.count("contactParams") >0)
	proxyConfig->setContactParameters(Utils::appStringToCoreString(data["contactParams"].toString()));
  if(data.count("avpfInterval") >0)
	proxyConfig->setAvpfRrInterval(uint8_t(data["avpfInterval"].toInt()));
  if(data.count("registerEnabled") >0)
	proxyConfig->enableRegister(data["registerEnabled"].toBool());
  if(data.count("publishPresence") >0) {
	newPublishPresence = proxyConfig->publishEnabled() != data["publishPresence"].toBool();
	proxyConfig->enablePublish(data["publishPresence"].toBool());
  }
  if(data.count("avpfEnabled") >0)
	proxyConfig->setAvpfMode(data["avpfEnabled"].toBool()
    ? linphone::AVPFMode::Enabled
    : linphone::AVPFMode::Default
  );

  shared_ptr<linphone::NatPolicy> natPolicy = proxyConfig->getNatPolicy();
  bool createdNat = !natPolicy;
  if (createdNat)
    natPolicy = proxyConfig->getCore()->createNatPolicy();
  if(data.count("iceEnabled") >0) {
	natPolicy->enableIce(data["iceEnabled"].toBool());
	natPolicy->enableStun(data["iceEnabled"].toBool());
  }
  string turnUser;
  string stunServer;
  string turnPassword;
  if(data.count("turnUser") >0) {
	turnUser = Utils::appStringToCoreString(data["turnUser"].toString());
	natPolicy->setStunServerUsername(turnUser);
  }
  if(data.count("stunServer") >0) {
	stunServer = Utils::appStringToCoreString(data["stunServer"].toString());
	natPolicy->setStunServer(stunServer);
  }
  if(data.count("turnPassword") >0) {
	  turnPassword = Utils::appStringToCoreString(data["turnPassword"].toString());
  }
  if(data.count("turnEnabled") >0)
	natPolicy->enableTurn(data["turnEnabled"].toBool());
  if( createdNat)
      proxyConfig->setNatPolicy(natPolicy);

  shared_ptr<linphone::Core> core(proxyConfig->getCore());
  shared_ptr<const linphone::AuthInfo> authInfo(core->findAuthInfo("", turnUser, stunServer));
  if (authInfo) {
    shared_ptr<linphone::AuthInfo> clonedAuthInfo(authInfo->clone());
    clonedAuthInfo->setUserid(turnUser);
    clonedAuthInfo->setUsername(turnUser);
    clonedAuthInfo->setPassword(turnPassword);

    core->addAuthInfo(clonedAuthInfo);
    core->removeAuthInfo(authInfo);
  } else
    core->addAuthInfo(linphone::Factory::get()->createAuthInfo(
      turnUser,
      turnUser,
	  turnPassword,
      "",
      stunServer,
      ""
    ));
  if( newPublishPresence)
    emit publishPresenceChanged();
  return addOrUpdateProxyConfig(proxyConfig);
}

bool AccountSettingsModel::addOrUpdateProxyConfig (
  const QVariantMap &data
) {
	shared_ptr<linphone::ProxyConfig> proxyConfig;
	QString sipAddress = data["sipAddress"].toString();
	shared_ptr<linphone::Address> address = CoreManager::getInstance()->getCore()->interpretUrl(sipAddress.toStdString());
	
	for (const auto &databaseProxyConfig : CoreManager::getInstance()->getCore()->getProxyConfigList())
	  if (databaseProxyConfig->getIdentityAddress()->weakEqual(address)) {
		proxyConfig = databaseProxyConfig;
	  }
	if(!proxyConfig)
		proxyConfig = createProxyConfig();
	return addOrUpdateProxyConfig(proxyConfig, data);
}

shared_ptr<linphone::ProxyConfig> AccountSettingsModel::createProxyConfig () {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  core->getConfig()->loadFromXmlFile(
    Paths::getAssistantConfigDirPath() + "create-app-sip-account.rc"
  );

  return core->createProxyConfig();	
}

void AccountSettingsModel::addAuthInfo (
  const shared_ptr<linphone::AuthInfo> &authInfo,
  const QString &password,
  const QString &userId
) {
  authInfo->setPassword(Utils::appStringToCoreString(password));
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

AccountSettingsModel::RegistrationState AccountSettingsModel::getRegistrationState () const {
  shared_ptr<linphone::ProxyConfig> proxyConfig = CoreManager::getInstance()->getCore()->getDefaultProxyConfig();
  return proxyConfig ? mapLinphoneRegistrationStateToUi(proxyConfig->getState()) : RegistrationStateNoProxy;
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getPrimaryUsername () const {
  return QString::fromStdString(
    CoreManager::getInstance()->getCore()->createPrimaryContactParsed()->getUsername()
  );
}

void AccountSettingsModel::setPrimaryUsername (const QString &username) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> primary = core->createPrimaryContactParsed();

  primary->setUsername(Utils::appStringToCoreString(
    username.isEmpty() ? APPLICATION_NAME : username
  ));
  core->setPrimaryContact(primary->asString());

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getPrimaryDisplayName () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->createPrimaryContactParsed()->getDisplayName()
  );
}

void AccountSettingsModel::setPrimaryDisplayName (const QString &displayName) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Address> primary = core->createPrimaryContactParsed();

  primary->setDisplayName(Utils::appStringToCoreString(displayName));
  core->setPrimaryContact(primary->asString());

  emit accountSettingsUpdated();
}

QString AccountSettingsModel::getPrimarySipAddress () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->createPrimaryContactParsed()->asString()
  );
}

// -----------------------------------------------------------------------------

QVariantList AccountSettingsModel::getAccounts () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  QVariantList accounts;

  {
    QVariantMap account;
    account["sipAddress"] = Utils::coreStringToAppString(core->createPrimaryContactParsed()->asStringUriOnly());
    account["fullSipAddress"] = Utils::coreStringToAppString(core->createPrimaryContactParsed()->asString());
    account["unreadMessageCount"] = core->getUnreadChatMessageCountFromLocal(core->createPrimaryContactParsed());
    account["missedCallCount"] = CoreManager::getInstance()->getMissedCallCountFromLocal(account["sipAddress"].toString());
    account["proxyConfig"].setValue(nullptr);
    accounts << account;
  }

  for (const auto &proxyConfig : core->getProxyConfigList()) {
    QVariantMap account;
    account["sipAddress"] = Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asStringUriOnly());
    account["fullSipAddress"] = Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asString());
    account["proxyConfig"].setValue(proxyConfig);
    account["unreadMessageCount"] = proxyConfig->getUnreadChatMessageCount();
    account["missedCallCount"] = CoreManager::getInstance()->getMissedCallCountFromLocal(account["sipAddress"].toString());
    accounts << account;
  }

  return accounts;
}

// -----------------------------------------------------------------------------

void AccountSettingsModel::handleRegistrationStateChanged (
  const shared_ptr<linphone::ProxyConfig> & proxy,
  linphone::RegistrationState core
) {
  Q_UNUSED(proxy)
  Q_UNUSED(core)
  emit accountSettingsUpdated();
}
