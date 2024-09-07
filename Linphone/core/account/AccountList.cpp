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

#include "AccountList.hpp"
#include "AccountCore.hpp"
#include "AccountGui.hpp"
#include "core/App.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(AccountList)

QSharedPointer<AccountList> AccountList::create() {
	auto model = QSharedPointer<AccountList>(new AccountList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

AccountList::AccountList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

AccountList::~AccountList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

void AccountList::setSelf(QSharedPointer<AccountList> me) {
	mModelConnection = QSharedPointer<SafeConnection<AccountList, CoreModel>>(
	    new SafeConnection<AccountList, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);

	mModelConnection->makeConnectToCore(&AccountList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			// Avoid copy to lambdas
			QList<QSharedPointer<AccountCore>> *accounts = new QList<QSharedPointer<AccountCore>>();
			mustBeInLinphoneThread(getClassName());
			auto linphoneAccounts = CoreModel::getInstance()->getCore()->getAccountList();
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			QSharedPointer<AccountCore> defaultAccountCore;
			for (auto it : linphoneAccounts) {
				auto model = AccountCore::create(it);
				if (it == defaultAccount) defaultAccountCore = AccountCore::create(defaultAccount);
				accounts->push_back(model);
			}
			mModelConnection->invokeToCore([this, accounts, defaultAccountCore]() {
				mustBeInMainThread(getClassName());
				resetData();
				add(*accounts);
				setHaveAccount(accounts->size() > 0);
				setDefaultAccount(defaultAccountCore);
				delete accounts;
			});
		});
	});
	mModelConnection->makeConnectToModel(
	    &CoreModel::defaultAccountChanged,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> &account) {
		    if (account) {
			    auto model = AccountCore::create(account);
			    mModelConnection->invokeToCore([this, model]() { setDefaultAccount(model); });
		    } else mModelConnection->invokeToCore([this]() { setDefaultAccount(nullptr); });
	    });
	mModelConnection->makeConnectToModel(&CoreModel::accountRemoved, &AccountList::lUpdate);
	mModelConnection->makeConnectToModel(&CoreModel::accountAdded, &AccountList::lUpdate);

	lUpdate();
	emit initialized();
}

QSharedPointer<AccountCore> AccountList::getDefaultAccountCore() const {
	return mDefaultAccount;
}

AccountGui *AccountList::getDefaultAccount() const {
	auto account = getDefaultAccountCore();
	if (account) return new AccountGui(account);
	else return nullptr;
}

void AccountList::setDefaultAccount(QSharedPointer<AccountCore> account) {
	if (mDefaultAccount != account) {
		mDefaultAccount = account;
		emit defaultAccountChanged();
	}
}

AccountGui *AccountList::findAccountByAddress(const QString &address) {
	for (auto &item : mList) {
		if (auto isAccount = item.objectCast<AccountCore>()) {
			if (isAccount->getIdentityAddress() == address) {
				return new AccountGui(isAccount);
			}
		}
	}
	return nullptr;
}

AccountGui *AccountList::firstAccount() {
	for (auto &item : mList) {
		if (auto isAccount = item.objectCast<AccountCore>()) {
			return new AccountGui(isAccount);
		}
	}
	return nullptr;
}

bool AccountList::getHaveAccount() const {
	return mHaveAccount;
}

void AccountList::setHaveAccount(bool haveAccount) {
	if (mHaveAccount != haveAccount) {
		mHaveAccount = haveAccount;
		emit haveAccountChanged();
	}
}

QVariant AccountList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new AccountGui(mList[row].objectCast<AccountCore>()));
	return QVariant();
}
