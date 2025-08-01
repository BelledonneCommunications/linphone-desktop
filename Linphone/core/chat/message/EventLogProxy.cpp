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
		disconnect(oldEventLogList);
	}
	auto newEventLogList = dynamic_cast<EventLogList *>(model);
	if (newEventLogList) {
		connect(newEventLogList, &EventLogList::eventChanged, this, &EventLogProxy::eventChanged);
		connect(newEventLogList, &EventLogList::eventInserted, this,
		        [this, newEventLogList](int index, EventLogGui *event) {
			        invalidate();
			        if (index != -1) {
				        index = dynamic_cast<SortFilterList *>(sourceModel())
				                    ->mapFromSource(newEventLogList->index(index, 0))
				                    .row();
				        if (mMaxDisplayItems <= index) setMaxDisplayItems(index + mDisplayItemsStep);
			        }
			        emit eventInserted(index, event);
		        });
	}
	setSourceModels(new SortFilterList(model, Qt::DescendingOrder));
	sort(0);
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
	auto model = getListModel<EventLogList>();
	auto sourceIndex = mapToSource(index(i, 0)).row();
	if (model) {
		auto event = model->getAt<EventLogCore>(sourceIndex);
		if (event) return new EventLogGui(event);
		else return nullptr;
	}
	return nullptr;
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

int EventLogProxy::findIndexCorrespondingToFilter(int startIndex, bool goingBackward) {
	auto filter = getFilterText();
	if (filter.isEmpty()) return startIndex;
	int endIndex = goingBackward ? 0 : getCount() - 1;
	startIndex = goingBackward ? startIndex - 1 : startIndex + 1;
	for (int i = startIndex; (goingBackward ? i >= 0 : i < getCount() - 1); (goingBackward ? --i : ++i)) {
		auto eventLog = getItemAt<SortFilterList, EventLogList, EventLogCore>(i);
		if (!eventLog) continue;
		if (auto message = eventLog->getChatMessageCore()) {
			auto text = message->getText();
			int regexIndex = text.indexOf(filter, 0, Qt::CaseInsensitive);
			if (regexIndex != -1) return i;
		}
	}
	return -1;
}

bool EventLogProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto l = getItemAtSource<EventLogList, EventLogCore>(sourceRow);
	return l != nullptr;
}

bool EventLogProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<EventLogList, EventLogCore>(sourceLeft.row());
	auto r = getItemAtSource<EventLogList, EventLogCore>(sourceRight.row());
	if (l && r) return l->getTimestamp() <= r->getTimestamp();
	else return true;
}
