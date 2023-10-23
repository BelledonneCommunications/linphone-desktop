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

#include "Account.hpp"
#include "tool/Utils.hpp"

Account::Account(const std::shared_ptr<linphone::Account> &account) : QObject(nullptr) {
	// Should be call from model Thread
	auto address = account->getContactAddress();
	mContactAddress = address ? Utils::coreStringToAppString(account->getContactAddress()->asString()) : "";
	auto params = account->getParams();
	auto identityAddress = params->getIdentityAddress();
	mIdentityAddress = identityAddress ? Utils::coreStringToAppString(identityAddress->asString()) : "";
	mPictureUri = Utils::coreStringToAppString(params->getPictureUri());
	mRegistrationState = LinphoneEnums::fromLinphone(account->getState());

	mAccountModel = Utils::makeQObject_ptr<AccountModel>(account); // OK
	connect(mAccountModel.get(), &AccountModel::registrationStateChanged, this, &Account::onRegistrationStateChanged);
	connect(this, &Account::requestSetPictureUri, mAccountModel.get(), &AccountModel::setPictureUri,
	        Qt::QueuedConnection);
	connect(mAccountModel.get(), &AccountModel::pictureUriChanged, this, &Account::onPictureUriChanged,
	        Qt::QueuedConnection);
}

Account::~Account() {
	emit mAccountModel->removeListener();
}

QString Account::getContactAddress() const {
	return mContactAddress;
}

QString Account::getIdentityAddress() const {
	return mIdentityAddress;
}

QString Account::getPictureUri() const {
	return mPictureUri;
}

LinphoneEnums::RegistrationState Account::getRegistrationState() const {
	return mRegistrationState;
}

void Account::onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
                                         linphone::RegistrationState state,
                                         const std::string &message) {
	mRegistrationState = LinphoneEnums::fromLinphone(state);
	emit registrationStateChanged(Utils::coreStringToAppString(message));
}

void Account::setPictureUri(const QString &uri) {
	if (uri != mPictureUri) {
		emit requestSetPictureUri(Utils::appStringToCoreString(uri));
	}
}

void Account::onPictureUriChanged(std::string uri) {
	mPictureUri = Utils::coreStringToAppString(uri);
	emit pictureUriChanged();
}
