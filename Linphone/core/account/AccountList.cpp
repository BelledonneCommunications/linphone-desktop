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
	mModelConnection = SafeConnection<AccountList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&AccountList::lUpdate, [this](bool isInitialization) {
		mModelConnection->invokeToModel([this, isInitialization]() {
			// Avoid copy to lambdas
			QList<QSharedPointer<AccountCore>> *accounts = new QList<QSharedPointer<AccountCore>>();
			mustBeInLinphoneThread(getClassName());
			auto linphoneAccounts = CoreModel::getInstance()->getCore()->getAccountList();
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			QSharedPointer<AccountCore> defaultAccountCore;
			for (auto it : linphoneAccounts) {
				auto model = AccountCore::create(it);
				if (it == defaultAccount) defaultAccountCore = model;
				accounts->push_back(model);
			}
			mModelConnection->invokeToCore([this, accounts, defaultAccountCore, isInitialization]() {
				mustBeInMainThread(getClassName());
				resetData<AccountCore>(*accounts);
				setHaveAccount(accounts->size() > 0);
				setDefaultAccount(defaultAccountCore);
				if (isInitialization) setInitialized(true);
				delete accounts;
			});
		});
	});
	mModelConnection->makeConnectToModel(
	    &CoreModel::defaultAccountChanged,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> &account) {
		    if (account && account->getParams()->getIdentityAddress()) {
			    auto address =
			        Utils::coreStringToAppString(account->getParams()->getIdentityAddress()->asStringUriOnly());
			    auto model = findAccountByAddress(address);
			    mModelConnection->invokeToCore([this, model]() { setDefaultAccount(model); });
		    } else mModelConnection->invokeToCore([this]() { setDefaultAccount(nullptr); });
	    });
	mModelConnection->makeConnectToModel(&CoreModel::accountRemoved, [this] { emit lUpdate(); });
	mModelConnection->makeConnectToModel(&CoreModel::accountAdded, [this] { emit lUpdate(true); });
	// force initialization on bearer account added to automatically go on the main page
	// with the open id account
	mModelConnection->makeConnectToModel(&CoreModel::bearerAccountAdded, [this] {
		setInitialized(false);
		emit lUpdate(true); });

	mModelConnection->makeConnectToModel(
	    &CoreModel::globalStateChanged,
	    [this](const std::shared_ptr<linphone::Core> &core, linphone::GlobalState gstate, const std::string &message) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    if (gstate == linphone::GlobalState::On) {
			    emit lUpdate();
		    }
	    });
	lUpdate(true);
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

QSharedPointer<AccountCore> AccountList::findAccountByAddress(const QString &address) {
	for (auto &item : getSharedList<AccountCore>()) {
		if (item->getIdentityAddress() == address) {
			return item;
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

bool AccountList::isInitialized() const {
	return mIsInitialized;
}

void AccountList::setInitialized(bool init) {
	if (mIsInitialized != init) {
		mIsInitialized = init;
		emit initializedChanged(mIsInitialized);
	}
}

QVariant AccountList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new AccountGui(mList[row].objectCast<AccountCore>()));
	return QVariant();
}
