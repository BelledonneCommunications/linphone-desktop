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

#ifndef ACCOUNT_MANAGER_SERVICES_REQUEST_MODEL_H_
#define ACCOUNT_MANAGER_SERVICES_REQUEST_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"

#include <QObject>
#include <linphone++/linphone.hh>

class AccountManagerServicesRequestModel
    : public ::Listener<linphone::AccountManagerServicesRequest, linphone::AccountManagerServicesRequestListener>,
      public linphone::AccountManagerServicesRequestListener,
      public AbstractObject {
	Q_OBJECT
public:
	AccountManagerServicesRequestModel(
	    const std::shared_ptr<linphone::AccountManagerServicesRequest> &accountManagerServicesRequest,
	    QObject *parent = nullptr);
	~AccountManagerServicesRequestModel();

	void submit();
	linphone::AccountManagerServicesRequest::Type getType() const;

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

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onRequestSuccessful(const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
	                                 const std::string &data) override;
	virtual void onRequestError(const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
	                            int statusCode,
	                            const std::string &errorMessage,
	                            const std::shared_ptr<const linphone::Dictionary> &parameterErrors) override;
	virtual void onDevicesListFetched(const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
	                                  const std::list<std::shared_ptr<linphone::AccountDevice>> &devicesList) override;
};

#endif
