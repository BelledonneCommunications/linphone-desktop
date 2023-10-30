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

#ifndef ACCOUNT_H_
#define ACCOUNT_H_

#include "model/account/AccountModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class Account : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString contactAddress READ getContactAddress CONSTANT)
	Q_PROPERTY(QString identityAddress READ getIdentityAddress CONSTANT)
	Q_PROPERTY(QString pictureUri READ getPictureUri WRITE setPictureUri NOTIFY pictureUriChanged)
	Q_PROPERTY(
	    LinphoneEnums::RegistrationState registrationState READ getRegistrationState NOTIFY registrationStateChanged)

public:
	// Should be call from model Thread. Will be automatically in App thread after initialization
	Account(const std::shared_ptr<linphone::Account> &account);
	~Account();

	QString getContactAddress() const;
	QString getIdentityAddress() const;
	QString getPictureUri() const;
	LinphoneEnums::RegistrationState getRegistrationState() const;

	void setPictureUri(const QString &uri);

	void onPictureUriChanged(std::string uri);
	void onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
	                                linphone::RegistrationState state,
	                                const std::string &message);

signals:
	void pictureUriChanged();
	void registrationStateChanged(const QString &message);

	// Account requests
	void requestSetPictureUri(std::string pictureUri);

private:
	QString mContactAddress;
	QString mIdentityAddress;
	QString mPictureUri;
	LinphoneEnums::RegistrationState mRegistrationState;
	std::shared_ptr<AccountModel> mAccountModel;

	DECLARE_ABSTRACT_OBJECT
};

#endif
