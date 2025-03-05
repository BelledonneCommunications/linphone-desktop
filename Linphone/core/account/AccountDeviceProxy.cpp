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

#include "AccountDeviceProxy.hpp"
#include "AccountDeviceList.hpp"
#include "core/App.hpp"
#include "tool/Utils.hpp"

#include <QQmlApplicationEngine>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(AccountDeviceProxy)
DEFINE_GUI_OBJECT(AccountDeviceProxy)

AccountDeviceProxy::AccountDeviceProxy(QObject *parent) : LimitProxy(parent) {
	mAccountDeviceList = AccountDeviceList::create();
	connect(this, &AccountDeviceProxy::sourceModelChanged, this, [this] {
		auto model = getListModel<AccountDeviceList>();
		if (model) {
			connect(model, &AccountDeviceList::devicesSet, this, &AccountDeviceProxy::devicesSet);
			connect(model, &AccountDeviceList::requestError, this, &AccountDeviceProxy::requestError);
		}
	});
	setSourceModels(new SortFilterList(mAccountDeviceList.get(), Qt::DescendingOrder));
}

AccountDeviceProxy::~AccountDeviceProxy() {
	// setSourceModel(nullptr);
}

AccountGui *AccountDeviceProxy::getAccount() const {
	auto account = mAccountDeviceList->getAccount();
	return account ? new AccountGui(account) : nullptr;
}

void AccountDeviceProxy::setAccount(AccountGui *accountGui) {
	mAccountDeviceList->setAccount(accountGui ? accountGui->mCore : nullptr);
}

void AccountDeviceProxy::deleteDevice(AccountDeviceGui *device) {
	mAccountDeviceList->deleteDevice(device);
}

bool AccountDeviceProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool AccountDeviceProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	return sourceLeft.row() < sourceRight.row();
}
