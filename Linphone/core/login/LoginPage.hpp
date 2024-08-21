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

#ifndef LOGINPAGE_H_
#define LOGINPAGE_H_

#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"
#include <QObject>
#include <linphone++/linphone.hh>

class LoginPage : public QObject, public AbstractObject {
	Q_OBJECT

public:
	LoginPage(QObject *parent = nullptr);
	~LoginPage();

	Q_PROPERTY(linphone::RegistrationState registrationState READ getRegistrationState NOTIFY registrationStateChanged)
	Q_PROPERTY(QString errorMessage READ getErrorMessage NOTIFY errorMessageChanged)

	Q_INVOKABLE void login(const QString &username,
	                       const QString &password,
	                       QString displayName = QString(),
	                       QString domain = QString(),
	                       LinphoneEnums::TransportType transportType = LinphoneEnums::TransportType::Tls);

	linphone::RegistrationState getRegistrationState() const;
	void setRegistrationState(linphone::RegistrationState status);

	QString getErrorMessage() const;
	void setErrorMessage(const QString &error);

signals:
	void registrationStateChanged();
	void errorMessageChanged(QString error);

private:
	linphone::RegistrationState mRegistrationState = linphone::RegistrationState::None;
	QString mErrorMessage;

	DECLARE_ABSTRACT_OBJECT
};

#endif
