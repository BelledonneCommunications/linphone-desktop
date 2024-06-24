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

#include "AccountManagerServicesRequestModel.hpp"

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include <QDebug>
#include <QUrl>

DEFINE_ABSTRACT_OBJECT(AccountManagerServicesRequestModel)

AccountManagerServicesRequestModel::AccountManagerServicesRequestModel(
    const std::shared_ptr<linphone::AccountManagerServicesRequest> &accountManagerServicesRequest, QObject *parent)
    : ::Listener<linphone::AccountManagerServicesRequest, linphone::AccountManagerServicesRequestListener>(
          accountManagerServicesRequest, parent) {
	mustBeInLinphoneThread(getClassName());
}

AccountManagerServicesRequestModel::~AccountManagerServicesRequestModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void AccountManagerServicesRequestModel::submit() {
	mMonitor->submit();
}

linphone::AccountManagerServicesRequest::Type AccountManagerServicesRequestModel::getType() const {
	return mMonitor->getType();
}

//--------------------------------------------------------------------------------
// LINPHONE
//--------------------------------------------------------------------------------

void AccountManagerServicesRequestModel::onRequestSuccessful(
    const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request, const std::string &data) {
	emit requestSuccessfull(request, data);
}

void AccountManagerServicesRequestModel::onRequestError(
    const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
    int statusCode,
    const std::string &errorMessage,
    const std::shared_ptr<const linphone::Dictionary> &parameterErrors) {
	emit requestError(request, statusCode, errorMessage, parameterErrors);
}

void AccountManagerServicesRequestModel::onDevicesListFetched(
    const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
    const std::list<std::shared_ptr<linphone::AccountDevice>> &devicesList) {
	emit devicesListFetched(request, devicesList);
}
