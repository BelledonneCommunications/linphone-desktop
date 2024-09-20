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

#ifndef ACCOUNT_DEVICE_PROXY_MODEL_H_
#define ACCOUNT_DEVICE_PROXY_MODEL_H_

#include "../proxy/SortFilterProxy.hpp"
#include "core/account/AccountDeviceGui.hpp"
#include "core/account/AccountGui.hpp"
#include "core/call/CallGui.hpp"
#include "tool/AbstractObject.hpp"

class AccountDeviceList;
class AccountDeviceGui;

class AccountDeviceProxy : public SortFilterProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(AccountGui *account READ getAccount WRITE setAccount NOTIFY accountChanged)

public:
	DECLARE_GUI_OBJECT
	AccountDeviceProxy(QObject *parent = Q_NULLPTR);
	~AccountDeviceProxy();

	AccountGui *getAccount() const;
	void setAccount(AccountGui *accountGui);
	Q_INVOKABLE void deleteDevice(AccountDeviceGui *device);

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

signals:
	void lUpdate();
	void accountChanged();

private:
	QString mSearchText;
	QSharedPointer<AccountDeviceList> mAccountDeviceList;
	QSharedPointer<SafeConnection<AccountDeviceProxy, CoreModel>> mCoreModelConnection;

	DECLARE_ABSTRACT_OBJECT
};

#endif
