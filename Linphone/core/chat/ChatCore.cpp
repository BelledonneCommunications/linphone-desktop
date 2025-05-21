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

#include "ChatCore.hpp"
#include "core/App.hpp"
#include "core/friend/FriendCore.hpp"
#include "core/setting/SettingsCore.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ChatCore)

/***********************************************************************/

QSharedPointer<ChatCore> ChatCore::create(const std::shared_ptr<linphone::ChatRoom> &chatRoom) {
	auto sharedPointer = QSharedPointer<ChatCore>(new ChatCore(chatRoom), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ChatCore::ChatCore(const std::shared_ptr<linphone::ChatRoom> &chatRoom) : QObject(nullptr) {
	lDebug() << "[ChatCore] new" << this;
	mustBeInLinphoneThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mLastUpdatedTime = QDateTime::fromSecsSinceEpoch(chatRoom->getLastUpdateTime());
	auto chatRoomAddress = chatRoom->getPeerAddress()->clone();
	chatRoomAddress->clean();
	mChatRoomAddress = Utils::coreStringToAppString(chatRoomAddress->asStringUriOnly());
	if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Basic)) {
		mTitle = ToolModel::getDisplayName(chatRoomAddress);
		mAvatarUri = ToolModel::getDisplayName(chatRoomAddress);
		mPeerAddress = Utils::coreStringToAppString(chatRoomAddress->asStringUriOnly());
		mIsGroupChat = false;
	} else {
		if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::OneToOne)) {
			auto participants = chatRoom->getParticipants();
			if (participants.size() > 0) {
				auto peer = participants.front();
				if (peer) mTitle = ToolModel::getDisplayName(peer->getAddress()->clone());
				mAvatarUri = ToolModel::getDisplayName(peer->getAddress()->clone());
				if (participants.size() == 1) {
					auto peerAddress = peer->getAddress();
					if (peerAddress) mPeerAddress = Utils::coreStringToAppString(peerAddress->asStringUriOnly());
				}
			}
			mIsGroupChat = false;
		} else if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Conference)) {
			mTitle = Utils::coreStringToAppString(chatRoom->getSubject());
			mAvatarUri = Utils::coreStringToAppString(chatRoom->getSubject());
			mIsGroupChat = true;
		}
	}
	mUnreadMessagesCount = chatRoom->getUnreadMessagesCount();
	connect(this, &ChatCore::unreadMessagesCountChanged, this, [this] {
		if (mUnreadMessagesCount == 0) emit lMarkAsRead();
	});
	mChatModel = Utils::makeQObject_ptr<ChatModel>(chatRoom);
	mChatModel->setSelf(mChatModel);
	auto lastMessage = chatRoom->getLastMessageInHistory();
	mLastMessage = lastMessage ? ChatMessageCore::create(lastMessage) : nullptr;
	auto history = chatRoom->getHistory(0, (int)linphone::ChatRoom::HistoryFilter::ChatMessage);
	std::list<std::shared_ptr<linphone::ChatMessage>> lHistory;
	for (auto &eventLog : history) {
		if (eventLog->getChatMessage()) lHistory.push_back(eventLog->getChatMessage());
	}
	QList<QSharedPointer<ChatMessageCore>> messageList;
	for (auto &message : lHistory) {
		if (!message) continue;
		auto chatMessage = ChatMessageCore::create(message);
		messageList.append(chatMessage);
	}
	resetChatMessageList(messageList);
	mIdentifier = Utils::coreStringToAppString(chatRoom->getIdentifier());
	mChatRoomState = LinphoneEnums::fromLinphone(chatRoom->getState());
	mIsEncrypted = chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Encrypted);
	mIsReadOnly = chatRoom->isReadOnly();
	connect(this, &ChatCore::messageListChanged, this, &ChatCore::lUpdateLastMessage);
	connect(this, &ChatCore::messagesInserted, this, &ChatCore::lUpdateLastMessage);
	connect(this, &ChatCore::messageRemoved, this, &ChatCore::lUpdateLastMessage);
}

ChatCore::~ChatCore() {
	lDebug() << "[ChatCore] delete" << this;
	mustBeInMainThread("~" + getClassName());
	emit mChatModel->removeListener();
}

