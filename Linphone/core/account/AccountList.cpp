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
	qDebug() << "[AccountList] new" << this;
	mustBeInMainThread(getClassName());
	connect(CoreModel::getInstance().get(), &CoreModel::accountAdded, this, &AccountList::lUpdate);
}

AccountList::~AccountList() {
	qDebug() << "[AccountList] delete" << this;
	mustBeInMainThread("~" + getClassName());
}

void AccountList::setSelf(QSharedPointer<AccountList> me) {
	mModelConnection = QSharedPointer<SafeConnection>(
	    new SafeConnection(me.objectCast<QObject>(), std::dynamic_pointer_cast<QObject>(CoreModel::getInstance())),
	    &QObject::deleteLater);
	mModelConnection->makeConnect(this, &AccountList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			QList<QSharedPointer<AccountCore>> *accounts = new QList<QSharedPointer<AccountCore>>();
			// Model thread.
			mustBeInLinphoneThread(getClassName());
			auto linphoneAccounts = CoreModel::getInstance()->getCore()->getAccountList();
			for (auto it : linphoneAccounts) {
				auto model = AccountCore::create(it);
				accounts->push_back(model);
			}
			mModelConnection->invokeToCore([this, accounts]() {
				mustBeInMainThread(getClassName());
				resetData();
				add(*accounts);
				delete accounts;
			});
		});
	});

	lUpdate();
}

AccountGui *AccountList::getDefaultAccount() const {
	for (auto it : mList) {
		auto account = it.objectCast<AccountCore>();
		if (account->getIsDefaultAccount()) return new AccountGui(account);
	}
	return nullptr;
}
/*
void AccountList::update() {
    App::postModelAsync([=]() {
        QList<QSharedPointer<AccountCore>> accounts;
        // Model thread.
        mustBeInLinphoneThread(getClassName());
        auto linphoneAccounts = CoreModel::getInstance()->getCore()->getAccountList();
        for (auto it : linphoneAccounts) {
            auto model = AccountCore::create(it);
            accounts.push_back(model);
        }
        // Invoke for adding stuffs in caller thread
        QMetaObject::invokeMethod(this, [this, accounts]() {
            mustBeInMainThread(getClassName());
            clearData();
            add(accounts);
        });
    });
}
*/
QVariant AccountList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new AccountGui(mList[row].objectCast<AccountCore>()));
	return QVariant();
}
