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
#include <linphone++/linphone.hh>

#include "AccountListener.hpp"

class AccountManager: public QObject {
Q_OBJECT
public:
	AccountManager(QObject *parent = nullptr);
	
	bool login(QString username, QString password);
	
	std::shared_ptr<linphone::Account> createAccount(const QString& assistantFile);
	
	void onRegistrationStateChanged(const std::shared_ptr<linphone::Account> & account, linphone::RegistrationState state, const std::string & message);
signals:
	void logged(bool isLoggued);
private:
	std::shared_ptr<AccountListener> mAccountListener;
};

#endif
