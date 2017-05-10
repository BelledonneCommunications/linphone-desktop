/*
 * AssistantModel.cpp
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
 *  Created on: April 6, 2017
 *      Author: Ronan Abhamon
 */

#include "../../app/paths/Paths.hpp"
#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "AssistantModel.hpp"

#define DEFAULT_XMLRPC_URL "https://subscribe.linphone.org:444/wizard.php"

using namespace std;

// =============================================================================

class AssistantModel::Handlers : public linphone::AccountCreatorListener {
public:
  Handlers (AssistantModel *assistant) {
    mAssistant = assistant;
  }

private:
  void onCreateAccount (
    const shared_ptr<linphone::AccountCreator> &,
    linphone::AccountCreatorStatus status,
    const string &
  ) override {
    if (status == linphone::AccountCreatorStatusAccountCreated)
      emit mAssistant->createStatusChanged("");
    else {
      if (status == linphone::AccountCreatorStatusRequestFailed)
        emit mAssistant->createStatusChanged(tr("requestFailed"));
      else if (status == linphone::AccountCreatorStatusServerError)
        emit mAssistant->createStatusChanged(tr("cannotSendSms"));
      else
        emit mAssistant->createStatusChanged(tr("accountAlreadyExists"));
    }
  }

  void onIsAccountExist (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &
  ) override {
    if (status == linphone::AccountCreatorStatusAccountExist || status == linphone::AccountCreatorStatusAccountExistWithAlias) {
      shared_ptr<linphone::ProxyConfig> proxyConfig = creator->createProxyConfig();
      Q_ASSERT(proxyConfig != nullptr);

      emit mAssistant->loginStatusChanged("");
    } else {
      if (status == linphone::AccountCreatorStatusRequestFailed)
        emit mAssistant->loginStatusChanged(tr("requestFailed"));
      else
        emit mAssistant->loginStatusChanged(tr("loginWithUsernameFailed"));
    }
  }

  void onActivateAccount (
    const shared_ptr<linphone::AccountCreator> &,
    linphone::AccountCreatorStatus status,
    const string &
  ) override {
    if (
      status == linphone::AccountCreatorStatusAccountActivated ||
      status == linphone::AccountCreatorStatusAccountAlreadyActivated
    )
      emit mAssistant->activateStatusChanged("");
    else {
      if (status == linphone::AccountCreatorStatusRequestFailed)
        emit mAssistant->activateStatusChanged(tr("requestFailed"));
      else
        emit mAssistant->activateStatusChanged(tr("smsActivationFailed"));
    }
  }

  void onIsAccountActivated (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &
  ) override {
    if (status == linphone::AccountCreatorStatusAccountActivated) {
      shared_ptr<linphone::ProxyConfig> proxyConfig = creator->createProxyConfig();
      Q_ASSERT(proxyConfig != nullptr);

      emit mAssistant->activateStatusChanged("");
    } else {
      if (status == linphone::AccountCreatorStatusRequestFailed)
        emit mAssistant->activateStatusChanged(tr("requestFailed"));
      else
        emit mAssistant->activateStatusChanged(tr("emailActivationFailed"));
    }
  }

  // void onLinkAccount (
  // const shared_ptr<linphone::AccountCreator> &creator,
  // linphone::AccountCreatorStatus status,
  // const string &resp
  // ) override {}
  //
  // void onActivateAlias (
  // const shared_ptr<linphone::AccountCreator> &creator,
  // linphone::AccountCreatorStatus status,
  // const string &resp
  // ) override {}
  //
  // void onIsAliasUsed (
  // const shared_ptr<linphone::AccountCreator> &creator,
  // linphone::AccountCreatorStatus status,
  // const string &resp
  // ) override {}
  //
  // void onIsAccountLinked (
  // const shared_ptr<linphone::AccountCreator> &creator,
  // linphone::AccountCreatorStatus status,
  // const string &resp
  // ) override {}
  //
  // void onRecoverAccount (
  // const shared_ptr<linphone::AccountCreator> &creator,
  // linphone::AccountCreatorStatus status,
  // const string &resp
  // ) override {}
  //
  // void onUpdateAccount (
  // const shared_ptr<linphone::AccountCreator> &creator,
  // linphone::AccountCreatorStatus status,
  // const string &resp
  // ) override {}

private:
  AssistantModel *mAssistant;
};

// -----------------------------------------------------------------------------

AssistantModel::AssistantModel (QObject *parent) : QObject(parent) {
  mHandlers = make_shared<AssistantModel::Handlers>(this);

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  mAccountCreator = core->createAccountCreator(
      core->getConfig()->getString("assistant", "xmlrpc_url", DEFAULT_XMLRPC_URL)
    );
  mAccountCreator->setListener(mHandlers);
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
  mAccountCreator->isAccountExist();
}

