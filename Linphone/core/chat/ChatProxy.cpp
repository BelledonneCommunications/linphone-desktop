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

#include "ChatProxy.hpp"
#include "ChatGui.hpp"
#include "ChatList.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(ChatProxy)

ChatProxy::ChatProxy(QObject *parent) : LimitProxy(parent) {
	mList = ChatList::create();
	setSourceModel(mList.get());
}

ChatProxy::~ChatProxy() {
}

void ChatProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldChatList = getListModel<ChatList>();
	if (oldChatList) {
		disconnect(oldChatList);
	}
	auto newChatList = dynamic_cast<ChatList *>(model);
	if (newChatList) {
		connect(this, &ChatProxy::filterTextChanged, newChatList,
		        [this, newChatList] { emit newChatList->filterChanged(getFilterText()); });
	}
	setSourceModels(new SortFilterList(model));
	sort(0);
}

int ChatProxy::findChatIndex(ChatGui *chatGui) {
	auto chatList = getListModel<ChatList>();
	if (chatList) {
		auto listIndex = chatList->findChatIndex(chatGui);
		if (listIndex != -1) {
			listIndex =
			    dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(chatList->index(listIndex, 0)).row();
			if (mMaxDisplayItems <= listIndex) setMaxDisplayItems(listIndex + mDisplayItemsStep);
			return listIndex;
		}
	}
	return -1;
}

bool ChatProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	//	auto l = getItemAtSource<ChatList, ChatCore>(sourceRow);
	//	return l != nullptr;
	return true;
}

bool ChatProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<ChatList, ChatCore>(sourceLeft.row());
	auto r = getItemAtSource<ChatList, ChatCore>(sourceRight.row());
	if (l && r) return l->getLastUpdatedTime() >= r->getLastUpdatedTime();
	else return true;
}
