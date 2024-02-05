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

DEFINE_ABSTRACT_OBJECT(LoginPage)

LoginPage::LoginPage(QObject *parent) : QObject(parent) {
	mustBeInMainThread(getClassName());
}

LoginPage::~LoginPage() {
	mustBeInMainThread("~" + getClassName());
}

linphone::RegistrationState LoginPage::getRegistrationState() const {
	// View thread
	return mRegistrationState;
}

void LoginPage::setRegistrationState(linphone::RegistrationState status) {
	// Should be view thread only because of object updates.
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mRegistrationState != status) {
		mRegistrationState = status;
		emit registrationStateChanged();
	}
}

QString LoginPage::getErrorMessage() const {
	return mErrorMessage;
}

void LoginPage::setErrorMessage(const QString &error) {
	// force signal emission to display the error even if it doesn't change
	mErrorMessage = error;
	emit errorMessageChanged();
}

void LoginPage::login(const QString &username, const QString &password) {
	App::postModelAsync([=]() {
		QString *error = new QString(tr("Le couple identifiant mot de passe ne correspond pas"));
		// Create on Model thread.
		AccountManager *accountManager = new AccountManager();
		connect(accountManager, &AccountManager::registrationStateChanged, this,
		        [accountManager, this, error](linphone::RegistrationState state) mutable {
			        // View thread
			        setRegistrationState(state);
			        switch (state) {
				        case linphone::RegistrationState::Failed: {
					        emit accountManager->errorMessageChanged(*error);
					        accountManager->deleteLater();
					        break;
				        }
				        case linphone::RegistrationState::Ok: {
					        emit accountManager->errorMessageChanged("");
					        break;
				        }
				        case linphone::RegistrationState::Cleared:
				        case linphone::RegistrationState::None:
				        case linphone::RegistrationState::Progress:
				        case linphone::RegistrationState::Refreshing:
					        break;
			        }
		        });
		connect(accountManager, &AccountManager::errorMessageChanged, this,
		        [this](QString errorMessage) { setErrorMessage(errorMessage); });

		connect(accountManager, &AccountManager::destroyed, [error]() { delete error; });

		if (!accountManager->login(username, password, error)) {
			emit accountManager->registrationStateChanged(linphone::RegistrationState::Failed);
		}
	});
}
