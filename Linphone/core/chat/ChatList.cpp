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

#include "ChatList.hpp"
#include "ChatCore.hpp"
#include "ChatGui.hpp"
#include "core/App.hpp"

#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ChatList)

QSharedPointer<ChatList> ChatList::create() {
	auto model = QSharedPointer<ChatList>(new ChatList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<ChatCore> ChatList::createChatCore(const std::shared_ptr<linphone::ChatRoom> &chatroom) {
	auto chatCore = ChatCore::create(chatroom);
	return chatCore;
}

ChatList::ChatList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ChatList::~ChatList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

void ChatList::setSelf(QSharedPointer<ChatList> me) {
	mModelConnection = SafeConnection<ChatList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&ChatList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			mustBeInLinphoneThread(getClassName());
			// Avoid copy to lambdas
			QList<QSharedPointer<ChatCore>> *chats = new QList<QSharedPointer<ChatCore>>();
			auto currentAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
//			auto linphoneChatRooms = currentAccount->filterChatRooms(Utils::appStringToCoreString(mFilter));
			auto linphoneChatRooms = currentAccount->getChatRooms();
			for (auto it : linphoneChatRooms) {
				auto model = createChatCore(it);
				chats->push_back(model);
			}
			mModelConnection->invokeToCore([this, chats]() {
				mustBeInMainThread(getClassName());
				resetData<ChatCore>(*chats);
				delete chats;
			});
		});
	});

	mModelConnection->makeConnectToModel(&CoreModel::chatRoomStateChanged,
	                                     [this](const std::shared_ptr<linphone::Core> &core,
	                                            const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                            linphone::ChatRoom::State state) {
		                                     // check account, filtre, puis ajout si c'est bon
		                                     bool toCreate = false;
		                                     if (toCreate) {
			                                     auto model = createChatCore(chatRoom);
			                                     mModelConnection->invokeToCore([this, model]() {
				                                     // We set the current here and not on firstChatStarted event
				                                     // because we don't want to add unicity check while keeping the
				                                     // same model between list and current chat.
				                                     add(model);
			                                     });
		                                     }
	                                     });
	mModelConnection->makeConnectToModel(&CoreModel::defaultAccountChanged, [this] (std::shared_ptr<linphone::Core> core, std::shared_ptr<linphone::Account> account) {
		lUpdate();
	});

	connect(this, &ChatList::filterChanged, [this](QString filter) {
		mFilter = filter;
		lUpdate();
	});
	lUpdate();
}

QVariant ChatList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new ChatGui(mList[row].objectCast<ChatCore>()));
	return QVariant();
}
