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

#include "app/paths/Paths.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/LinphoneUtils.hpp"
#include "utils/Utils.hpp"

#include "AssistantModel.hpp"

#include <QtDebug>

// =============================================================================

using namespace std;

namespace {
  constexpr char DefaultXmlrpcUri[] = "https://subscribe.linphone.org:444/wizard.php";
}

class AssistantModel::Handlers : public linphone::AccountCreatorListener {
public:
  Handlers (AssistantModel *assistant) {
    mAssistant = assistant;
  }

private:
  void createProxyConfig (const shared_ptr<linphone::AccountCreator> &creator) {
    shared_ptr<linphone::ProxyConfig> proxyConfig = creator->createProxyConfig();
    Q_CHECK_PTR(proxyConfig);
    CoreManager::getInstance()->getSettingsModel()->configureRlsUri(proxyConfig);
  }

  void onCreateAccount (
    const shared_ptr<linphone::AccountCreator> &,
    linphone::AccountCreator::Status status,
    const string &
  ) override {
    if (status == linphone::AccountCreator::Status::AccountCreated){
      emit mAssistant->createStatusChanged(QString(""));
    }else {
      if (status == linphone::AccountCreator::Status::RequestFailed)
        emit mAssistant->createStatusChanged(tr("requestFailed"));
      else if (status == linphone::AccountCreator::Status::ServerError)
        emit mAssistant->createStatusChanged(tr("cannotSendSms"));
      else
        emit mAssistant->createStatusChanged(tr("accountAlreadyExists"));
    }
  }

  void onIsAccountExist (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreator::Status status,
    const string &
  ) override {
    if (status == linphone::AccountCreator::Status::AccountExist || status == linphone::AccountCreator::Status::AccountExistWithAlias) {
      createProxyConfig(creator);
      CoreManager::getInstance()->getSipAddressesModel()->reset();
      emit mAssistant->loginStatusChanged(QString(""));
    } else {
      if (status == linphone::AccountCreator::Status::RequestFailed)
        emit mAssistant->loginStatusChanged(tr("requestFailed"));
      else
        emit mAssistant->loginStatusChanged(tr("loginWithUsernameFailed"));
    }
  }

  void onActivateAccount (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreator::Status status,
    const string &
  ) override {
    if (
      status == linphone::AccountCreator::Status::AccountActivated ||
      status == linphone::AccountCreator::Status::AccountAlreadyActivated
    ) {
      if (creator->getEmail().empty())
        createProxyConfig(creator);
      CoreManager::getInstance()->getSipAddressesModel()->reset();
      emit mAssistant->activateStatusChanged(QString(""));
    } else {
      if (status == linphone::AccountCreator::Status::RequestFailed)
        emit mAssistant->activateStatusChanged(tr("requestFailed"));
      else
        emit mAssistant->activateStatusChanged(tr("smsActivationFailed"));
    }
  }

  void onIsAccountActivated (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreator::Status status,
    const string &
  ) override {
    if (status == linphone::AccountCreator::Status::AccountActivated) {
      createProxyConfig(creator);
      CoreManager::getInstance()->getSipAddressesModel()->reset();
      emit mAssistant->activateStatusChanged(QString(""));
    } else {
      if (status == linphone::AccountCreator::Status::RequestFailed)
        emit mAssistant->activateStatusChanged(tr("requestFailed"));
      else
        emit mAssistant->activateStatusChanged(tr("emailActivationFailed"));
    }
  }

  void onRecoverAccount (
    const shared_ptr<linphone::AccountCreator> &,
    linphone::AccountCreator::Status status,
    const string &
  ) override {
    if (status == linphone::AccountCreator::Status::RequestOk) {
      CoreManager::getInstance()->getSipAddressesModel()->reset();
      emit mAssistant->recoverStatusChanged(QString(""));
    } else {
      if (status == linphone::AccountCreator::Status::RequestFailed)
        emit mAssistant->recoverStatusChanged(tr("requestFailed"));
      else if (status == linphone::AccountCreator::Status::ServerError)
        emit mAssistant->recoverStatusChanged(tr("cannotSendSms"));
      else
        emit mAssistant->recoverStatusChanged(tr("loginWithPhoneNumberFailed"));
    }
  }

private:
  AssistantModel *mAssistant;
};

// -----------------------------------------------------------------------------

AssistantModel::AssistantModel (QObject *parent) : QObject(parent) {
  mHandlers = make_shared<AssistantModel::Handlers>(this);

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  mAccountCreator = core->createAccountCreator(
    core->getConfig()->getString("assistant", "xmlrpc_url", DefaultXmlrpcUri)
  );
  mAccountCreator->addListener(mHandlers);
}

