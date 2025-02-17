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

#ifndef ACCOUNT_MANAGER_H_
#define ACCOUNT_MANAGER_H_

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

#include "AccountManagerServicesModel.hpp"
#include "AccountManagerServicesRequestModel.hpp"
#include "AccountModel.hpp"
#include "tool/AbstractObject.hpp"

class AccountManager : public QObject, public AbstractObject {
	Q_OBJECT
public:
	AccountManager(QObject *parent = nullptr);
	~AccountManager();

	bool login(QString username,
	           QString password,
	           QString displayName = QString(),
	           QString domain = QString(),
	           linphone::TransportType transportType = linphone::TransportType::Tls,
	           QString *errorMessage = nullptr);

	std::shared_ptr<linphone::Account> createAccount(const QString &assistantFile);

	enum RegisterType { PhoneNumber = 0, Email = 1 };
	void registerNewAccount(const QString &username,
	                        const QString &password,
	                        RegisterType type,
	                        const QString &registerAddress,
	                        QString lastToken = QString());

	void linkNewAccountUsingCode(const QString &code, RegisterType registerType, const QString &sipAddress);

signals:
	void registrationStateChanged(linphone::RegistrationState state, QString message = QString());
	void newAccountCreationSucceed(QString sipAddress, RegisterType registerType, const QString &registerAddress);
	void registerNewAccountFailed(const QString &error);
	void tokenConversionSucceed(QString convertedToken);
	void errorInField(const QString &field, const QString &error);
	void linkingNewAccountWithCodeSucceed();
	void linkingNewAccountWithCodeFailed(const QString &error);

private:
	std::shared_ptr<AccountModel> mAccountModel;
	std::shared_ptr<AccountManagerServicesModel> mAccountManagerServicesModel;
	QTimer timer;
	QString mCreatedSipAddress;
	DECLARE_ABSTRACT_OBJECT
};

#endif
