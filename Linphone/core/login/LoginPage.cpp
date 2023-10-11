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

#include "LoginPage.hpp"
#include <QTimer>

#include "core/App.hpp"

#include "model/account/AccountManager.hpp"

LoginPage::LoginPage(QObject *parent) : QObject(parent) {
}

bool LoginPage::isLogged() const {
	// View thread
	return mIsLogged;
}

void LoginPage::setIsLogged(bool status) {
	// Should be view thread only because of object updates.
	if (mIsLogged != status) {
		mIsLogged = status;
		emit isLoggedChanged();
	}
}

void LoginPage::login(const QString &username, const QString &password) {
	App::postModelAsync([=]() {
		// Create on Model thread.
		AccountManager *accountManager = new AccountManager();
		connect(accountManager, &AccountManager::logged, this, [accountManager, this](bool isLoggued) mutable {
			// View thread
			setIsLogged(isLoggued);
			accountManager->deleteLater();
		});
		accountManager->login(username, password);
	});
}