// -----------------------------------------------------------------------------

void AssistantModel::activate () {
  if (mAccountCreator->getEmail().empty())
    mAccountCreator->activateAccount();
  else
    mAccountCreator->isAccountActivated();
}

void AssistantModel::create () {
  mAccountCreator->createAccount();
}

void AssistantModel::login () {
  if (!mCountryCode.isEmpty()) {
    mAccountCreator->recoverAccount();
    return;
  }

  shared_ptr<linphone::Config> config(CoreManager::getInstance()->getCore()->getConfig());
  if (!config->getString("assistant", "xmlrpc_url", "").empty()) {
    mAccountCreator->isAccountExist();
    return;
  }

  // No verification if no xmlrpc url. Use addOtherSipAccount directly.
  QVariantMap map;
  map["sipDomain"] = Utils::coreStringToAppString(config->getString("assistant", "domain", ""));
  map["username"] = getUsername();
  map["password"] = getPassword();
  emit loginStatusChanged(addOtherSipAccount(map) ? QString("") : tr("unableToAddAccount"));
}

void AssistantModel::reset () {
  mCountryCode = QString("");
  mAccountCreator->reset();

  emit emailChanged(QString(""), QString(""));
  emit passwordChanged(QString(""), QString(""));
  emit phoneNumberChanged(QString(""), QString(""));
  emit usernameChanged(QString(""), QString(""));
}

// -----------------------------------------------------------------------------

bool AssistantModel::addOtherSipAccount (const QVariantMap &map) {
  CoreManager *coreManager = CoreManager::getInstance();

  shared_ptr<linphone::Factory> factory = linphone::Factory::get();
  shared_ptr<linphone::Core> core = coreManager->getCore();
  shared_ptr<linphone::ProxyConfig> proxyConfig = core->createProxyConfig();

  const QString domain = map["sipDomain"].toString();

  QString sipAddress = QStringLiteral("sip:%1@%2")
    .arg(map["username"].toString()).arg(domain);

  // Server address.
  {
    shared_ptr<linphone::Address> address = factory->createAddress(
      Utils::appStringToCoreString(QStringLiteral("sip:%1").arg(domain))
    );

    const QString &transport(map["transport"].toString());
    if (!transport.isEmpty())
      address->setTransport(LinphoneUtils::stringToTransportType(transport));

    if (proxyConfig->setServerAddr(address->asString())) {
      qWarning() << QStringLiteral("Unable to add server address: `%1`.")
        .arg(QString::fromStdString(address->asString()));
      return false;
    }
  }

  // Sip Address.
  shared_ptr<linphone::Address> address = factory->createAddress(sipAddress.toStdString());
  if (!address) {
    qWarning() << QStringLiteral("Unable to create sip address object from: `%1`.").arg(sipAddress);
    return false;
  }

  address->setDisplayName(map["displayName"].toString().toStdString());
  proxyConfig->setIdentityAddress(address);

  // AuthInfo.
  core->addAuthInfo(
    factory->createAuthInfo(
      address->getUsername(), // Username.
      "", // User ID.
      Utils::appStringToCoreString(map["password"].toString()), // Password.
      "", // HA1.
      "", // Realm.
      address->getDomain() // Domain.
    )
  );

  AccountSettingsModel *accountSettingsModel = coreManager->getAccountSettingsModel();
  if (accountSettingsModel->addOrUpdateProxyConfig(proxyConfig)) {
    accountSettingsModel->setDefaultProxyConfig(proxyConfig);
    return true;
  }
  return false;
}

// -----------------------------------------------------------------------------

QString AssistantModel::getEmail () const {
  return Utils::coreStringToAppString(mAccountCreator->getEmail());
}

