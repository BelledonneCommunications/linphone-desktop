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

#ifndef ACCOUNT_CORE_H_
#define ACCOUNT_CORE_H_

#include "model/account/AccountModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class AccountCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString contactAddress READ getContactAddress CONSTANT)
	Q_PROPERTY(QString identityAddress READ getIdentityAddress CONSTANT)
	Q_PROPERTY(QString pictureUri READ getPictureUri WRITE lSetPictureUri NOTIFY pictureUriChanged)
	Q_PROPERTY(
	    LinphoneEnums::RegistrationState registrationState READ getRegistrationState NOTIFY registrationStateChanged)
	Q_PROPERTY(bool isDefaultAccount READ getIsDefaultAccount NOTIFY defaultAccountChanged)
	Q_PROPERTY(int unreadNotifications READ getUnreadNotifications NOTIFY unreadNotificationsChanged)
	Q_PROPERTY(int unreadCallNotifications READ getUnreadCallNotifications NOTIFY unreadCallNotificationsChanged)
	Q_PROPERTY(
	    int unreadMessageNotifications READ getUnreadMessageNotifications NOTIFY unreadMessageNotificationsChanged)

public:
	static QSharedPointer<AccountCore> create(const std::shared_ptr<linphone::Account> &account);
	// Should be call from model Thread. Will be automatically in App thread after initialization
	AccountCore(const std::shared_ptr<linphone::Account> &account);
	~AccountCore();
	void setSelf(QSharedPointer<AccountCore> me);

	QString getContactAddress() const;
	QString getIdentityAddress() const;
	QString getPictureUri() const;
	LinphoneEnums::RegistrationState getRegistrationState() const;
	bool getIsDefaultAccount() const;
	int getUnreadNotifications() const;
	void setUnreadNotifications(int unread);
	int getUnreadCallNotifications() const;
	void setUnreadCallNotifications(int unread);
	int getUnreadMessageNotifications() const;
	void setUnreadMessageNotifications(int unread);

	void onPictureUriChanged(QString uri);
	void onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
	                                linphone::RegistrationState state,
	                                const std::string &message);

	void onDefaultAccountChanged(bool isDefault);
	Q_INVOKABLE void removeAccount();

signals:
	void pictureUriChanged();
	void registrationStateChanged(const QString &message);
	void defaultAccountChanged(bool isDefault);
	void unreadNotificationsChanged(int unread);
	void unreadCallNotificationsChanged(int unread);
	void unreadMessageNotificationsChanged(int unread);

	// Account requests
	void lSetPictureUri(QString pictureUri);
	void lSetDefaultAccount();
	void lResetMissedCalls();
	void lRefreshNotifications();

private:
	QString mContactAddress;
	QString mIdentityAddress;
	QString mPictureUri;
	bool mIsDefaultAccount = false;
	LinphoneEnums::RegistrationState mRegistrationState;
	int mUnreadNotifications = 0;
	int mUnreadCallNotifications = 0;
	int mUnreadMessageNotifications = 0;
	std::shared_ptr<AccountModel> mAccountModel;
	QSharedPointer<SafeConnection<AccountCore, AccountModel>> mAccountModelConnection;
	QSharedPointer<SafeConnection<AccountCore, CoreModel>> mCoreModelConnection;

	DECLARE_ABSTRACT_OBJECT
};

#endif
