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

#include "ChatMessageList.hpp"
#include "ChatMessageCore.hpp"
#include "ChatMessageGui.hpp"
#include "core/App.hpp"
#include "core/chat/ChatCore.hpp"
#include "core/chat/ChatGui.hpp"

#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ChatMessageList)

QSharedPointer<ChatMessageList> ChatMessageList::create() {
	auto model = QSharedPointer<ChatMessageList>(new ChatMessageList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<ChatMessageCore>
ChatMessageList::createChatMessageCore(const std::shared_ptr<linphone::ChatMessage> &chatMessage) {
	auto chatMessageCore = ChatMessageCore::create(chatMessage);
	return chatMessageCore;
}

ChatMessageList::ChatMessageList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ChatMessageList::~ChatMessageList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

ChatGui *ChatMessageList::getChat() const {
	if (mChatCore) return new ChatGui(mChatCore);
	else return nullptr;
}

QSharedPointer<ChatCore> ChatMessageList::getChatCore() const {
	return mChatCore;
}

void ChatMessageList::setChatCore(QSharedPointer<ChatCore> core) {
	if (mChatCore != core) {
		if (mChatCore) disconnect(mChatCore.get(), &ChatCore::messageListChanged, this, nullptr);
		mChatCore = core;
		if (mChatCore) connect(mChatCore.get(), &ChatCore::messageListChanged, this, &ChatMessageList::lUpdate);
		if (mChatCore)
			connect(mChatCore.get(), &ChatCore::messagesInserted, this,
			        [this](QList<QSharedPointer<ChatMessageCore>> list) {
				        auto chatList = getSharedList<ChatMessageCore>();
				        for (auto &message : list) {
					        auto it = std::find_if(
					            chatList.begin(), chatList.end(),
					            [message](const QSharedPointer<ChatMessageCore> item) { return item == message; });
					        if (it == chatList.end()) {
						        add(message);
						        int index;
						        get(message.get(), &index);
						        emit messageInserted(index, new ChatMessageGui(message));
					        }
				        }
			        });
		emit chatChanged();
		lUpdate();
	}
}

void ChatMessageList::setChatGui(ChatGui *chat) {
	auto chatCore = chat ? chat->mCore : nullptr;
	setChatCore(chatCore);
}

int ChatMessageList::findFirstUnreadIndex() {
	auto chatList = getSharedList<ChatMessageCore>();
	auto it = std::find_if(chatList.begin(), chatList.end(),
	                       [](const QSharedPointer<ChatMessageCore> item) { return !item->isRead(); });
	return it == chatList.end() ? -1 : std::distance(chatList.begin(), it);
}

void ChatMessageList::setSelf(QSharedPointer<ChatMessageList> me) {
	mModelConnection = SafeConnection<ChatMessageList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&ChatMessageList::lUpdate, [this]() {
		for (auto &message : getSharedList<ChatMessageCore>()) {
			if (message) disconnect(message.get(), &ChatMessageCore::deleted, this, nullptr);
		}
		if (!mChatCore) return;
		auto messages = mChatCore->getChatMessageList();
		for (auto &message : messages) {
			connect(message.get(), &ChatMessageCore::deleted, this, [this, message] {
				emit mChatCore->lUpdateLastMessage();
				remove(message);
			});
		}
		resetData<ChatMessageCore>(messages);
	});

	connect(this, &ChatMessageList::filterChanged, [this](QString filter) {
		mFilter = filter;
		lUpdate();
	});
	lUpdate();
}

QVariant ChatMessageList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new ChatMessageGui(mList[row].objectCast<ChatMessageCore>()));
	return QVariant();
}
