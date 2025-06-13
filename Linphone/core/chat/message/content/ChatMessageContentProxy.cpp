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

#include "ChatMessageContentProxy.hpp"
#include "ChatMessageContentGui.hpp"
#include "core/App.hpp"
#include "core/chat/message/ChatMessageGui.hpp"

DEFINE_ABSTRACT_OBJECT(ChatMessageContentProxy)

ChatMessageContentProxy::ChatMessageContentProxy(QObject *parent) : LimitProxy(parent) {
	mList = ChatMessageContentList::create();
	setSourceModel(mList.get());
}

ChatMessageContentProxy::~ChatMessageContentProxy() {
}

void ChatMessageContentProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldChatMessageContentList = getListModel<ChatMessageContentList>();
	if (oldChatMessageContentList) {
		// disconnect(oldChatMessageContentList);
	}
	auto newChatMessageContentList = dynamic_cast<ChatMessageContentList *>(model);
	if (newChatMessageContentList) {
		// connect(newChatMessageContentList, &ChatMessageContentList::chatChanged, this,
		// &ChatMessageContentProxy::chatChanged);
	}
	setSourceModels(new SortFilterList(model));
	sort(0);
}

ChatMessageGui *ChatMessageContentProxy::getChatMessageGui() {
	auto model = getListModel<ChatMessageContentList>();
	if (!mChatMessageGui && model) mChatMessageGui = model->getChatMessage();
	return mChatMessageGui;
}

void ChatMessageContentProxy::setChatMessageGui(ChatMessageGui *chat) {
	getListModel<ChatMessageContentList>()->setChatMessageGui(chat);
}

// ChatMessageGui *ChatMessageContentProxy::getChatMessageAtIndex(int i) {
// 	auto model = getListModel<ChatMessageContentList>();
// 	auto sourceIndex = mapToSource(index(i, 0)).row();
// 	if (model) {
// 		auto chat = model->getAt<ChatMessageCore>(sourceIndex);
// 		if (chat) return new ChatMessageGui(chat);
// 		else return nullptr;
// 	}
// 	return nullptr;
// }

void ChatMessageContentProxy::addFiles(const QStringList &paths) {
	auto model = getListModel<ChatMessageContentList>();
	if (model) emit model->lAddFiles(paths);
}

void ChatMessageContentProxy::removeContent(ChatMessageContentGui *contentGui) {
	auto model = getListModel<ChatMessageContentList>();
	if (model && contentGui) model->remove(contentGui->mCore);
}

void ChatMessageContentProxy::clear() {
	auto model = getListModel<ChatMessageContentList>();
	if (model) model->clearData();
}

bool ChatMessageContentProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto contentCore = getItemAtSource<ChatMessageContentList, ChatMessageContentCore>(sourceRow);
	if (contentCore) {
		if (mFilterType == (int)FilterContentType::Unknown) return false;
		else if (mFilterType == (int)FilterContentType::File) {
			return !contentCore->isVoiceRecording() && (contentCore->isFile() || contentCore->isFileTransfer());
		} else if (mFilterType == (int)FilterContentType::Text) return contentCore->isText();
		else if (mFilterType == (int)FilterContentType::Voice) return contentCore->isVoiceRecording();
		else if (mFilterType == (int)FilterContentType::Conference) return contentCore->isCalendar();
		else if (mFilterType == (int)FilterContentType::All) return true;
	}
	return false;
}

bool ChatMessageContentProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft,
                                                       const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<ChatMessageContentList, ChatMessageCore>(sourceLeft.row());
	auto r = getItemAtSource<ChatMessageContentList, ChatMessageCore>(sourceRight.row());
	if (l && r) return l->getTimestamp() <= r->getTimestamp();
	else return true;
}
