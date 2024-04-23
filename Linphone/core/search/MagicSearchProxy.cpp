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

#include "MagicSearchProxy.hpp"
#include "MagicSearchList.hpp"
#include "core/friend/FriendGui.hpp"

MagicSearchProxy::MagicSearchProxy(QObject *parent) : SortFilterProxy(parent) {
	mList = MagicSearchList::create();
	connect(mList.get(), &MagicSearchList::sourceFlagsChanged, this, &MagicSearchProxy::sourceFlagsChanged);
	connect(mList.get(), &MagicSearchList::aggregationFlagChanged, this, &MagicSearchProxy::aggregationFlagChanged);
	connect(mList.get(), &MagicSearchList::friendCreated, this, [this](int index) {
		auto proxyIndex = mapFromSource(sourceModel()->index(index, 0));
		emit friendCreated(proxyIndex.row());
	});
	setSourceModel(mList.get());
	connect(this, &MagicSearchProxy::forceUpdate, [this] { emit mList->lSearch(mSearchText); });
	sort(0);
}

MagicSearchProxy::~MagicSearchProxy() {
}

QString MagicSearchProxy::getSearchText() const {
	return mSearchText;
}

void MagicSearchProxy::setSearchText(const QString &search) {
	mSearchText = search;
	qobject_cast<MagicSearchList *>(sourceModel())->setSearch(mSearchText);
}

int MagicSearchProxy::getSourceFlags() const {
	return qobject_cast<MagicSearchList *>(sourceModel())->getSourceFlags();
}

void MagicSearchProxy::setSourceFlags(int flags) {
	qobject_cast<MagicSearchList *>(sourceModel())->lSetSourceFlags(flags);
}

LinphoneEnums::MagicSearchAggregation MagicSearchProxy::getAggregationFlag() const {
	return qobject_cast<MagicSearchList *>(sourceModel())->getAggregationFlag();
}

void MagicSearchProxy::setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag) {
	qobject_cast<MagicSearchList *>(sourceModel())->lSetAggregationFlag(flag);
}

bool MagicSearchProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = sourceModel()->data(left);
	auto r = sourceModel()->data(right);

	auto lIsFriend = l.value<FriendGui *>();
	auto rIsFriend = r.value<FriendGui *>();

	if (lIsFriend && rIsFriend) {
		auto lName = lIsFriend->getCore()->getDisplayName().toLower();
		auto rName = rIsFriend->getCore()->getDisplayName().toLower();
		return lName < rName;
	}
	return true;
}