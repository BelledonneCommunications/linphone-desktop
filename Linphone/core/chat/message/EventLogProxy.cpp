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

#include "EventLogProxy.hpp"
#include "EventLogGui.hpp"
#include "EventLogList.hpp"
// #include "core/chat/ChatGui.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(EventLogProxy)

EventLogProxy::EventLogProxy(QObject *parent) : QSortFilterProxyModel(parent) {
	mList = EventLogList::create();
	setSourceModel(mList.get());
}

EventLogProxy::~EventLogProxy() {
}

void EventLogProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldEventLogList = dynamic_cast<EventLogList *>(sourceModel());
	if (oldEventLogList) {
		disconnect(oldEventLogList, &EventLogList::displayItemsStepChanged, this, nullptr);
		disconnect(oldEventLogList, &EventLogList::messageWithFilterFound, this, nullptr);
		disconnect(oldEventLogList, &EventLogList::eventInsertedByUser, this, nullptr);
	}
	auto newEventLogList = dynamic_cast<EventLogList *>(model);
	if (newEventLogList) {
		connect(this, &EventLogProxy::displayItemsStepChanged, newEventLogList,
		        [this, newEventLogList] { newEventLogList->setDisplayItemsStep(mDisplayItemsStep); });
		connect(newEventLogList, &EventLogList::messageWithFilterFound, this, [this, newEventLogList](int i) {
			auto model = dynamic_cast<EventLogList *>(sourceModel());
			int proxyIndex = mapFromSource(newEventLogList->index(i, 0)).row();
			if (i != -1) {
				loadUntil(proxyIndex);
			}
			emit indexWithFilterFound(proxyIndex);
		});
		connect(newEventLogList, &EventLogList::eventInsertedByUser, this, [this, newEventLogList](int i) {
			int proxyIndex = mapFromSource(newEventLogList->index(i, 0)).row();
			emit eventInsertedByUser(proxyIndex);
		});
	}
	QSortFilterProxyModel::setSourceModel(model);
}

ChatGui *EventLogProxy::getChatGui() {
	auto model = dynamic_cast<EventLogList *>(sourceModel());
	if (!mChatGui && model) mChatGui = model->getChat();
	return mChatGui;
}

void EventLogProxy::setChatGui(ChatGui *chat) {
	auto model = dynamic_cast<EventLogList *>(sourceModel());
	if (model) model->setChatGui(chat);
}

EventLogGui *EventLogProxy::getEventAtIndex(int i) {
	auto eventCore = getEventCoreAtIndex(i);
	return eventCore == nullptr ? nullptr : new EventLogGui(eventCore);
}

int EventLogProxy::getCount() const {
	return rowCount();
}

int EventLogProxy::getInitialDisplayItems() const {
	return mInitialDisplayItems;
}

void EventLogProxy::setInitialDisplayItems(int initialItems) {
	if (mInitialDisplayItems != initialItems) {
		mInitialDisplayItems = initialItems;
		if (getMaxDisplayItems() <= mInitialDisplayItems) setMaxDisplayItems(initialItems);
		if (getDisplayItemsStep() <= 0) setDisplayItemsStep(initialItems);
		emit initialDisplayItemsChanged();
	}
}

int EventLogProxy::getDisplayCount(int listCount, int maxCount) {
	return maxCount >= 0 ? qMin(listCount, maxCount) : listCount;
}

int EventLogProxy::getDisplayCount(int listCount) const {
	return getDisplayCount(listCount, mMaxDisplayItems);
}

QSharedPointer<EventLogCore> EventLogProxy::getEventCoreAtIndex(int i) {
	auto model = dynamic_cast<EventLogList *>(sourceModel());
	if (model) {
		return model->getAt<EventLogCore>(mapToSource(index(i, 0)).row());
	}
	return nullptr;
}

void EventLogProxy::displayMore() {
	auto model = dynamic_cast<EventLogList *>(sourceModel());
	if (model) {
		model->displayMore();
	}
}
int EventLogProxy::getMaxDisplayItems() const {
	return mMaxDisplayItems;
}

void EventLogProxy::setMaxDisplayItems(int maxItems) {
	if (mMaxDisplayItems != maxItems) {
		auto model = sourceModel();
		int modelCount = model ? model->rowCount() : 0;
		int oldCount = getDisplayCount(modelCount);
		mMaxDisplayItems = maxItems;
		if (getInitialDisplayItems() > mMaxDisplayItems) setInitialDisplayItems(maxItems);
		if (getDisplayItemsStep() <= 0) setDisplayItemsStep(maxItems);
		emit maxDisplayItemsChanged();

		if (model && getDisplayCount(modelCount) != oldCount) {
			invalidate();
		}
	}
}

int EventLogProxy::getDisplayItemsStep() const {
	return mDisplayItemsStep;
}

void EventLogProxy::setDisplayItemsStep(int step) {
	if (step > 0 && mDisplayItemsStep != step) {
		mDisplayItemsStep = step;
		emit displayItemsStepChanged();
	}
}

void EventLogProxy::loadUntil(int index) {
	if (mMaxDisplayItems < index) setMaxDisplayItems(index + mDisplayItemsStep);
}

int EventLogProxy::findFirstUnreadIndex() {
	auto eventLogList = dynamic_cast<EventLogList *>(sourceModel());
	if (eventLogList) {
		auto listIndex = eventLogList->findFirstUnreadIndex();
		if (listIndex != -1) {
			listIndex = mapFromSource(eventLogList->index(listIndex, 0)).row();
			if (mMaxDisplayItems <= listIndex) setMaxDisplayItems(listIndex + mDisplayItemsStep);
			return listIndex;
		} else {
			return 0;
		}
	}
	return 0;
}

QString EventLogProxy::getFilterText() const {
	return mFilterText;
}

void EventLogProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
#if QT_VERSION >= QT_VERSION_CHECK(6, 10, 0)
		beginFilterChange();
		mFilterText = filter;
		endFilterChange();
#else
		mFilterText = filter;
		invalidateFilter();
#endif
		emit filterTextChanged();
	}
}

QSharedPointer<EventLogCore> EventLogProxy::getAt(int atIndex) const {
	auto model = dynamic_cast<EventLogList *>(sourceModel());
	if (model) {
		return model->getAt<EventLogCore>(mapToSource(index(atIndex, 0)).row());
	}
	return nullptr;
}

void EventLogProxy::markIndexAsRead(int proxyIndex) {
	auto event = getAt(proxyIndex);
	if (event && event->getChatMessageCore()) event->getChatMessageCore()->lMarkAsRead();
}

void EventLogProxy::findIndexCorrespondingToFilter(int startIndex, bool forward, bool isFirstResearch) {
	auto filter = getFilterText();
	if (filter.isEmpty()) return;
	auto eventLogList = dynamic_cast<EventLogList *>(sourceModel());
	if (eventLogList) {
		auto listIndex = mapToSource(index(startIndex, 0)).row();
		eventLogList->findChatMessageWithFilter(filter, listIndex, forward, isFirstResearch);
	}
}