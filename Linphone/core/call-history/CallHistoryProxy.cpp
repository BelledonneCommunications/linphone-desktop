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

#include "CallHistoryProxy.hpp"
#include "CallHistoryGui.hpp"
#include "CallHistoryList.hpp"

DEFINE_ABSTRACT_OBJECT(CallHistoryProxy)

CallHistoryProxy::CallHistoryProxy(QObject *parent) : LimitProxy(parent) {
	mHistoryList = CallHistoryList::create();
	setSourceModels(new SortFilterList(mHistoryList.get(), Qt::DescendingOrder));
}

CallHistoryProxy::~CallHistoryProxy() {
}

void CallHistoryProxy::removeAllEntries() {
	mHistoryList->removeAllEntries();
}

void CallHistoryProxy::removeEntriesWithFilter() {
	QList<QSharedPointer<CallHistoryCore>> itemList(rowCount());
	for (auto i = rowCount() - 1; i >= 0; --i) {
		auto item = getItemAt<SortFilterList, CallHistoryList, CallHistoryCore>(i);
		itemList[i] = item;
	}
	for (auto item : itemList) {
		mHistoryList->ListProxy::remove(item.get());
	}
}

//------------------------------------------------------------------------------------------

bool CallHistoryProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");

	if (!show) {
		QRegularExpression search(QRegularExpression::escape(mFilterText),
		                          QRegularExpression::CaseInsensitiveOption |
		                              QRegularExpression::UseUnicodePropertiesOption);
		auto callLog = getItemAtSource<CallHistoryList, CallHistoryCore>(sourceRow);
		show =
		    callLog->mIsConference ? callLog->mDisplayName.contains(search) : callLog->mRemoteAddress.contains(search);
	}
	return show;
}

bool CallHistoryProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<CallHistoryList, CallHistoryCore>(sourceLeft.row());
	auto r = getItemAtSource<CallHistoryList, CallHistoryCore>(sourceRight.row());

	return l->mDate < r->mDate;
}
