/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#include "AccountDeviceList.hpp"
#include "core/App.hpp"
#include "core/account/AccountDeviceGui.hpp"
#include "tool/Utils.hpp"

#include <QQmlApplicationEngine>
#include <algorithm>

DEFINE_ABSTRACT_OBJECT(AccountDeviceList)

QSharedPointer<AccountDeviceList> AccountDeviceList::create() {
	auto model = QSharedPointer<AccountDeviceList>(new AccountDeviceList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<AccountDeviceList> AccountDeviceList::create(const QSharedPointer<AccountCore> &account) {
	auto model = create();
	model->setAccount(account);
	return model;
}

AccountDeviceList::AccountDeviceList() {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

AccountDeviceList::~AccountDeviceList() {
}

QList<QSharedPointer<AccountDeviceCore>>
AccountDeviceList::buildDevices(const std::list<std::shared_ptr<linphone::AccountDevice>> &devicesList) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	QList<QSharedPointer<AccountDeviceCore>> devices;
	for (auto &device : devicesList) {
		auto deviceCore = AccountDeviceCore::create(device);
		devices << deviceCore;
	}
	return devices;
}

const QSharedPointer<AccountCore> &AccountDeviceList::getAccount() const {
	return mAccountCore;
}

void AccountDeviceList::setAccount(const QSharedPointer<AccountCore> &accountCore) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mAccountCore != accountCore) {
		mAccountCore = accountCore;
		lDebug() << log().arg("Set account model") << mAccountCore.get();
		// oldConnect.unlock();
		refreshDevices();
		// }
	}
}

void AccountDeviceList::refreshDevices() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	beginResetModel();
	clearData();
	endResetModel();
	if (mAccountCore) {
		auto requestDeviceList = [this] {
			if (!mAccountManagerServicesModelConnection) return;
			mAccountManagerServicesModelConnection->invokeToModel([this]() {
				auto identityAddress = mAccountCore->getModel()->getMonitor()->getParams()->getIdentityAddress();
				auto authinfo = mAccountCore->getModel()->getMonitor()->findAuthInfo();
				qDebug() << "[AccountDeviceList] request devices for address" << identityAddress->asStringUriOnly();
				mAccountManagerServicesModel->getDeviceList(identityAddress);
			});
		};
		if (mIsComponentReady) {
			requestDeviceList();
		} else {
			connect(this, &AccountDeviceList::componentReady, this, requestDeviceList, Qt::SingleShotConnection);
		}
	}
}

void AccountDeviceList::setDevices(QList<QSharedPointer<AccountDeviceCore>> devices) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	add(devices);
	lDebug() << log().arg("Add %1 devices").arg(devices.size());
	emit devicesSet();
}

void AccountDeviceList::deleteDevice(AccountDeviceGui *deviceGui) {
	auto requestDeviceDeletion = [this, deviceGui] {
		if (!mAccountManagerServicesModelConnection) return;
		auto deviceCore = deviceGui->getCore();
		auto deviceModel = deviceCore->getModel();
		mAccountManagerServicesModelConnection->invokeToModel([this, deviceModel]() {
			auto linphoneDevice = deviceModel->getDevice();
			auto identityAddress = mAccountCore->getModel()->getMonitor()->getParams()->getIdentityAddress();
			auto authinfo = mAccountCore->getModel()->getMonitor()->findAuthInfo();
			qDebug() << "[AccountDeviceList] delete device" << linphoneDevice->getName() << "of address"
			         << identityAddress->asStringUriOnly();
			mAccountManagerServicesModel->deleteDevice(identityAddress, linphoneDevice);
		});
	};
	if (mIsComponentReady) {
		requestDeviceDeletion();
	} else {
		connect(this, &AccountDeviceList::componentReady, this, requestDeviceDeletion);
	}
}

void AccountDeviceList::setSelf(QSharedPointer<AccountDeviceList> me) {
	if (mCoreModelConnection) mCoreModelConnection->disconnect();
	mCoreModelConnection = SafeConnection<AccountDeviceList, CoreModel>::create(me, CoreModel::getInstance());
	mCoreModelConnection->invokeToModel([=] {
		auto core = CoreModel::getInstance()->getCore();
		auto ams = core->createAccountManagerServices();
		auto amsModel = Utils::makeQObject_ptr<AccountManagerServicesModel>(ams);
		mCoreModelConnection->invokeToCore([this, amsModel, me]() {
			mAccountManagerServicesModel = amsModel;
			if (mAccountManagerServicesModelConnection) mAccountManagerServicesModelConnection->disconnect();
			mAccountManagerServicesModelConnection =
			    SafeConnection<AccountDeviceList, AccountManagerServicesModel>::create(me,
			                                                                           mAccountManagerServicesModel);
			mAccountManagerServicesModelConnection->makeConnectToModel(
			    &AccountManagerServicesModel::requestSuccessfull,
			    [this](const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
			           const std::string &data) {
				    if (request->getType() == linphone::AccountManagerServicesRequest::Type::DeleteDevice) {
					    mAccountManagerServicesModelConnection->invokeToCore([this] { refreshDevices(); });
				    }
			    });
			mAccountManagerServicesModelConnection->makeConnectToModel(
			    &AccountManagerServicesModel::requestError,
			    [this](const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request, int statusCode,
			           const std::string &errorMessage,
					   const std::shared_ptr<const linphone::Dictionary> &parameterErrors) {
					lDebug() << "REQUEST ERROR" << errorMessage << "/" << int(request->getType());
					QString message = QString::fromStdString(errorMessage);
					if (request->getType() == linphone::AccountManagerServicesRequest::Type::GetDevicesList) {
						//: "Erreur lors de la récupération des appareils"
						message = tr("manage_account_no_device_found_error_message");
					}
					emit requestError(message);
			    });
			mAccountManagerServicesModelConnection->makeConnectToModel(
			    &AccountManagerServicesModel::devicesListFetched,
			    [this](const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request,
			           const std::list<std::shared_ptr<linphone::AccountDevice>> &devicesList) {
				    mAccountManagerServicesModelConnection->invokeToModel([this, request, devicesList]() {
					    if (request->getType() == linphone::AccountManagerServicesRequest::Type::GetDevicesList) {
						    QList<QSharedPointer<AccountDeviceCore>> devices;
						    for (auto &device : devicesList) {
							    auto deviceCore = AccountDeviceCore::create(device);
							    devices << deviceCore;
						    }
						    // auto devices = buildDevices(devicesList);
						    mAccountManagerServicesModelConnection->invokeToCore(
						        [this, devices]() { setDevices(devices); });
					    }
				    });
			    });
			mIsComponentReady = true;
			emit componentReady();
		});
	});
}

QVariant AccountDeviceList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= rowCount()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new AccountDeviceGui(mList[row].objectCast<AccountDeviceCore>()));
	return QVariant();
}
