/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "AccountManager.hpp"

#include <QDebug>
#include <QTemporaryFile>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(AccountManager)

AccountManager::AccountManager(QObject *parent) : QObject(parent) {
	mustBeInLinphoneThread(getClassName());
}

AccountManager::~AccountManager() {
	mustBeInLinphoneThread("~" + getClassName());
}

std::shared_ptr<linphone::Account> AccountManager::createAccount(const QString &assistantFile) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	QString assistantPath = "://data/assistant/" + assistantFile;
	qInfo() << log().arg(QStringLiteral("Set config on assistant: `%1`.")).arg(assistantPath);
	QFile resource(assistantPath);
	auto file = QTemporaryFile::createNativeFile(resource);
	core->getConfig()->loadFromXmlFile(Utils::appStringToCoreString(file->fileName()));
	return core->createAccount(core->createAccountParams());
}

bool AccountManager::login(QString username, QString password) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	auto factory = linphone::Factory::get();
	auto account = createAccount("use-app-sip-account.rc");
	auto params = account->getParams()->clone();
	// Sip address.
	auto identity = params->getIdentityAddress()->clone();
	if (mAccountModel) return false;

	identity->setUsername(Utils::appStringToCoreString(username));
	if (params->setIdentityAddress(identity)) {
		qWarning() << log()
		                  .arg(QStringLiteral("Unable to set identity address: `%1`."))
		                  .arg(Utils::coreStringToAppString(identity->asStringUriOnly()));
		return false;
	}

	account->setParams(params);
	core->addAuthInfo(factory->createAuthInfo(Utils::appStringToCoreString(username), // Username.
	                                          "",                                     // User ID.
	                                          Utils::appStringToCoreString(password), // Password.
	                                          "",                                     // HA1.
	                                          "",                                     // Realm.
	                                          identity->getDomain()                   // Domain.
	                                          ));
	mAccountModel = Utils::makeQObject_ptr<AccountModel>(account);
	mAccountModel->setSelf(mAccountModel);
	connect(mAccountModel.get(), &AccountModel::registrationStateChanged, this,
	        &AccountManager::onRegistrationStateChanged);
	core->addAccount(account);
	return true;
}

void AccountManager::onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
                                                linphone::RegistrationState state,
                                                const std::string &message) {
	auto core = CoreModel::getInstance()->getCore();
	switch (state) {
		case linphone::RegistrationState::Failed:
			core->removeAccount(account);
			emit mAccountModel->removeListener();
			mAccountModel = nullptr;
			break;
		case linphone::RegistrationState::Ok:
			core->setDefaultAccount(account);
			emit mAccountModel->removeListener();
			mAccountModel = nullptr;
			break;
		default: {
		}
	}
	emit registrationStateChanged(state);
}
