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

#ifndef REGISTERPAGE_H_
#define REGISTERPAGE_H_

#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <linphone++/linphone.hh>

class AccountManager;
class RegisterPage : public QObject, public AbstractObject {
	Q_OBJECT

public:
	RegisterPage(QObject *parent = nullptr);
	~RegisterPage();

	// Q_PROPERTY(linphone::RegistrationState registrationState READ getRegistrationState NOTIFY
	// registrationStateChanged) Q_PROPERTY(QString errorMessage READ getErrorMessage NOTIFY errorMessageChanged)

	Q_INVOKABLE void registerNewAccount(const QString &username,
	                                    const QString &password,
	                                    const QString &email,
	                                    const QString &phoneNumber);
	Q_INVOKABLE void
	linkNewAccountUsingCode(const QString &code, bool registerWithEmail, const QString &sipIdentityAddress);

signals:
	void registrationFailed(const QString &errorMessage);
	void errorMessageChanged();
	void newAccountCreationSucceed(bool withEmail, // false if creation with phone number
	                               const QString &address,
	                               const QString &sipIdentityAddress);
	void registerNewAccountFailed(const QString &error);
	void errorInField(const QString &field, const QString &error);
	void tokenConversionSucceed();
	void linkingNewAccountWithCodeSucceed();
	void linkingNewAccountWithCodeFailed(const QString &error);

private:
	linphone::RegistrationState mRegistrationState = linphone::RegistrationState::None;
	QSharedPointer<SafeConnection<RegisterPage, AccountManager>> mAccountManagerConnection;
	std::shared_ptr<AccountManager> mAccountManager;
	QString mErrorMessage;
	// Usefull to skip token verification part if the account
	// creation failed for an existing username
	QString mLastRegisterAddress;
	QString mLastConvertedToken;

	DECLARE_ABSTRACT_OBJECT
};

#endif