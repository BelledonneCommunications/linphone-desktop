/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "ConferenceInfoProxy.hpp"
#include "ConferenceInfoCore.hpp"
#include "ConferenceInfoGui.hpp"
#include "ConferenceInfoList.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceInfoProxy)

ConferenceInfoProxy::ConferenceInfoProxy(QObject *parent) : LimitProxy(parent) {
	mList = ConferenceInfoList::create();
	setSourceModels(new SortFilterList(mList.get(), Qt::AscendingOrder));
	connect(
	    mList.get(), &ConferenceInfoList::haveCurrentDateChanged, this,
	    [this] {
		    auto sortModel = dynamic_cast<SortFilterList *>(sourceModel());
		    sortModel->invalidate(); // New date => sort and filter change.
		    loadUntil(nullptr);
	    },
	    Qt::QueuedConnection);
	connect(
	    mList.get(), &ConferenceInfoList::confInfoInserted, this,
	    [this](QSharedPointer<ConferenceInfoCore> data) {
		    auto sortModel = dynamic_cast<SortFilterList *>(sourceModel());
		    sortModel->invalidate(); // New conf => sort change. Filter can change if on current date.
		    static const QMetaMethod conferenceInfoCreatedSignal =
		        QMetaMethod::fromSignal(&ConferenceInfoProxy::conferenceInfoCreated);
		    if (isSignalConnected(conferenceInfoCreatedSignal)) emit conferenceInfoCreated(new ConferenceInfoGui(data));
	    },
	    Qt::QueuedConnection);
	// When the date of a conference is being modified, it can be moved at another index,
	// so we need to find this new index to select the right conference info
	connect(
	    mList.get(), &ConferenceInfoList::confInfoUpdated, this,
	    [this](QSharedPointer<ConferenceInfoCore> data) {
		    static const QMetaMethod conferenceInfoUpdatedSignal =
		        QMetaMethod::fromSignal(&ConferenceInfoProxy::conferenceInfoUpdated);
		    if (isSignalConnected(conferenceInfoUpdatedSignal)) emit conferenceInfoUpdated(new ConferenceInfoGui(data));
	    },
	    Qt::QueuedConnection);
	connect(mList.get(), &ConferenceInfoList::initialized, this, &ConferenceInfoProxy::initialized);
}

ConferenceInfoProxy::~ConferenceInfoProxy() {
}

bool ConferenceInfoProxy::haveCurrentDate() const {
	return mList->haveCurrentDate();
}

bool ConferenceInfoProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto list = qobject_cast<ConferenceInfoList *>(sourceModel());
	auto ciCore = list->getAt<ConferenceInfoCore>(sourceRow);
	if (ciCore) {
		bool searchTextInSubject = false;
		bool searchTextInParticipant = false;
		if (ciCore->getSubject().contains(mFilterText, Qt::CaseInsensitive)) searchTextInSubject = true;
		for (auto &contact : ciCore->getParticipants()) {
			auto infos = contact.toMap();
			if (infos["displayName"].toString().contains(mFilterText, Qt::CaseInsensitive)) {
				searchTextInParticipant = true;
				break;
			}
		}
		if (!searchTextInSubject && !searchTextInParticipant) return false;
		QDateTime currentDateTime = QDateTime::currentDateTimeUtc();
		if (mFilterType == int(ConferenceInfoProxy::ConferenceInfoFiltering::None)) {
			return true;
		} else if (mFilterType == int(ConferenceInfoProxy::ConferenceInfoFiltering::Future)) {
			auto res = ciCore->getEndDateTimeUtc() >= currentDateTime;
			return res;
		} else return mFilterType == -1;
	} else {
		// if mlist count == 1 there is only the dummy row which we don't display alone
		return !list->haveCurrentDate() && list->getCount() > 1 && mFilterText.isEmpty();
	}
}

void ConferenceInfoProxy::clear() {
	mList->clearData();
}

int ConferenceInfoProxy::loadUntil(ConferenceInfoGui *confInfo) {
	return loadUntil(confInfo ? confInfo->mCore : nullptr);
}

int ConferenceInfoProxy::loadUntil(QSharedPointer<ConferenceInfoCore> data) {
	auto confInfoList = getListModel<ConferenceInfoList>();
	if (confInfoList) {
		int listIndex = -1;
		// Get list index.
		if (!data) listIndex = confInfoList->getCurrentDateIndex();
		else confInfoList->get(data.get(), &listIndex);
		if (listIndex == -1) return -1;
		// Get the index inside sorted/filtered list.
		auto listModelIndex =
		    dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(confInfoList->index(listIndex, 0));
		// Load enough items into LimitProxy.
		if (mMaxDisplayItems < listModelIndex.row()) setMaxDisplayItems(listModelIndex.row() + mDisplayItemsStep);
		// Get the new index inside sorted/filtered list.
		listModelIndex =
		    dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(confInfoList->index(listIndex, 0));
		// Get the index inside LimitProxy.
		listIndex = mapFromSource(listModelIndex).row();
		return listIndex;
	}
	return -1;
}

bool ConferenceInfoProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft,
                                                   const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<ConferenceInfoList, ConferenceInfoCore>(sourceLeft.row());
	auto r = getItemAtSource<ConferenceInfoList, ConferenceInfoCore>(sourceRight.row());
	if (!l && !r) {
		return true;
	}
	auto nowDate = QDate::currentDate();
	if (!l || !r) { // sort on date
		auto rdate = r ? r->getDateTimeUtc().date() : QDate::currentDate();
		return !l ? nowDate <= r->getDateTimeUtc().date() : l->getDateTimeUtc().date() < nowDate;
	} else {
		return l->getDateTimeUtc() < r->getDateTimeUtc();
	}
}