void AssistantModel::reset () {
  mAccountCreator->reset();

  emit emailChanged("", "");
  emit passwordChanged("", "");
  emit phoneNumberChanged("", "");
  emit usernameChanged("", "");
}

// -----------------------------------------------------------------------------

QString AssistantModel::getEmail () const {
  return ::Utils::linphoneStringToQString(mAccountCreator->getEmail());
}

void AssistantModel::setEmail (const QString &email) {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (mAccountCreator->setEmail(::Utils::qStringToLinphoneString(email))) {
    case linphone::AccountCreatorEmailStatusOk:
      break;
    case linphone::AccountCreatorEmailStatusMalformed:
      error = tr("emailStatusMalformed");
      break;
    case linphone::AccountCreatorEmailStatusInvalidCharacters:
      error = tr("emailStatusMalformedInvalidCharacters");
      break;
  }

  emit emailChanged(email, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getPassword () const {
  return ::Utils::linphoneStringToQString(mAccountCreator->getPassword());
}

void AssistantModel::setPassword (const QString &password) {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (mAccountCreator->setPassword(::Utils::qStringToLinphoneString(password))) {
    case linphone::AccountCreatorPasswordStatusOk:
      break;
    case linphone::AccountCreatorPasswordStatusTooShort:
      error = tr("passwordStatusTooShort").arg(config->getInt("assistant", "password_min_length", 1));
      break;
    case linphone::AccountCreatorPasswordStatusTooLong:
      error = tr("passwordStatusTooLong").arg(config->getInt("assistant", "password_max_length", -1));
      break;
    case linphone::AccountCreatorPasswordStatusInvalidCharacters:
      error = tr("passwordStatusInvalidCharacters")
        .arg(::Utils::linphoneStringToQString(config->getString("assistant", "password_regex", "")));
      break;
    case linphone::AccountCreatorPasswordStatusMissingCharacters:
      error = tr("passwordStatusMissingCharacters")
        .arg(::Utils::linphoneStringToQString(config->getString("assistant", "missing_characters", "")));
      break;
  }

  emit passwordChanged(password, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getPhoneNumber () const {
  return ::Utils::linphoneStringToQString(mAccountCreator->getPhoneNumber());
}

void AssistantModel::setPhoneNumber (const QString &phoneNumber) {
  // shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  // TODO: use the future wrapped function: `set_phone_number`.

  emit phoneNumberChanged(phoneNumber, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getUsername () const {
  return ::Utils::linphoneStringToQString(mAccountCreator->getUsername());
}

void AssistantModel::setUsername (const QString &username) {
  emit usernameChanged(
    username,
    mapAccountCreatorUsernameStatusToString(
      mAccountCreator->setUsername(::Utils::qStringToLinphoneString(username))
    )
  );
}

// -----------------------------------------------------------------------------

QString AssistantModel::getDisplayName () const {
  return ::Utils::linphoneStringToQString(mAccountCreator->getDisplayName());
}

void AssistantModel::setDisplayName (const QString &displayName) {
  emit displayNameChanged(
    displayName,
    mapAccountCreatorUsernameStatusToString(
      mAccountCreator->setDisplayName(::Utils::qStringToLinphoneString(displayName))
    )
  );
}

// -----------------------------------------------------------------------------

QString AssistantModel::getConfigFilename () const {
  return mConfigFilename;
}

void AssistantModel::setConfigFilename (const QString &configFilename) {
  mConfigFilename = configFilename;

  QString configPath = ::Utils::linphoneStringToQString(Paths::getAssistantConfigDirPath()) + configFilename;
  qInfo() << QStringLiteral("Set config on assistant: `%1`.").arg(configPath);

  CoreManager::getInstance()->getCore()->getConfig()->loadFromXmlFile(
    ::Utils::qStringToLinphoneString(configPath)
  );

  emit configFilenameChanged(configFilename);
}

// -----------------------------------------------------------------------------

QString AssistantModel::mapAccountCreatorUsernameStatusToString (linphone::AccountCreatorUsernameStatus status) const {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (status) {
    case linphone::AccountCreatorUsernameStatusOk:
      break;
    case linphone::AccountCreatorUsernameStatusTooShort:
      error = tr("usernameStatusTooShort").arg(config->getInt("assistant", "username_min_length", 1));
      break;
    case linphone::AccountCreatorUsernameStatusTooLong:
      error = tr("usernameStatusTooLong").arg(config->getInt("assistant", "username_max_length", -1));
      break;
    case linphone::AccountCreatorUsernameStatusInvalidCharacters:
      error = tr("usernameStatusInvalidCharacters")
        .arg(::Utils::linphoneStringToQString(config->getString("assistant", "username_regex", "")));
      break;
    case linphone::AccountCreatorUsernameStatusInvalid:
      error = tr("usernameStatusInvalid");
      break;
  }

  return error;
}
