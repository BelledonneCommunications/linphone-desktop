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

ChatProxy::ChatProxy(QObject *parent) {
	mList = ChatList::create();
	setSourceModel(mList.get());
	setDynamicSortFilter(true);
}

ChatProxy::~ChatProxy() {
}

void ChatProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldChatList = dynamic_cast<ChatList *>(sourceModel());
	if (oldChatList) {
		disconnect(this, &ChatProxy::filterTextChanged, oldChatList, nullptr);
		disconnect(oldChatList, &ChatList::chatAdded, this, nullptr);
		disconnect(oldChatList, &ChatList::dataChanged, this, nullptr);
	}
	auto newChatList = dynamic_cast<ChatList *>(model);
	if (newChatList) {
		connect(this, &ChatProxy::filterTextChanged, newChatList,
		        [this, newChatList] { emit newChatList->filterChanged(getFilterText()); });
		connect(newChatList, &ChatList::chatAdded, this, [this] { invalidate(); });
		connect(newChatList, &ChatList::chatCreated, this, [this](ChatGui *chatGui) {
			invalidate();
			emit chatCreated(chatGui);
		});
		connect(newChatList, &ChatList::dataChanged, this, [this] { invalidate(); });
	}
	QSortFilterProxyModel::setSourceModel(newChatList);
	sort(0);
}

int ChatProxy::findChatIndex(ChatGui *chatGui) {
	auto chatList = dynamic_cast<ChatList *>(sourceModel());
	if (chatList) {
		auto listIndex = chatList->findChatIndex(chatGui);
		if (listIndex != -1) {
			listIndex = mapFromSource(chatList->index(listIndex, 0)).row();
			return listIndex;
		}
	}
	return -1;
}

void ChatProxy::addChatInList(ChatGui *chatGui) {
	auto chatList = dynamic_cast<ChatList *>(sourceModel());
	if (chatList && chatGui) {
		chatList->addChatInList(chatGui->mCore);
	}
}

bool ChatProxy::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	if (!mFilterText.isEmpty()) return false;
	auto l = getItemAtSource<ChatList, ChatCore>(sourceLeft.row());
	auto r = getItemAtSource<ChatList, ChatCore>(sourceRight.row());
	if (l && r) return l->getLastUpdatedTime() > r->getLastUpdatedTime();
	return false;
}
