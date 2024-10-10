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

#include "AccountProxy.hpp"
#include "AccountGui.hpp"
#include "AccountList.hpp"
#include "core/App.hpp"

AccountProxy::AccountProxy(QObject *parent) : LimitProxy(parent) {
	setSourceModels(new SortFilterList(App::getInstance()->getAccountList().get(), Qt::AscendingOrder));
}

AccountProxy::~AccountProxy() {
	setSourceModel(nullptr);
}

AccountGui *AccountProxy::getDefaultAccount() {
	if (!mDefaultAccount)
		mDefaultAccount = dynamic_cast<AccountList *>(dynamic_cast<SortFilterList *>(sourceModel())->sourceModel())
		                      ->getDefaultAccountCore();
	return new AccountGui(mDefaultAccount);
}

void AccountProxy::setDefaultAccount(AccountGui *account) {
}

// Reset the default account to let UI build its new object if needed.
void AccountProxy::resetDefaultAccount() {
	mDefaultAccount = nullptr;
	emit this->defaultAccountChanged(); // Warn the UI
}

AccountGui *AccountProxy::findAccountByAddress(const QString &address) {
	return getListModel<AccountList>()->findAccountByAddress(address);
}

AccountGui *AccountProxy::firstAccount() {
	return getListModel<AccountList>()->firstAccount();
}

bool AccountProxy::getHaveAccount() const {
	return getListModel<AccountList>()->getHaveAccount();
}

void AccountProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldAccountList = getListModel<AccountList>();
	if (oldAccountList) {
		disconnect(oldAccountList);
	}
	auto newAccountList = dynamic_cast<AccountList *>(model);
	if (newAccountList) {
		connect(newAccountList, &AccountList::countChanged, this, &AccountProxy::resetDefaultAccount,
		        Qt::QueuedConnection);
		connect(newAccountList, &AccountList::defaultAccountChanged, this, &AccountProxy::resetDefaultAccount,
		        Qt::QueuedConnection);
		connect(newAccountList, &AccountList::haveAccountChanged, this, &AccountProxy::haveAccountChanged,
		        Qt::QueuedConnection);
	}
	QSortFilterProxyModel::setSourceModel(model);
}

//------------------------------------------------------------------------------------------

bool AccountProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");
	if (!show) {
		QRegularExpression search(QRegularExpression::escape(mFilterText),
		                          QRegularExpression::CaseInsensitiveOption |
		                              QRegularExpression::UseUnicodePropertiesOption);
		auto account = getItemAtSource<AccountList, AccountCore>(sourceRow);
		show = account->getIdentityAddress().contains(search);
	}

	return show;
}

bool AccountProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<AccountList, AccountCore>(sourceLeft.row());
	auto r = getItemAtSource<AccountList, AccountCore>(sourceRight.row());

	return l->getIdentityAddress() < r->getIdentityAddress();
}