void ChatCore::setSelf(QSharedPointer<ChatCore> me) {
	mChatModelConnection = SafeConnection<ChatCore, ChatModel>::create(me, mChatModel);
	mChatModelConnection->makeConnectToCore(&ChatCore::lDeleteHistory, [this]() {
		mChatModelConnection->invokeToModel([this]() { mChatModel->deleteHistory(); });
	});
	mChatModelConnection->makeConnectToCore(
	    &ChatCore::lLeave, [this]() { mChatModelConnection->invokeToModel([this]() { mChatModel->leave(); }); });
	mChatModelConnection->makeConnectToModel(&ChatModel::historyDeleted, [this]() {
		mChatModelConnection->invokeToCore([this]() {
			clearMessagesList();
			//: Deleted
			Utils::showInformationPopup(tr("info_toast_deleted_title"),
			                            //: Message history has been deleted
			                            tr("info_toast_deleted_message_history"), true);
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lUpdateUnreadCount, [this]() {
		mChatModelConnection->invokeToModel([this]() {
			auto count = mChatModel->getUnreadMessagesCount();
			mChatModelConnection->invokeToCore([this, count] { setUnreadMessagesCount(count); });
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lUpdateLastUpdatedTime, [this]() {
		mChatModelConnection->invokeToModel([this]() {
			auto time = mChatModel->getLastUpdateTime();
			mChatModelConnection->invokeToCore([this, time]() { setLastUpdatedTime(time); });
		});
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lDelete, [this]() {
		mChatModelConnection->invokeToModel([this]() { mChatModel->deleteChatRoom(); });
	});
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::deleted, [this]() { mChatModelConnection->invokeToCore([this]() { emit deleted(); }); });
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::stateChanged,
	    [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom, linphone::ChatRoom::State newState) {
		    auto state = LinphoneEnums::fromLinphone(newState);
		    bool isReadOnly = chatRoom->isReadOnly();
		    mChatModelConnection->invokeToCore([this, state, isReadOnly]() {
			    setChatRoomState(state);
			    setIsReadOnly(isReadOnly);
		    });
	    });

	mChatModelConnection->makeConnectToModel(&ChatModel::chatMessageReceived,
	                                         [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
		                                         if (mChatModel->getMonitor() != chatRoom) return;
		                                         auto message = eventLog->getChatMessage();
		                                         qDebug() << "EVENT LOG RECEIVED IN CHATROOM" << mChatModel->getTitle();
		                                         if (message) {
			                                         auto newMessage = ChatMessageCore::create(message);
			                                         mChatModelConnection->invokeToCore([this, newMessage]() {
				                                         appendMessageToMessageList(newMessage);
				                                         emit lUpdateUnreadCount();
				                                         emit lUpdateLastUpdatedTime();
			                                         });
		                                         }
	                                         });
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::chatMessagesReceived, [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                             const std::list<std::shared_ptr<linphone::EventLog>> &chatMessages) {
		    if (mChatModel->getMonitor() != chatRoom) return;
		    qDebug() << "EVENT LOGS RECEIVED IN CHATROOM" << mChatModel->getTitle();
		    QList<QSharedPointer<ChatMessageCore>> list;
		    for (auto &m : chatMessages) {
			    auto message = m->getChatMessage();
			    if (message) {
				    auto newMessage = ChatMessageCore::create(message);
				    list.push_back(newMessage);
			    }
		    }
		    mChatModelConnection->invokeToCore([this, list]() {
			    appendMessagesToMessageList(list);
			    emit lUpdateUnreadCount();
			    emit lUpdateLastUpdatedTime();
		    });
	    });

	mChatModelConnection->makeConnectToCore(&ChatCore::lMarkAsRead, [this]() {
		mChatModelConnection->invokeToModel([this]() { mChatModel->markAsRead(); });
	});
	mChatModelConnection->makeConnectToModel(&ChatModel::messagesRead, [this]() {
		auto unread = mChatModel->getUnreadMessagesCount();
		mChatModelConnection->invokeToCore([this, unread]() { setUnreadMessagesCount(unread); });
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lUpdateLastMessage, [this]() {
		auto lastMessageModel = mLastMessage ? mLastMessage->getModel() : nullptr;
		mChatModelConnection->invokeToModel([this, lastMessageModel]() {
			auto linphoneMessage = mChatModel->getLastChatMessage();
			if (!lastMessageModel || lastMessageModel->getMonitor() != linphoneMessage) {
				auto chatMessageCore = ChatMessageCore::create(linphoneMessage);
				mChatModelConnection->invokeToCore([this, chatMessageCore]() { setLastMessage(chatMessageCore); });
			}
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lSendTextMessage, [this](QString message) {
		if (Utils::isEmptyMessage(message)) return;
		mChatModelConnection->invokeToModel([this, message]() {
			auto linMessage = mChatModel->createTextMessageFromText(message);
			linMessage->send();
		});
	});
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::chatMessageSending, [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                           const std::shared_ptr<const linphone::EventLog> &eventLog) {
		    auto message = eventLog->getChatMessage();
		    if (message) {
			    auto newMessage = ChatMessageCore::create(message);
			    mChatModelConnection->invokeToCore([this, newMessage]() { appendMessageToMessageList(newMessage); });
		    }
	    });
	mChatModelConnection->makeConnectToCore(
	    &ChatCore::lCompose, [this]() { mChatModelConnection->invokeToModel([this]() { mChatModel->compose(); }); });
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::isComposingReceived,
	    [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	           const std::shared_ptr<const linphone::Address> &remoteAddress, bool isComposing) {
		    if (mChatModel->getMonitor() != chatRoom) return;
		    QString name = isComposing ? ToolModel::getDisplayName(remoteAddress->clone()) : QString();
		    auto remoteAddr = remoteAddress->clone();
		    remoteAddr->clean();
		    mChatModelConnection->invokeToCore(
		        [this, name, address = Utils::coreStringToAppString(remoteAddr->asStringUriOnly())]() {
			        setComposingName(name);
			        setComposingAddress(address);
		        });
	    });
}

QDateTime ChatCore::getLastUpdatedTime() const {
	return mLastUpdatedTime;
}

void ChatCore::setLastUpdatedTime(QDateTime time) {
	if (mLastUpdatedTime != time) {
		mLastUpdatedTime = time;
		emit lastUpdatedTimeChanged(time);
	}
}

QString ChatCore::getTitle() const {
	return mTitle;
}

void ChatCore::setTitle(QString title) {
	if (mTitle != title) {
		mTitle = title;
		emit titleChanged(title);
	}
}

bool ChatCore::isGroupChat() const {
	return mIsGroupChat;
}

bool ChatCore::isEncrypted() const {
	return mIsEncrypted;
}

QString ChatCore::getIdentifier() const {
	return mIdentifier;
}

QString ChatCore::getPeerAddress() const {
	return mPeerAddress;
}

QString ChatCore::getChatRoomAddress() const {
	return mChatRoomAddress;
}

QString ChatCore::getAvatarUri() const {
	return mAvatarUri;
}

void ChatCore::setAvatarUri(QString avatarUri) {
	if (mAvatarUri != avatarUri) {
		mAvatarUri = avatarUri;
		emit avatarUriChanged();
	}
}

QString ChatCore::getLastMessageText() const {
	return mLastMessage ? mLastMessage->getText() : QString();
}

LinphoneEnums::ChatMessageState ChatCore::getLastMessageState() const {
	return mLastMessage ? mLastMessage->getMessageState() : LinphoneEnums::ChatMessageState::StateIdle;
}

LinphoneEnums::ChatRoomState ChatCore::getChatRoomState() const {
	return mChatRoomState;
}

void ChatCore::setChatRoomState(LinphoneEnums::ChatRoomState state) {
	if (mChatRoomState != state) {
		mChatRoomState = state;
		emit chatRoomStateChanged();
	}
}

void ChatCore::setIsReadOnly(bool readOnly) {
	if (mIsReadOnly != readOnly) {
		mIsReadOnly = readOnly;
		emit readOnlyChanged();
	}
}

bool ChatCore::getIsReadOnly() const {
	return mIsReadOnly;
}

ChatMessageGui *ChatCore::getLastMessage() const {
	return mLastMessage ? new ChatMessageGui(mLastMessage) : nullptr;
}

QSharedPointer<ChatMessageCore> ChatCore::getLastMessageCore() const {
	return mLastMessage;
}

void ChatCore::setLastMessage(QSharedPointer<ChatMessageCore> lastMessage) {
	if (mLastMessage != lastMessage) {
		disconnect(mLastMessage.get());
		mLastMessage = lastMessage;
		connect(mLastMessage.get(), &ChatMessageCore::messageStateChanged, this, &ChatCore::lastMessageChanged);
		emit lastMessageChanged();
	}
}

int ChatCore::getUnreadMessagesCount() const {
	return mUnreadMessagesCount;
}

void ChatCore::setUnreadMessagesCount(int count) {
	if (mUnreadMessagesCount != count) {
		mUnreadMessagesCount = count;
		emit unreadMessagesCountChanged(count);
	}
}

QList<QSharedPointer<ChatMessageCore>> ChatCore::getChatMessageList() const {
	return mChatMessageList;
}

void ChatCore::resetChatMessageList(QList<QSharedPointer<ChatMessageCore>> list) {
	mChatMessageList = list;
	emit messageListChanged();
}

void ChatCore::appendMessagesToMessageList(QList<QSharedPointer<ChatMessageCore>> list) {
	int nbAdded = 0;
	for (auto &message : list) {
		if (mChatMessageList.contains(message)) continue;
		mChatMessageList.append(message);
		++nbAdded;
	}
	if (nbAdded > 0) emit messagesInserted(list);
}

void ChatCore::appendMessageToMessageList(QSharedPointer<ChatMessageCore> message) {
	if (mChatMessageList.contains(message)) return;
	mChatMessageList.append(message);
	emit messagesInserted({message});
}

void ChatCore::removeMessagesFromMessageList(QList<QSharedPointer<ChatMessageCore>> list) {
	int nbRemoved = 0;
	for (auto &message : list) {
		if (mChatMessageList.contains(message)) {
			mChatMessageList.removeAll(message);
			++nbRemoved;
		}
	}
	if (nbRemoved > 0) emit messageRemoved();
}

void ChatCore::clearMessagesList() {
	mChatMessageList.clear();
	emit messageListChanged();
}

QString ChatCore::getComposingName() const {
	return mComposingName;
}

void ChatCore::setComposingName(QString composingName) {
	if (mComposingAddress != composingName) {
		mComposingName = composingName;
		emit composingUserChanged();
	}
}

void ChatCore::setComposingAddress(QString composingAddress) {
	if (mComposingAddress != composingAddress) {
		mComposingAddress = composingAddress;
		emit composingUserChanged();
	}
}

QString ChatCore::getComposingAddress() const {
	return mComposingAddress;
}

std::shared_ptr<ChatModel> ChatCore::getModel() const {
	return mChatModel;
}
