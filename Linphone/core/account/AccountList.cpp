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
#include "Account.hpp"
#include "core/App.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(AccountList)

AccountList::AccountList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::postModelAsync([=]() {
		QList<QSharedPointer<Account>> accounts;
		// Model thread.
		mustBeInLinphoneThread(getClassName());
		auto linphoneAccounts = CoreModel::getInstance()->getCore()->getAccountList();
		for (auto it : linphoneAccounts) {
			auto model = QSharedPointer<Account>(new Account(it), &QObject::deleteLater);
			model->moveToThread(this->thread());
			accounts.push_back(model);
		}
		// Invoke for adding stuffs in caller thread
		QMetaObject::invokeMethod(this, [this, accounts]() {
			mustBeInMainThread(getClassName());
			add(accounts);
		});
	});
}

AccountList::~AccountList() {
	mustBeInMainThread("~" + getClassName());
}
