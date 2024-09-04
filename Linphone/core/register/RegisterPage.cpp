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

#include "RegisterPage.hpp"
#include <QTimer>

#include "core/App.hpp"

#include "model/account/AccountManager.hpp"

DEFINE_ABSTRACT_OBJECT(RegisterPage)

RegisterPage::RegisterPage(QObject *parent) : QObject(parent) {
	mustBeInMainThread(getClassName());
}

RegisterPage::~RegisterPage() {
	mustBeInMainThread("~" + getClassName());
}

void RegisterPage::registerNewAccount(const QString &username,
                                      const QString &password,
                                      const QString &email,
                                      const QString &phoneNumber) {
	App::postModelAsync([=]() {
		// Create on Model thread.
		// registrationFailed(error); });
		AccountManager::RegisterType registerType;
		QString address;
		if (email.isEmpty()) {
			registerType = AccountManager::RegisterType::PhoneNumber;
			address = phoneNumber;
		} else {
			registerType = AccountManager::RegisterType::Email;
			address = email;
		}
		auto accountManager = new AccountManager();
		connect(accountManager, &AccountManager::newAccountCreationSucceed, this,
		        [this, registerType, address, accountManager](const QString &sipAddress) mutable {
			        App::postCoreAsync([this, registerType, address, sipAddress, accountManager]() {
				        emit newAccountCreationSucceed(registerType == AccountManager::RegisterType::Email, address,
				                                       sipAddress);
			        });
			        if (accountManager) {
				        accountManager->deleteLater();
				        accountManager = nullptr;
			        }
		        });
		connect(accountManager, &AccountManager::registerNewAccountFailed, this,
		        [this, accountManager](const QString &errorMessage) mutable {
			        App::postCoreAsync([this, errorMessage]() {
				        mLastRegisterAddress.clear();
				        mLastConvertedToken.clear();
				        emit registerNewAccountFailed(errorMessage);
			        });
			        if (accountManager) {
				        accountManager->deleteLater();
				        accountManager = nullptr;
			        }
		        });
		connect(accountManager, &AccountManager::errorInField, this,
		        [this, accountManager](const QString &field, const QString &errorMessage) mutable {
			        App::postCoreAsync([this, field, errorMessage]() { emit errorInField(field, errorMessage); });
			        if (accountManager) {
				        accountManager->deleteLater();
				        accountManager = nullptr;
			        }
		        });
		connect(accountManager, &AccountManager::tokenConversionSucceed, this,
		        [this, accountManager, address](QString convertedToken) {
			        App::postCoreAsync([this, convertedToken, address]() {
				        mLastRegisterAddress = address;
				        mLastConvertedToken = convertedToken;
				        emit tokenConversionSucceed();
			        });
		        });
		accountManager->registerNewAccount(username, password, registerType, address,
		                                   QString::compare(mLastRegisterAddress, address) ? QString()
		                                                                                   : mLastConvertedToken);
	});
}

void RegisterPage::linkNewAccountUsingCode(const QString &code,
                                           bool registerWithEmail,
                                           const QString &sipIdentityAddress) {
	App::postModelAsync([=]() {
		auto accountManager = new AccountManager();
		connect(accountManager, &AccountManager::linkingNewAccountWithCodeSucceed, this, [this, accountManager]() {
			App::postCoreAsync([this]() {
				mLastRegisterAddress.clear();
				mLastConvertedToken.clear();
				emit linkingNewAccountWithCodeSucceed();
			});
			accountManager->deleteLater();
		});
		connect(accountManager, &AccountManager::linkingNewAccountWithCodeFailed, this,
		        [this, accountManager](const QString &errorMessage) {
			        App::postCoreAsync([this, errorMessage]() { emit linkingNewAccountWithCodeFailed(errorMessage); });
			        accountManager->deleteLater();
		        });
		accountManager->linkNewAccountUsingCode(
		    code, registerWithEmail ? AccountManager::RegisterType::Email : AccountManager::RegisterType::PhoneNumber,
		    sipIdentityAddress);
	});
}