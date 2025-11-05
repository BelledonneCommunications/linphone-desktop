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

EventLogProxy::EventLogProxy(QObject *parent) : LimitProxy(parent) {
	mList = EventLogList::create();
	setSourceModel(mList.get());
}

EventLogProxy::~EventLogProxy() {
}

void EventLogProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldEventLogList = getListModel<EventLogList>();
	if (oldEventLogList) {
		disconnect(oldEventLogList, &EventLogList::listAboutToBeReset, this, nullptr);
		disconnect(oldEventLogList, &EventLogList::chatGuiChanged, this, nullptr);
		disconnect(oldEventLogList, &EventLogList::displayItemsStepChanged, this, nullptr);
		disconnect(oldEventLogList, &EventLogList::eventInserted, this, nullptr);
		disconnect(oldEventLogList, &EventLogList::messageWithFilterFound, this, nullptr);
	}
	auto newEventLogList = dynamic_cast<EventLogList *>(model);
	if (newEventLogList) {
		connect(newEventLogList, &EventLogList::listAboutToBeReset, this, &EventLogProxy::listAboutToBeReset);
		connect(newEventLogList, &EventLogList::chatGuiChanged, this, &EventLogProxy::chatGuiChanged);
		connect(this, &EventLogProxy::displayItemsStepChanged, newEventLogList,
		        [this, newEventLogList] { newEventLogList->setDisplayItemsStep(mDisplayItemsStep); });
		connect(newEventLogList, &EventLogList::eventInserted, this,
		        [this, newEventLogList](int index, EventLogGui *event) {
			        invalidate();
			        int proxyIndex = -1;
			        if (index != -1) {
				        proxyIndex = dynamic_cast<SortFilterList *>(sourceModel())
				                         ->mapFromSource(newEventLogList->index(index, 0))
				                         .row();
			        }
			        loadUntil(proxyIndex);
			        emit eventInserted(proxyIndex, event);
		        });
		connect(newEventLogList, &EventLogList::messageWithFilterFound, this, [this, newEventLogList](int i) {
			connect(this, &EventLogProxy::layoutChanged, newEventLogList, [this, i, newEventLogList] {
				disconnect(this, &EventLogProxy::layoutChanged, newEventLogList, nullptr);
				auto model = getListModel<EventLogList>();
				int proxyIndex =
				    dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(newEventLogList->index(i, 0)).row();
				if (i != -1) {
					loadUntil(proxyIndex);
				}
				emit indexWithFilterFound(proxyIndex);
			});
			invalidate();
		});
	}
	setSourceModels(new SortFilterList(model, Qt::DescendingOrder));
	sort(0, Qt::DescendingOrder);
}

ChatGui *EventLogProxy::getChatGui() {
	auto model = getListModel<EventLogList>();
	if (!mChatGui && model) mChatGui = model->getChat();
	return mChatGui;
}

void EventLogProxy::setChatGui(ChatGui *chat) {
	getListModel<EventLogList>()->setChatGui(chat);
}

EventLogGui *EventLogProxy::getEventAtIndex(int i) {
	auto eventCore = getEventCoreAtIndex(i);
	return eventCore == nullptr ? nullptr : new EventLogGui(eventCore);
}

QSharedPointer<EventLogCore> EventLogProxy::getEventCoreAtIndex(int i) {
	return getItemAt<SortFilterList, EventLogList, EventLogCore>(i);
}

void EventLogProxy::displayMore() {
	auto model = getListModel<EventLogList>();
	if (model) {
		model->displayMore();
	}
}

void EventLogProxy::loadUntil(int index) {
	auto confInfoList = getListModel<EventLogList>();
	if (mMaxDisplayItems < index) setMaxDisplayItems(index + mDisplayItemsStep);
}

int EventLogProxy::findFirstUnreadIndex() {
	auto eventLogList = getListModel<EventLogList>();
	if (eventLogList) {
		auto listIndex = eventLogList->findFirstUnreadIndex();
		if (listIndex != -1) {
			listIndex =
			    dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(eventLogList->index(listIndex, 0)).row();
			if (mMaxDisplayItems <= listIndex) setMaxDisplayItems(listIndex + mDisplayItemsStep);
			return listIndex;
		} else {
			return 0;
		}
	}
	return 0;
}

void EventLogProxy::markIndexAsRead(int proxyIndex) {
	auto event = getItemAt<SortFilterList, EventLogList, EventLogCore>(proxyIndex);
	if (event && event->getChatMessageCore()) event->getChatMessageCore()->lMarkAsRead();
}

void EventLogProxy::findIndexCorrespondingToFilter(int startIndex, bool forward, bool isFirstResearch) {
	auto filter = getFilterText();
	if (filter.isEmpty()) return;
	auto eventLogList = getListModel<EventLogList>();
	if (eventLogList) {
		auto startEvent = mLastSearchStart;
		if (!startEvent) {
			startEvent = getItemAt<SortFilterList, EventLogList, EventLogCore>(startIndex);
		}
		eventLogList->findChatMessageWithFilter(filter, startEvent, forward, isFirstResearch);
	}
}

bool EventLogProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto l = getItemAtSource<EventLogList, EventLogCore>(sourceRow);
	return l != nullptr;
}

bool EventLogProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<EventLogList, EventLogCore>(sourceLeft.row());
	auto r = getItemAtSource<EventLogList, EventLogCore>(sourceRight.row());
	if (l && r) return l->getTimestamp() < r->getTimestamp();
	return true;
}
