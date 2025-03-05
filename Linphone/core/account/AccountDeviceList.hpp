/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef ACCOUNT_DEVICE_LIST_H_
#define ACCOUNT_DEVICE_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "AccountDeviceCore.hpp"
#include "core/account/AccountGui.hpp"
#include "model/account/AccountManagerServicesModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"

class AccountDeviceGui;
class AccountDeviceList : public ListProxy, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<AccountDeviceList> create();
	static QSharedPointer<AccountDeviceList> create(const QSharedPointer<AccountCore> &accountCore);

	AccountDeviceList();
	~AccountDeviceList();

	QList<QSharedPointer<AccountDeviceCore>>
	buildDevices(const std::list<std::shared_ptr<linphone::AccountDevice>> &devicesList);

	const QSharedPointer<AccountCore> &getAccount() const;
	void setAccount(const QSharedPointer<AccountCore> &accountCore);
	void refreshDevices();

	void setDevices(QList<QSharedPointer<AccountDeviceCore>> devices);
	void deleteDevice(AccountDeviceGui *deviceGui);

	void setSelf(QSharedPointer<AccountDeviceList> me);

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void componentReady();
	void devicesSet();
	void requestError(QString errorMessage = QString());

private:
	QSharedPointer<AccountCore> mAccountCore;
	std::shared_ptr<AccountManagerServicesModel> mAccountManagerServicesModel;
	QSharedPointer<SafeConnection<AccountDeviceList, AccountManagerServicesModel>>
	    mAccountManagerServicesModelConnection;
	QSharedPointer<SafeConnection<AccountDeviceList, CoreModel>> mCoreModelConnection;
	bool mIsComponentReady = false;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(QSharedPointer<AccountDeviceList>);

#endif // ACCOUNT_DEVICE_LIST_H_
