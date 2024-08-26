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

#ifndef ACCOUNT_MANAGER_SERVICES_MODEL_H_
#define ACCOUNT_MANAGER_SERVICES_MODEL_H_

#include "AccountManagerServicesRequestModel.hpp"
#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"

#include <QObject>
#include <linphone++/linphone.hh>

class AccountManagerServicesModel : public QObject, public AbstractObject {
	Q_OBJECT
public:
	AccountManagerServicesModel(const std::shared_ptr<linphone::AccountManagerServices> &accountManagerServices,
	                            QObject *parent = nullptr);
	~AccountManagerServicesModel();

	void requestToken();
	void convertCreationRequestTokenIntoCreationToken(const std::string &token);
	void createAccountUsingToken(const std::string &username,
	                             const std::string &password,
	                             const std::string &token,
	                             const std::string &algorithm = "SHA-256");
	void linkPhoneNumberBySms(const std::shared_ptr<linphone::Address> &sipIdentityAddress,
	                          const std::string &phoneNumber);
	void linkEmailByEmail(const std::shared_ptr<linphone::Address> &sipIdentityAddress,
	                      const std::string &emailAddress);

	void linkPhoneNumberToAccountUsingCode(const std::shared_ptr<linphone::Address> &sipIdentityAddress,
	                                       const std::string &code);
	void linkEmailToAccountUsingCode(const std::shared_ptr<linphone::Address> &sipIdentityAddress,
	                                 const std::string &code);
	void getDeviceList(const std::shared_ptr<const linphone::Address> &sipIdentityAddress);
	void deleteDevice(const std::shared_ptr<const linphone::Address> &sipIdentityAddress,
	                  const std::shared_ptr<linphone::AccountDevice> &device);

	void setRequestAndSubmit(const std::shared_ptr<linphone::AccountManagerServicesRequest> &request);

signals:
	void requestSuccessfull(const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
	                        const std::string &data);
	void requestError(const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
	                  int statusCode,
	                  const std::string &errorMessage,
	                  const std::shared_ptr<const linphone::Dictionary> &parameterErrors);
	void devicesListFetched(const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
	                        const std::list<std::shared_ptr<linphone::AccountDevice>> &devicesList);

private:
	DECLARE_ABSTRACT_OBJECT
	std::shared_ptr<linphone::AccountManagerServices> mAccountManagerServices;
	std::shared_ptr<AccountManagerServicesRequestModel> mRequest;
};

#endif
