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

#include "AccountCore.hpp"
#include "core/App.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(AccountCore)

QSharedPointer<AccountCore> AccountCore::create(const std::shared_ptr<linphone::Account> &account) {
	auto model = QSharedPointer<AccountCore>(new AccountCore(account), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

AccountCore::AccountCore(const std::shared_ptr<linphone::Account> &account) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	// Init data
	auto address = account->getContactAddress();
	mContactAddress = address ? Utils::coreStringToAppString(account->getContactAddress()->asStringUriOnly()) : "";
	auto params = account->getParams();
	auto identityAddress = params->getIdentityAddress();
	mIdentityAddress = identityAddress ? Utils::coreStringToAppString(identityAddress->asStringUriOnly()) : "";
	mPictureUri = Utils::coreStringToAppString(params->getPictureUri());
	mRegistrationState = LinphoneEnums::fromLinphone(account->getState());
	mIsDefaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount() == account;
	// mUnreadNotifications = account->getUnreadChatMessageCount() + account->getMissedCallsCount();	// TODO
	mUnreadNotifications = account->getMissedCallsCount();

	// Add listener
	mAccountModel = Utils::makeQObject_ptr<AccountModel>(account); // OK
	mAccountModel->setSelf(mAccountModel);
}

AccountCore::~AccountCore() {
	mustBeInMainThread("~" + getClassName());
	emit mAccountModel->removeListener();
}

void AccountCore::setSelf(QSharedPointer<AccountCore> me) {
	mAccountModelConnection = QSharedPointer<SafeConnection<AccountCore, AccountModel>>(
	    new SafeConnection<AccountCore, AccountModel>(me, mAccountModel));
	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::registrationStateChanged, [this](const std::shared_ptr<linphone::Account> &account,
	                                                    linphone::RegistrationState state, const std::string &message) {
		    mAccountModelConnection->invokeToCore(
		        [this, account, state, message]() { this->onRegistrationStateChanged(account, state, message); });
	    });
	// From Model
	mAccountModelConnection->makeConnectToModel(&AccountModel::defaultAccountChanged, [this](bool isDefault) {
		mAccountModelConnection->invokeToCore([this, isDefault]() { this->onDefaultAccountChanged(isDefault); });
	});

	mAccountModelConnection->makeConnectToModel(&AccountModel::pictureUriChanged, [this](QString uri) {
		mAccountModelConnection->invokeToCore([this, uri]() { this->onPictureUriChanged(uri); });
	});
	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::unreadNotificationsChanged, [this](int unreadMessagesCount, int unreadCallsCount) {
		    mAccountModelConnection->invokeToCore([this, unreadMessagesCount, unreadCallsCount]() {
			    this->setUnreadNotifications(unreadMessagesCount + unreadCallsCount);
		    });
	    });

	// From GUI
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetPictureUri, [this](QString uri) {
		mAccountModelConnection->invokeToModel([this, uri]() { mAccountModel->setPictureUri(uri); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetDefaultAccount, [this]() {
		mAccountModelConnection->invokeToModel([this]() { mAccountModel->setDefault(); });
	});
}

QString AccountCore::getContactAddress() const {
	return mContactAddress;
}

QString AccountCore::getIdentityAddress() const {
	return mIdentityAddress;
}

QString AccountCore::getPictureUri() const {
	return mPictureUri;
}

LinphoneEnums::RegistrationState AccountCore::getRegistrationState() const {
	return mRegistrationState;
}

bool AccountCore::getIsDefaultAccount() const {
	return mIsDefaultAccount;
}

int AccountCore::getUnreadNotifications() const {
	return mUnreadNotifications;
}
void AccountCore::setUnreadNotifications(int unread) {
	if (mUnreadNotifications != unread) {
		mUnreadNotifications = unread;
		emit unreadNotificationsChanged(unread);
	}
}

void AccountCore::onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
                                             linphone::RegistrationState state,
                                             const std::string &message) {
	mRegistrationState = LinphoneEnums::fromLinphone(state);
	emit registrationStateChanged(Utils::coreStringToAppString(message));
}

void AccountCore::onDefaultAccountChanged(bool isDefault) {
	if (mIsDefaultAccount != isDefault) {
		mIsDefaultAccount = isDefault;
		emit defaultAccountChanged(mIsDefaultAccount);
	}
}

void AccountCore::onPictureUriChanged(QString uri) {
	mPictureUri = uri;
	emit pictureUriChanged();
}

void AccountCore::removeAccount() {
	mAccountModelConnection->invokeToModel([this]() { mAccountModel->removeAccount(); });
}
