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

CallHistoryProxy::CallHistoryProxy(QObject *parent) : SortFilterProxy(parent) {
	mHistoryList = CallHistoryList::create();
	setSourceModel(mHistoryList.get());
	// sort(0);
}

CallHistoryProxy::~CallHistoryProxy() {
	setSourceModel(nullptr);
}

QString CallHistoryProxy::getFilterText() const {
	return mFilterText;
}

void CallHistoryProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
		mFilterText = filter;
		invalidate();
		emit filterTextChanged();
	}
}

void CallHistoryProxy::removeAllEntries() {
	static_cast<CallHistoryList *>(sourceModel())->removeAllEntries();
}

void CallHistoryProxy::removeEntriesWithFilter() {
	std::list<QSharedPointer<CallHistoryCore>> itemList(rowCount());
	for (auto i = rowCount() - 1; i >= 0; --i) {
		auto item = getItemAt<CallHistoryList, CallHistoryCore>(i);
		itemList.emplace_back(item);
	}
	for (auto item : itemList) {
		mHistoryList->ListProxy::remove(item.get());
		if (item) item->remove();
	}
}

void CallHistoryProxy::updateView() {
	mHistoryList->lUpdate();
}

bool CallHistoryProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");
	if (!show) {
		QRegularExpression search(QRegularExpression::escape(mFilterText),
		                          QRegularExpression::CaseInsensitiveOption |
		                              QRegularExpression::UseUnicodePropertiesOption);
		auto callLog = qobject_cast<CallHistoryList *>(sourceModel())->getAt<CallHistoryCore>(sourceRow);
		show =
		    callLog->mIsConference ? callLog->mDisplayName.contains(search) : callLog->mRemoteAddress.contains(search);
	}

	return show;
}

bool CallHistoryProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = getItemAt<CallHistoryList, CallHistoryCore>(left.row());
	auto r = getItemAt<CallHistoryList, CallHistoryCore>(right.row());

	return l->mDate < r->mDate;
}
