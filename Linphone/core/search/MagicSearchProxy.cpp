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
#include "core/App.hpp"
#include "core/friend/FriendGui.hpp"

MagicSearchProxy::MagicSearchProxy(QObject *parent) : LimitProxy(parent) {
	mSourceFlags = (int)LinphoneEnums::MagicSearchSource::Friends | (int)LinphoneEnums::MagicSearchSource::LdapServers;
	mAggregationFlag = LinphoneEnums::MagicSearchAggregation::Friend;
	setList(MagicSearchList::create());
	sort(0);
	connect(this, &MagicSearchProxy::forceUpdate, [this] {
		if (mList) emit mList->lSearch(mSearchText);
	});
	connect(App::getInstance(), &App::currentDateChanged, this, &MagicSearchProxy::forceUpdate);
}

MagicSearchProxy::~MagicSearchProxy() {
	setSourceModel(nullptr);
}

void MagicSearchProxy::setList(QSharedPointer<MagicSearchList> newList) {
	if (mList == newList) return;
	if (mList) {
		disconnect(mList.get());
	}
	auto oldModel = dynamic_cast<SortFilterList *>(sourceModel());
	mList = newList;
	if (mList) {
		connect(mList.get(), &MagicSearchList::sourceFlagsChanged, this, &MagicSearchProxy::sourceFlagsChanged,
		        Qt::QueuedConnection);
		connect(mList.get(), &MagicSearchList::aggregationFlagChanged, this, &MagicSearchProxy::aggregationFlagChanged,
		        Qt::QueuedConnection);
		connect(
		    mList.get(), &MagicSearchList::friendCreated, this,
		    [this](int index) {
			    auto proxyIndex =
			        dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(mList->index(index, 0)).row();
			    // auto proxyIndex = mapFromSource(sourceModel()->index(index, 0)); // OLD (keep for checking new proxy
			    // behavior)
			    emit friendCreated(proxyIndex);
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
	auto sortFilterList = new SortFilterList(mList.get(), Qt::AscendingOrder);
	if (oldModel) {
		sortFilterList->mShowFavoritesOnly = oldModel->mShowFavoritesOnly;
		sortFilterList->mShowLdapContacts = oldModel->mShowLdapContacts;
		sortFilterList->mHideListProxy = oldModel->mHideListProxy;
		if (sortFilterList->mHideListProxy) {
			connect(sortFilterList->mHideListProxy, &MagicSearchProxy::countChanged, sortFilterList,
			        [this, sortFilterList]() { sortFilterList->invalidate(); });
			connect(sortFilterList, &MagicSearchProxy::modelReset, sortFilterList,
			        [this, sortFilterList]() { sortFilterList->invalidate(); });
		}
	}
	setSourceModels(sortFilterList);
}

int MagicSearchProxy::findFriendIndexByAddress(const QString &address) {
	auto magicSearchList = getListModel<MagicSearchList>();
	if (magicSearchList) {
		auto listIndex = magicSearchList->findFriendIndexByAddress(address);
		if (listIndex == -1) return -1;
		return dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(magicSearchList->index(listIndex, 0)).row();
	} else return -1;
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
	return dynamic_cast<SortFilterList *>(sourceModel())->mShowFavoritesOnly;
}

void MagicSearchProxy::setShowFavoritesOnly(bool show) {
	auto list = dynamic_cast<SortFilterList *>(sourceModel());
	if (list->mShowFavoritesOnly != show) {
		list->mShowFavoritesOnly = show;
		list->invalidate();
		emit showFavoriteOnlyChanged();
	}
}

void MagicSearchProxy::setParentProxy(MagicSearchProxy *proxy) {
	setList(proxy->mList);
	emit parentProxyChanged();
}

MagicSearchProxy *MagicSearchProxy::getHideListProxy() const {
	auto list = dynamic_cast<SortFilterList *>(sourceModel());
	return list ? list->mHideListProxy : nullptr;
}

void MagicSearchProxy::setHideListProxy(MagicSearchProxy *proxy) {
	auto list = dynamic_cast<SortFilterList *>(sourceModel());
	if (list && list->mHideListProxy != proxy) {
		if (list->mHideListProxy) list->disconnect(list->mHideListProxy);
		list->mHideListProxy = proxy;
		list->invalidate();
		if (proxy) {
			connect(proxy, &MagicSearchProxy::countChanged, list, [this, list]() { list->invalidate(); });
			connect(proxy, &MagicSearchProxy::modelReset, list, [this, list]() { list->invalidate(); });
		}
		emit hideListProxyChanged();
	}
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

bool MagicSearchProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto friendCore = getItemAtSource<MagicSearchList, FriendCore>(sourceRow);
	auto toShow = false;
	if (friendCore) {
		toShow = (!mShowFavoritesOnly || friendCore->getStarred()) && (mShowLdapContacts || !friendCore->isLdap());
		if (toShow && mHideListProxy) {
			for (auto &friendAddress : friendCore->getAllAddresses()) {
				toShow = mHideListProxy->findFriendIndexByAddress(friendAddress.toMap()["address"].toString()) == -1;
				if (!toShow) break;
			}
		}
	}

	return toShow;
}

bool MagicSearchProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<MagicSearchList, FriendCore>(sourceLeft.row());
	auto r = getItemAtSource<MagicSearchList, FriendCore>(sourceRight.row());

	if (l && r) {
		auto lName = l->getDisplayName().toLower();
		auto rName = r->getDisplayName().toLower();
		return lName < rName;
	}
	return true;
}

bool MagicSearchProxy::showLdapContacts() const {
	return dynamic_cast<SortFilterList *>(sourceModel())->mShowLdapContacts;
}

void MagicSearchProxy::setShowLdapContacts(bool show) {
	auto list = dynamic_cast<SortFilterList *>(sourceModel());
	if (list->mShowLdapContacts != show) {
		list->mShowLdapContacts = show;
		list->invalidate();
	}
}
