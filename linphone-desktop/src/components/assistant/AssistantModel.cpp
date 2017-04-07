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

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "AssistantModel.hpp"

#define DEFAULT_XMLRPC_URL "https://subscribe.linphone.org:444/wizard.php"

using namespace std;

// =============================================================================

class AssistantModel::Handlers : public linphone::AccountCreatorListener {
public:
  Handlers (AssistantModel *assistant) {
    m_assistant = assistant;
  }

  void onCreateAccount (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onIsAccountExist (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &
  ) override {
    if (status == linphone::AccountCreatorStatusAccountExist || status == linphone::AccountCreatorStatusAccountExistWithAlias) {
      CoreManager::getInstance()->getCore()->addProxyConfig(creator->configure());
      emit m_assistant->loginStatusChanged("");
    } else {
      if (status == linphone::AccountCreatorStatusRequestFailed)
        emit m_assistant->loginStatusChanged(tr("requestFailed"));
      else
        emit m_assistant->loginStatusChanged(tr("loginWithUsernameFailed"));
    }
  }

  void onActivateAccount (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onIsAccountActivated (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onLinkAccount (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onActivateAlias (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onIsAliasUsed (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onIsAccountLinked (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onRecoverAccount (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

  void onUpdateAccount (
    const shared_ptr<linphone::AccountCreator> &creator,
    linphone::AccountCreatorStatus status,
    const string &resp
  ) override {}

private:
  AssistantModel *m_assistant;
};

// -----------------------------------------------------------------------------

AssistantModel::AssistantModel (QObject *parent) : QObject(parent) {
  m_handlers = make_shared<AssistantModel::Handlers>(this);

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  m_account_creator = core->createAccountCreator(
      core->getConfig()->getString("assistant", "xmlrpc_url", DEFAULT_XMLRPC_URL)
    );
  m_account_creator->setListener(m_handlers);
}

// -----------------------------------------------------------------------------

void AssistantModel::setUsername (const QString &username) {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (m_account_creator->setUsername(::Utils::qStringToLinphoneString(username))) {
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

  emit usernameChanged(username, error);
}

void AssistantModel::setPassword (const QString &password) {
  shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
  QString error;

  switch (m_account_creator->setPassword(::Utils::qStringToLinphoneString(password))) {
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

void AssistantModel::login () {
  m_account_creator->isAccountExist();
}
