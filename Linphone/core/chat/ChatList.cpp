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
#include "model/tool/ToolModel.hpp"

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

void ChatList::connectItem(QSharedPointer<ChatCore> chat) {
	connect(chat.get(), &ChatCore::deleted, this, [this, chat] {
		remove(chat);
		// We cannot use countChanged here because it is called before mList
		// really has removed the item, then emit specific signal
		emit chatRemoved(chat ? new ChatGui(chat) : nullptr);
	});
	auto dataChange = [this, chat] {
		int i = -1;
		get(chat.get(), &i);
		if (i != -1) {
			auto modelIndex = index(i);
			emit dataChanged(modelIndex, modelIndex);
		}
	};
	connect(chat.get(), &ChatCore::unreadMessagesCountChanged, this, dataChange);
	connect(chat.get(), &ChatCore::lastUpdatedTimeChanged, this, dataChange);
	connect(chat.get(), &ChatCore::lastMessageChanged, this, dataChange);
}

void ChatList::setSelf(QSharedPointer<ChatList> me) {
	mModelConnection = SafeConnection<ChatList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&ChatList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			mustBeInLinphoneThread(getClassName());
			// Avoid copy to lambdas
			QList<QSharedPointer<ChatCore>> *chats = new QList<QSharedPointer<ChatCore>>();
			auto currentAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			if (!currentAccount) return;
			auto linphoneChatRooms = currentAccount->filterChatRooms(Utils::appStringToCoreString(mFilter));
			for (auto it : linphoneChatRooms) {
				auto model = createChatCore(it);
				chats->push_back(model);
			}
			mModelConnection->invokeToCore([this, chats]() {
				for (auto &chat : getSharedList<ChatCore>()) {
					if (chat) {
						disconnect(chat.get(), &ChatCore::deleted, this, nullptr);
						disconnect(chat.get(), &ChatCore::unreadMessagesCountChanged, this, nullptr);
						disconnect(chat.get(), &ChatCore::lastUpdatedTimeChanged, this, nullptr);
						disconnect(chat.get(), &ChatCore::lastMessageChanged, this, nullptr);
					}
				}
				for (auto &chat : *chats) {
					connectItem(chat);
				}
				mustBeInMainThread(getClassName());
                clearData();
                for(auto chat: *chats) {
                    add(chat);
                }
                delete chats;
			});
		});
	});

	mModelConnection->makeConnectToModel(
	    &CoreModel::defaultAccountChanged,
	    [this](std::shared_ptr<linphone::Core> core, std::shared_ptr<linphone::Account> account) { lUpdate(); });
	auto addChatToList = [this](const std::shared_ptr<linphone::Core> &core,
	                            const std::shared_ptr<linphone::ChatRoom> &room,
	                            const std::shared_ptr<linphone::ChatMessage> &message) {
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		auto receiverAccount = ToolModel::findAccount(message->getToAddress());
		if (!receiverAccount) {
			qWarning() << log().arg("Receiver account not found in account list, return");
			return;
		}
		auto receiverAddress = receiverAccount->getContactAddress();
		if (!receiverAddress) {
			qWarning() << log().arg("Receiver account has no address, return");
			return;
		}
		auto defaultAddress = core->getDefaultAccount()->getContactAddress();
		if (!defaultAddress->weakEqual(receiverAddress)) {
			qDebug() << log().arg("Receiver account is not the default one, do not add chat to list");
			return;
		}

		auto chatCore = ChatCore::create(room);
		mModelConnection->invokeToCore([this, chatCore] {
			auto chatList = getSharedList<ChatCore>();
			auto it = std::find_if(chatList.begin(), chatList.end(), [chatCore](const QSharedPointer<ChatCore> item) {
				return item && chatCore && item->getModel() && chatCore->getModel() &&
				       item->getModel()->getMonitor() == chatCore->getModel()->getMonitor();
			});
			if (it == chatList.end()) {
				connectItem(chatCore);
				add(chatCore);
				emit chatAdded();
			}
		});
	};
	mModelConnection->makeConnectToModel(&CoreModel::messageReceived,
	                                     [this, addChatToList](const std::shared_ptr<linphone::Core> &core,
	                                                           const std::shared_ptr<linphone::ChatRoom> &room,
	                                                           const std::shared_ptr<linphone::ChatMessage> &message) {
		                                     addChatToList(core, room, message);
	                                     });
	mModelConnection->makeConnectToModel(
	    &CoreModel::messagesReceived,
	    [this, addChatToList](const std::shared_ptr<linphone::Core> &core,
	                          const std::shared_ptr<linphone::ChatRoom> &room,
	                          const std::list<std::shared_ptr<linphone::ChatMessage>> &messages) {
		    addChatToList(core, room, messages.front());
	    });
	mModelConnection->makeConnectToModel(
	    &CoreModel::newMessageReaction,
	    [this, addChatToList](const std::shared_ptr<linphone::Core> &core,
	                          const std::shared_ptr<linphone::ChatRoom> &room,
	                          const std::shared_ptr<linphone::ChatMessage> &message,
	                          const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) {
		    addChatToList(core, room, message);
	    });

	connect(this, &ChatList::filterChanged, [this](QString filter) {
		mFilter = filter;
		lUpdate();
	});
	lUpdate();
}

int ChatList::findChatIndex(ChatGui *chatGui) {
	if (!chatGui) return -1;
	auto core = chatGui->mCore;
	auto chatList = getSharedList<ChatCore>();
	auto it = std::find_if(chatList.begin(), chatList.end(), [core](const QSharedPointer<ChatCore> item) {
		return item->getIdentifier() == core->getIdentifier();
	});
	return it == chatList.end() ? -1 : std::distance(chatList.begin(), it);
}

void ChatList::addChatInList(ChatGui *chatGui) {
	auto chatCore = chatGui->mCore;
	auto chatList = getSharedList<ChatCore>();
	auto it = std::find_if(chatList.begin(), chatList.end(), [chatCore](const QSharedPointer<ChatCore> item) {
		return item && chatCore && item->getModel() && chatCore->getModel() &&
		       item->getModel()->getMonitor() == chatCore->getModel()->getMonitor();
	});
	if (it == chatList.end()) {
		connectItem(chatCore);
		add(chatCore);
		emit chatAdded();
	}
}

QVariant ChatList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new ChatGui(mList[row].objectCast<ChatCore>()));
	return QVariant();
}
