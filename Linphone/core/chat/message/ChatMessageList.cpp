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
#include "core/chat/ChatCore.hpp"
#include "core/chat/ChatGui.hpp"
#include "core/App.hpp"

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

QSharedPointer<ChatMessageCore> ChatMessageList::createChatMessageCore(const std::shared_ptr<linphone::ChatMessage> &chatMessage) {
	auto chatMessageCore = ChatMessageCore::create(chatMessage);
	return chatMessageCore;
}

ChatMessageList::ChatMessageList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	connect(this, &ChatMessageList::chatChanged, this, &ChatMessageList::lUpdate);
}

ChatMessageList::~ChatMessageList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

ChatGui* ChatMessageList::getChat() const {
	if (mChatCore) return new ChatGui(mChatCore);
	else return nullptr;
}

QSharedPointer<ChatCore> ChatMessageList::getChatCore() const {
	return mChatCore;
}

void ChatMessageList::setChatCore(QSharedPointer<ChatCore> core) {
	if (mChatCore != core) {
		mChatCore = core;
		emit chatChanged();
	}
}

void ChatMessageList::setChatGui(ChatGui* chat) {
	auto chatCore = chat ? chat->mCore : nullptr;
	setChatCore(chatCore);
}

void ChatMessageList::setSelf(QSharedPointer<ChatMessageList> me) {
	mModelConnection = SafeConnection<ChatMessageList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&ChatMessageList::lUpdate, [this]() {
//		mModelConnection->invokeToModel([this]() {
//			// Avoid copy to lambdas
//			QList<QSharedPointer<CallCore>> *calls = new QList<QSharedPointer<CallCore>>();
//			mustBeInLinphoneThread(getClassName());
//			mModelConnection->invokeToCore([this, calls, currentCallCore]() {
//				mustBeInMainThread(getClassName());
//				resetData<CallCore>(*calls);
//			});
//		});
		if (!mChatCore) return;
		auto messages = mChatCore->getChatMessageList();
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
	if (role == Qt::DisplayRole) return QVariant::fromValue(new ChatMessageGui(mList[row].objectCast<ChatMessageCore>()));
	return QVariant();
}
