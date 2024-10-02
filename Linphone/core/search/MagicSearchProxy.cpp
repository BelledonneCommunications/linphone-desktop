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
	mSourceFlags = (int)LinphoneEnums::MagicSearchSource::Friends | (int)LinphoneEnums::MagicSearchSource::LdapServers;
	mAggregationFlag = LinphoneEnums::MagicSearchAggregation::Friend;
	setList(MagicSearchList::create());
	sort(0);
	connect(this, &MagicSearchProxy::forceUpdate, [this] {
		if (mList) emit mList->lSearch(mSearchText);
	});
}

MagicSearchProxy::~MagicSearchProxy() {
	setSourceModel(nullptr);
}

void MagicSearchProxy::setList(QSharedPointer<MagicSearchList> newList) {
	if (mList == newList) return;
	if (mList) {
		disconnect(mList.get());
	}
	mList = newList;
	if (mList) {
		connect(mList.get(), &MagicSearchList::sourceFlagsChanged, this, &MagicSearchProxy::sourceFlagsChanged,
		        Qt::QueuedConnection);
		connect(mList.get(), &MagicSearchList::aggregationFlagChanged, this, &MagicSearchProxy::aggregationFlagChanged,
		        Qt::QueuedConnection);
		connect(
		    mList.get(), &MagicSearchList::friendCreated, this,
		    [this](int index) {
			    auto proxyIndex = mapFromSource(sourceModel()->index(index, 0));
			    emit friendCreated(proxyIndex.row());
		    },
		    Qt::QueuedConnection);
		connect(
		    mList.get(), &MagicSearchList::initialized, this,
		    [this, newList = mList.get()] {
			    emit newList->lSetSourceFlags(mSourceFlags);
			    emit newList->lSetAggregationFlag(mAggregationFlag);
			    emit initialized();
		    },
		    Qt::QueuedConnection);
	}
	setSourceModel(mList.get());
}

int MagicSearchProxy::findFriendIndexByAddress(const QString &address) {
	auto magicSearchList = qobject_cast<MagicSearchList *>(sourceModel());
	if (magicSearchList)
		return mapFromSource(magicSearchList->index(magicSearchList->findFriendIndexByAddress(address), 0)).row();
	else return -1;
}

QString MagicSearchProxy::getSearchText() const {
	return mSearchText;
}

void MagicSearchProxy::setSearchText(const QString &search) {
	if (mSearchText != search) {
		mSearchText = search;
		mList->setSearch(mSearchText);
	}
}

int MagicSearchProxy::getSourceFlags() const {
	return mSourceFlags;
}

void MagicSearchProxy::setSourceFlags(int flags) {
	if (flags != mSourceFlags) {
		mSourceFlags = flags;
		emit mList->lSetSourceFlags(flags);
	}
}

bool MagicSearchProxy::showFavoritesOnly() const {
	return mShowFavoritesOnly;
}

void MagicSearchProxy::setShowFavoritesOnly(bool show) {
	if (mShowFavoritesOnly != show) {
		mShowFavoritesOnly = show;
		emit showFavoriteOnlyChanged();
	}
}

void MagicSearchProxy::setParentProxy(MagicSearchProxy *proxy) {
	setList(proxy->mList);
	emit parentProxyChanged();
}

LinphoneEnums::MagicSearchAggregation MagicSearchProxy::getAggregationFlag() const {
	return mAggregationFlag;
}

void MagicSearchProxy::setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag) {
	if (flag != mAggregationFlag) {
		mAggregationFlag = flag;
		emit mList->lSetAggregationFlag(flag);
	}
}

bool MagicSearchProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	auto model = sourceModel()->data(index);
	auto friendGui = model.value<FriendGui *>();
	auto friendCore = friendGui->getCore();
	if (friendCore) {
		return !mShowFavoritesOnly || friendCore->getStarred();
	}
	return false;
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
