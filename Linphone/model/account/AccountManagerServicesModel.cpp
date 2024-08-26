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

#include "AccountManagerServicesModel.hpp"

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include <QDebug>
#include <QUrl>

DEFINE_ABSTRACT_OBJECT(AccountManagerServicesModel)

AccountManagerServicesModel::AccountManagerServicesModel(
    const std::shared_ptr<linphone::AccountManagerServices> &accountManagerServices, QObject *parent)
    : mAccountManagerServices(accountManagerServices) {
	mustBeInLinphoneThread(getClassName());
}

AccountManagerServicesModel::~AccountManagerServicesModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void AccountManagerServicesModel::setRequestAndSubmit(
    const std::shared_ptr<linphone::AccountManagerServicesRequest> &request) {
	if (mRequest) {
		disconnect(mRequest.get(), &AccountManagerServicesRequestModel::requestSuccessfull, this, nullptr);
		disconnect(mRequest.get(), &AccountManagerServicesRequestModel::requestError, this, nullptr);
		disconnect(mRequest.get(), &AccountManagerServicesRequestModel::devicesListFetched, this, nullptr);
		mRequest = nullptr;
	}
	mRequest = Utils::makeQObject_ptr<AccountManagerServicesRequestModel>(request);
	mRequest->setSelf(mRequest);
	connect(mRequest.get(), &AccountManagerServicesRequestModel::requestSuccessfull, this,
	        &AccountManagerServicesModel::requestSuccessfull);
	connect(mRequest.get(), &AccountManagerServicesRequestModel::requestError, this,
	        &AccountManagerServicesModel::requestError);
	connect(mRequest.get(), &AccountManagerServicesRequestModel::devicesListFetched, this,
	        &AccountManagerServicesModel::devicesListFetched);
	mRequest->submit();
}

void AccountManagerServicesModel::requestToken() {
	auto req = mAccountManagerServices->createGetAccountCreationRequestTokenRequest();
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::convertCreationRequestTokenIntoCreationToken(const std::string &token) {
	auto req = mAccountManagerServices->createGetAccountCreationTokenFromRequestTokenRequest(token);
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::createAccountUsingToken(const std::string &username,
                                                          const std::string &password,
                                                          const std::string &token,
                                                          const std::string &algorithm) {
	auto req = mAccountManagerServices->createNewAccountUsingTokenRequest(username, password, algorithm, token);
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::linkPhoneNumberBySms(const std::shared_ptr<linphone::Address> &sipIdentityAddress,
                                                       const std::string &phoneNumber) {
	auto req = mAccountManagerServices->createSendPhoneNumberLinkingCodeBySmsRequest(sipIdentityAddress, phoneNumber);
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::linkEmailByEmail(const std::shared_ptr<linphone::Address> &sipIdentityAddress,
                                                   const std::string &emailAddress) {
	auto req = mAccountManagerServices->createSendEmailLinkingCodeByEmailRequest(sipIdentityAddress, emailAddress);
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::linkPhoneNumberToAccountUsingCode(
    const std::shared_ptr<linphone::Address> &sipIdentityAddress, const std::string &code) {
	auto req = mAccountManagerServices->createLinkPhoneNumberToAccountUsingCodeRequest(sipIdentityAddress, code);
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::linkEmailToAccountUsingCode(
    const std::shared_ptr<linphone::Address> &sipIdentityAddress, const std::string &code) {
	auto req = mAccountManagerServices->createLinkEmailToAccountUsingCodeRequest(sipIdentityAddress, code);
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::getDeviceList(const std::shared_ptr<const linphone::Address> &sipIdentityAddress) {
	auto req = mAccountManagerServices->createGetDevicesListRequest(sipIdentityAddress);
	setRequestAndSubmit(req);
}

void AccountManagerServicesModel::deleteDevice(const std::shared_ptr<const linphone::Address> &sipIdentityAddress,
                                               const std::shared_ptr<linphone::AccountDevice> &device) {
	auto req = mAccountManagerServices->createDeleteDeviceRequest(sipIdentityAddress, device);
	setRequestAndSubmit(req);
}
