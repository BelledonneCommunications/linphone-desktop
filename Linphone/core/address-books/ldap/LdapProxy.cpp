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

#include "LdapProxy.hpp"
#include "LdapCore.hpp"
#include "LdapList.hpp"

DEFINE_ABSTRACT_OBJECT(LdapProxy)

LdapProxy::LdapProxy(QObject *parent) : LimitProxy(parent) {
	mLdapList = LdapList::create();
	setSourceModels(new SortFilterList(mLdapList.get(), Qt::AscendingOrder));
}

LdapProxy::~LdapProxy() {
	setSourceModel(nullptr);
}

void LdapProxy::removeAllEntries() {
	getListModel<LdapList>()->removeAllEntries();
}

void LdapProxy::removeEntriesWithFilter() {
	QList<QSharedPointer<LdapCore>> itemList(rowCount());
	for (auto i = rowCount() - 1; i >= 0; --i) {
		auto item = getItemAt<SortFilterList, LdapList, LdapCore>(i);
		itemList[i] = item;
	}
	for (auto item : itemList) {
		mLdapList->ListProxy::remove(item.get());
	}
}

bool LdapProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool LdapProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<LdapList, LdapCore>(sourceLeft.row());
	auto r = getItemAtSource<LdapList, LdapCore>(sourceRight.row());

	return l->mSipDomain < r->mSipDomain;
}

void LdapProxy::updateView() {
	mLdapList->lUpdate();
}
