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

#include "ChatMessageProxy.hpp"
#include "ChatMessageGui.hpp"
//#include "core/chat/ChatGui.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(ChatMessageProxy)

ChatMessageProxy::ChatMessageProxy(QObject *parent) : LimitProxy(parent) {
	mList = ChatMessageList::create();
	setSourceModel(mList.get());
}

ChatMessageProxy::~ChatMessageProxy() {
}

void ChatMessageProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldChatMessageList = getListModel<ChatMessageList>();
	if (oldChatMessageList) {
		disconnect(oldChatMessageList);
	}
	auto newChatMessageList = dynamic_cast<ChatMessageList *>(model);
	if (newChatMessageList) {
		connect(newChatMessageList, &ChatMessageList::chatChanged, this, &ChatMessageProxy::chatChanged);
	}
	setSourceModels(new SortFilterList(model));
	sort(0);
}

ChatGui* ChatMessageProxy::getChatGui() {
	auto model = getListModel<ChatMessageList>();
	if (!mChatGui && model) mChatGui = model->getChat();
	return mChatGui;
}

void ChatMessageProxy::setChatGui(ChatGui* chat) {
	getListModel<ChatMessageList>()->setChatGui(chat);
}

bool ChatMessageProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
//	auto l = getItemAtSource<ChatMessageList, ChatMessageCore>(sourceRow);
//	return l != nullptr;
	return true;
}

bool ChatMessageProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<ChatMessageList, ChatMessageCore>(sourceLeft.row());
	auto r = getItemAtSource<ChatMessageList, ChatMessageCore>(sourceRight.row());
	if (l && r) return l->getTimestamp() <= r->getTimestamp();
	else return true;
}
