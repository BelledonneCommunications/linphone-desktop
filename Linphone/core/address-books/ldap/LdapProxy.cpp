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
#include "LdapGui.hpp"
#include "LdapList.hpp"

DEFINE_ABSTRACT_OBJECT(LdapProxy)

LdapProxy::LdapProxy(QObject *parent) : SortFilterProxy(parent) {
	mLdapList = LdapList::create();
	setSourceModel(mLdapList.get());
}

LdapProxy::~LdapProxy() {
	setSourceModel(nullptr);
}

QString LdapProxy::getFilterText() const {
	return mFilterText;
}

void LdapProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
		mFilterText = filter;
		invalidate();
		emit filterTextChanged();
	}
}

void LdapProxy::removeAllEntries() {
	static_cast<LdapList *>(sourceModel())->removeAllEntries();
}

void LdapProxy::removeEntriesWithFilter() {
	std::list<QSharedPointer<LdapCore>> itemList(rowCount());
	for (auto i = rowCount() - 1; i >= 0; --i) {
		auto item = getItemAt<LdapList, LdapCore>(i);
		itemList.emplace_back(item);
	}
	for (auto item : itemList) {
		mLdapList->ListProxy::remove(item.get());
		if (item) item->remove();
	}
}

bool LdapProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool LdapProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = getItemAt<LdapList, LdapCore>(left.row());
	auto r = getItemAt<LdapList, LdapCore>(right.row());

	return l->mSipDomain < r->mSipDomain;
}

void LdapProxy::updateView() {
	mLdapList->lUpdate();
}
