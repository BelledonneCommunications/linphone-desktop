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
#include "core/friend/FriendCore.hpp"

MagicSearchProxy::MagicSearchProxy(QObject *parent) : LimitProxy(parent) {
	auto magicSearchList = MagicSearchList::create();
	setList(magicSearchList);
	connect(this, &MagicSearchProxy::forceUpdate, [this] {
		if (mList) emit mList->lSearch(mSearchText, getSourceFlags(), getAggregationFlag(), getMaxResults());
	});
	connect(App::getInstance(), &App::currentDateChanged, this, &MagicSearchProxy::forceUpdate);
	connect(magicSearchList.get(), &MagicSearchList::resultsProcessed, this, &MagicSearchProxy::resultsProcessed);
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
		    [this](int index, FriendGui *data) {
			    auto sortModel = dynamic_cast<SortFilterList *>(sourceModel());
			    sortModel->invalidate();
			    if (!data->mCore->isLdap() && !data->mCore->isCardDAV()) {
				    auto proxyIndex = sortModel->mapFromSource(mList->index(index, 0)).row();
				    // auto proxyIndex = mapFromSource(sourceModel()->index(index, 0)); // OLD (keep for checking new
				    // proxy behavior)
				    emit localFriendCreated(proxyIndex);
			    }
		    },
		    Qt::QueuedConnection);
		connect(
		    mList.get(), &MagicSearchList::initialized, this, [this, newList = mList.get()] { emit initialized(); },
		    Qt::QueuedConnection);
	}
	auto sortFilterList = new SortFilterList(mList.get(), Qt::AscendingOrder);
	if (oldModel) {
		sortFilterList->mFilterType = oldModel->mFilterType;
		sortFilterList->mHideListProxy = oldModel->mHideListProxy;
		if (sortFilterList->mHideListProxy) {
			connect(sortFilterList->mHideListProxy, &MagicSearchProxy::countChanged, sortFilterList,
			        [this, sortFilterList]() { sortFilterList->invalidate(); });
			connect(sortFilterList, &MagicSearchProxy::modelReset, sortFilterList,
			        [this, sortFilterList]() { sortFilterList->invalidate(); });
		}
	}
	connect(
	    mList.get(), &MagicSearchList::friendStarredChanged, this,
	    [this, sortFilterList]() {
		    if ((getFilterType() & (int)FilteringTypes::Favorites) > 0) sortFilterList->invalidate();
	    },
	    Qt::QueuedConnection);
	setSourceModels(sortFilterList);
	sort(0);
}

int MagicSearchProxy::findFriendIndexByAddress(const QString &address) {
	auto magicSearchList = getListModel<MagicSearchList>();
	if (magicSearchList) {
		auto listIndex = magicSearchList->findFriendIndexByAddress(address);
		if (listIndex == -1) return -1;
		return dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(magicSearchList->index(listIndex, 0)).row();
	} else return -1;
}

FriendGui *MagicSearchProxy::findFriendByAddress(const QString &address) {
	auto magicSearchList = getListModel<MagicSearchList>();
	if (magicSearchList) {
		auto friendCore = magicSearchList->findFriendByAddress(address);
		return friendCore ? new FriendGui(friendCore) : nullptr;
	} else return nullptr;
}

int MagicSearchProxy::loadUntil(const QString &address) {
	auto magicSearchList = getListModel<MagicSearchList>();
	if (magicSearchList) {
		auto listIndex = magicSearchList->findFriendIndexByAddress(address);
		if (listIndex != -1) {
			listIndex = dynamic_cast<SortFilterList *>(sourceModel())
			                ->mapFromSource(magicSearchList->index(listIndex, 0))
			                .row();
			if (mMaxDisplayItems <= listIndex) setMaxDisplayItems(listIndex + mDisplayItemsStep);
			return listIndex;
		}
	}
	return -1;
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
	return mList->getSourceFlags();
}

void MagicSearchProxy::setSourceFlags(int flags) {
	mList->setSourceFlags(flags);
}

int MagicSearchProxy::getMaxResults() const {
	return mList->getMaxResults();
}

void MagicSearchProxy::setMaxResults(int flags) {
	mList->setMaxResults(flags);
}

MagicSearchProxy *MagicSearchProxy::getParentProxy() const {
	return mParentProxy;
}

void MagicSearchProxy::setParentProxy(MagicSearchProxy *parentProxy) {
	if (parentProxy && parentProxy->mList) {
		mParentProxy = parentProxy;
		setList(parentProxy->mList);
		emit parentProxyChanged();
	}
}

MagicSearchProxy *MagicSearchProxy::getHideListProxy() const {
	auto list = dynamic_cast<SortFilterList *>(sourceModel());
	return list ? list->mHideListProxy : nullptr;
}

void MagicSearchProxy::setHideListProxy(MagicSearchProxy *hideListProxy) {
	auto list = dynamic_cast<SortFilterList *>(sourceModel());
	if (list && list->mHideListProxy != hideListProxy) {
		if (list->mHideListProxy) list->disconnect(list->mHideListProxy);
		list->mHideListProxy = hideListProxy;
		list->invalidate();
		if (hideListProxy) {
			connect(hideListProxy, &MagicSearchProxy::countChanged, list, [this, list]() { list->invalidateFilter(); });
			connect(hideListProxy, &MagicSearchProxy::modelReset, list, [this, list]() { list->invalidateFilter(); });
		}
		emit hideListProxyChanged();
	}
}

LinphoneEnums::MagicSearchAggregation MagicSearchProxy::getAggregationFlag() const {
	return mList->getAggregationFlag();
}

void MagicSearchProxy::setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag) {
	mList->setAggregationFlag(flag);
}

bool MagicSearchProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto friendCore = getItemAtSource<MagicSearchList, FriendCore>(sourceRow);
	auto toShow = false;
	if (friendCore) {
		if (mFilterType == (int)FilteringTypes::None) return false;
		if ((mFilterType & (int)FilteringTypes::Favorites) > 0) {
			toShow = friendCore->getStarred();
			if (!toShow) return false;
		}
		if ((mFilterType & (int)FilteringTypes::Ldap) > 0) {
			toShow = friendCore->isLdap();
			// if (!toShow) return false;
		}
		if (!toShow && (mFilterType & (int)FilteringTypes::CardDAV) > 0) {
			toShow = friendCore->isCardDAV();
		}
		if (!toShow && (mFilterType & (int)FilteringTypes::App) > 0) {
			toShow = friendCore->getIsStored() && !friendCore->isLdap();
			// if (!toShow) return false;
		}
		if (!toShow && (mFilterType & (int)FilteringTypes::Other) > 0) {
			toShow = !friendCore->getIsStored() && !friendCore->isLdap();
		}

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
		bool lIsStored = l->getIsStored() || l->isLdap() || l->isCardDAV();
		bool rIsStored = r->getIsStored() || r->isLdap() || r->isCardDAV();
		if (lIsStored && !rIsStored) return true;
		else if (!lIsStored && rIsStored) return false;
		auto lName = l->getFullName().toLower();
		auto rName = r->getFullName().toLower();
		return lName < rName;
	}
	return true;
}
