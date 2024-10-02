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

#include "FriendInitialProxy.hpp"
#include "FriendCore.hpp"
#include "FriendGui.hpp"

DEFINE_ABSTRACT_OBJECT(FriendInitialProxy)

FriendInitialProxy::FriendInitialProxy(QObject *parent) : SortFilterProxy(parent) {
}

FriendInitialProxy::~FriendInitialProxy() {
	setSourceModel(nullptr);
}

QString FriendInitialProxy::getFilterText() const {
	return mFilterText;
}

void FriendInitialProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
		mFilterText = filter;
		invalidate();
		emit filterTextChanged();
	}
}

bool FriendInitialProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");
	if (!show) {
		QRegularExpression search(mFilterText, QRegularExpression::CaseInsensitiveOption |
		                                           QRegularExpression::UseUnicodePropertiesOption);
		auto friendData = sourceModel()->data(sourceModel()->index(sourceRow, 0, sourceParent)).value<FriendGui *>();
		auto friendCore = friendData->getCore();
		show = friendCore->getGivenName().indexOf(search) == 0 || friendCore->getFamilyName().indexOf(search) == 0;
	}

	return show;
}

// bool FriendInitialProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
// 	// auto l = getItemAt<MagicSearchProxy, FriendCore>(left.row());
// 	// auto r = getItemAt<MagicSearchProxy, FriendCore>(right.row());
// 	// return l->getName() < r->getName();
// }

QVariant FriendInitialProxy::data(const QModelIndex &index, int role) const {
	return sourceModel()->data(mapToSource(index));
}
