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
#include "Account.hpp"
#include "AccountList.hpp"

AccountProxy::AccountProxy(QObject *parent) : SortFilterProxy(parent) {
	setSourceModel(new AccountList(this));
	sort(0);
}

AccountProxy::~AccountProxy() {
}

QString AccountProxy::getFilterText() const {
	return mFilterText;
}

void AccountProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
		mFilterText = filter;
		invalidate();
		emit filterTextChanged();
	}
}

bool AccountProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");
	if (!show) {
		QRegularExpression search(QRegularExpression::escape(mFilterText),
		                          QRegularExpression::CaseInsensitiveOption |
		                              QRegularExpression::UseUnicodePropertiesOption);
		QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
		auto model = sourceModel()->data(index);
		auto account = model.value<Account *>();
		show = account->getIdentityAddress().contains(search);
	}

	return show;
}

bool AccountProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = sourceModel()->data(left);
	auto r = sourceModel()->data(right);

	return l.value<Account *>()->getIdentityAddress() < r.value<Account *>()->getIdentityAddress();
}