void AssistantModel::setEmail (const QString &email) {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (mAccountCreator->setEmail(Utils::appStringToCoreString(email))) {
    case linphone::AccountCreator::EmailStatus::Ok:
      break;
    case linphone::AccountCreator::EmailStatus::Malformed:
      error = tr("emailStatusMalformed");
      break;
    case linphone::AccountCreator::EmailStatus::InvalidCharacters:
      error = tr("emailStatusMalformedInvalidCharacters");
      break;
  }

  emit emailChanged(email, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getPassword () const {
  return Utils::coreStringToAppString(mAccountCreator->getPassword());
}

void AssistantModel::setPassword (const QString &password) {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (mAccountCreator->setPassword(Utils::appStringToCoreString(password))) {
    case linphone::AccountCreator::PasswordStatus::Ok:
      break;
    case linphone::AccountCreator::PasswordStatus::TooShort:
      error = tr("passwordStatusTooShort").arg(config->getInt("assistant", "password_min_length", 1));
      break;
    case linphone::AccountCreator::PasswordStatus::TooLong:
      error = tr("passwordStatusTooLong").arg(config->getInt("assistant", "password_max_length", -1));
      break;
    case linphone::AccountCreator::PasswordStatus::InvalidCharacters:
      error = tr("passwordStatusInvalidCharacters")
        .arg(Utils::coreStringToAppString(config->getString("assistant", "password_regex", "")));
      break;
    case linphone::AccountCreator::PasswordStatus::MissingCharacters:
      error = tr("passwordStatusMissingCharacters")
        .arg(Utils::coreStringToAppString(config->getString("assistant", "missing_characters", "")));
      break;
  }

  emit passwordChanged(password, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getCountryCode () const {
  return mCountryCode;
}

void AssistantModel::setCountryCode (const QString &countryCode) {
  mCountryCode = countryCode;
  emit countryCodeChanged(countryCode);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getPhoneNumber () const {
  return Utils::coreStringToAppString(mAccountCreator->getPhoneNumber());
}

void AssistantModel::setPhoneNumber (const QString &phoneNumber) {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (static_cast<linphone::AccountCreator::PhoneNumberStatus>(
    mAccountCreator->setPhoneNumber(Utils::appStringToCoreString(phoneNumber), Utils::appStringToCoreString(mCountryCode))
  )) {
    case linphone::AccountCreator::PhoneNumberStatus::Ok:
      break;
    case linphone::AccountCreator::PhoneNumberStatus::Invalid:
      error = tr("phoneNumberStatusInvalid");
      break;
    case linphone::AccountCreator::PhoneNumberStatus::TooShort:
      error = tr("phoneNumberStatusTooShort");
      break;
    case linphone::AccountCreator::PhoneNumberStatus::TooLong:
      error = tr("phoneNumberStatusTooLong");
      break;
    case linphone::AccountCreator::PhoneNumberStatus::InvalidCountryCode:
      error = tr("phoneNumberStatusInvalidCountryCode");
      break;
    default:
      break;
  }

  emit phoneNumberChanged(phoneNumber, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getUsername () const {
  return QString::fromStdString(mAccountCreator->getUsername());
}

void AssistantModel::setUsername (const QString &username) {
  emit usernameChanged(
    username,
    mapAccountCreatorUsernameStatusToString(
      mAccountCreator->setUsername(Utils::appStringToCoreString(username))
    )
  );
}

// -----------------------------------------------------------------------------

QString AssistantModel::getDisplayName () const {
  return QString::fromStdString(mAccountCreator->getDisplayName());
}

void AssistantModel::setDisplayName (const QString &displayName) {
  emit displayNameChanged(
    displayName,
    mapAccountCreatorUsernameStatusToString(
      mAccountCreator->setDisplayName(displayName.toStdString())
    )
  );
}

// -----------------------------------------------------------------------------

QString AssistantModel::getActivationCode () const {
  return Utils::coreStringToAppString(mAccountCreator->getActivationCode());
}

void AssistantModel::setActivationCode (const QString &activationCode) {
  mAccountCreator->setActivationCode(Utils::appStringToCoreString(activationCode));
  emit activationCodeChanged(activationCode);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getConfigFilename () const {
  return mConfigFilename;
}

void AssistantModel::setConfigFilename (const QString &configFilename) {
  mConfigFilename = configFilename;

  QString configPath = Utils::coreStringToAppString(Paths::getAssistantConfigDirPath()) + configFilename;
  qInfo() << QStringLiteral("Set config on assistant: `%1`.").arg(configPath);

  CoreManager::getInstance()->getCore()->getConfig()->loadFromXmlFile(
    Utils::appStringToCoreString(configPath)
  );

  emit configFilenameChanged(configFilename);
}

// -----------------------------------------------------------------------------

QString AssistantModel::mapAccountCreatorUsernameStatusToString (linphone::AccountCreator::UsernameStatus status) const {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (status) {
    case linphone::AccountCreator::UsernameStatus::Ok:
      break;
    case linphone::AccountCreator::UsernameStatus::TooShort:
      error = tr("usernameStatusTooShort").arg(config->getInt("assistant", "username_min_length", 1));
      break;
    case linphone::AccountCreator::UsernameStatus::TooLong:
      error = tr("usernameStatusTooLong").arg(config->getInt("assistant", "username_max_length", -1));
      break;
    case linphone::AccountCreator::UsernameStatus::InvalidCharacters:
      error = tr("usernameStatusInvalidCharacters")
        .arg(Utils::coreStringToAppString(config->getString("assistant", "username_regex", "")));
      break;
    case linphone::AccountCreator::UsernameStatus::Invalid:
      error = tr("usernameStatusInvalid");
      break;
  }

  return error;
}
