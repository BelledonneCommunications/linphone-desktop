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
	if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Basic)) {
		mTitle = ToolModel::getDisplayName(chatRoom->getPeerAddress()->clone());
		mAvatarUri = ToolModel::getDisplayName(chatRoom->getPeerAddress()->clone());
		auto peerAddress = chatRoom->getPeerAddress();
		mPeerAddress = Utils::coreStringToAppString(peerAddress->asStringUriOnly());
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
		} else if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Conference)) {
			mTitle = Utils::coreStringToAppString(chatRoom->getSubject());
			mAvatarUri = Utils::coreStringToAppString(chatRoom->getSubject());
		}
	}
	mUnreadMessagesCount = chatRoom->getUnreadMessagesCount();
	connect(this, &ChatCore::unreadMessagesCountChanged, this, [this] {
		if (mUnreadMessagesCount == 0) emit lMarkAsRead();
	});
	mChatModel = Utils::makeQObject_ptr<ChatModel>(chatRoom);
	mChatModel->setSelf(mChatModel);
	mLastMessageInHistory = mChatModel->getLastMessageInHistory();
	auto history = chatRoom->getHistory(0, (int)linphone::ChatRoom::HistoryFilter::ChatMessage);
	std::list<std::shared_ptr<linphone::ChatMessage>> linHistory;
	for (auto &eventLog : history) {
		if (eventLog->getChatMessage()) linHistory.push_back(eventLog->getChatMessage());
	}
	for (auto &message : linHistory) {
		if (!message) continue;
		auto chatMessage = ChatMessageCore::create(message);
		mChatMessageList.append(chatMessage);
	}
	mIdentifier = Utils::coreStringToAppString(chatRoom->getIdentifier());
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
	mChatModelConnection->makeConnectToModel(&ChatModel::historyDeleted, [this]() {
		mChatModelConnection->invokeToCore([this]() {
			clearMessagesList();
			Utils::showInformationPopup(tr("Supprimé"), tr("L'historique des messages a été supprimé."), true);
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

	mChatModelConnection->makeConnectToModel(&ChatModel::chatMessageReceived,
	                                         [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
		                                         if (mChatModel->getMonitor() != chatRoom) return;
		                                         emit lUpdateLastMessage();
		                                         emit lUpdateUnreadCount();
		                                         emit lUpdateLastUpdatedTime();
		                                         auto message = eventLog->getChatMessage();
		                                         qDebug() << "EVENT LOG RECEIVED IN CHATROOM" << mChatModel->getTitle();
		                                         if (message) {
			                                         auto newMessage = ChatMessageCore::create(message);
			                                         mChatModelConnection->invokeToCore([this, newMessage]() {
				                                         qDebug() << log().arg("append message to chatRoom") << this;
				                                         appendMessageToMessageList(newMessage);
			                                         });
		                                         }
	                                         });
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::chatMessagesReceived, [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                             const std::list<std::shared_ptr<linphone::EventLog>> &chatMessages) {
		    if (mChatModel->getMonitor() != chatRoom) return;
		    emit lUpdateLastMessage();
		    emit lUpdateUnreadCount();
		    emit lUpdateLastUpdatedTime();
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
			    qDebug() << log().arg("append messages to chatRoom") << this;
			    appendMessagesToMessageList(list);
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
		mChatModelConnection->invokeToModel([this]() {
			auto message = mChatModel->getLastMessageInHistory();
			mChatModelConnection->invokeToCore([this, message]() { setLastMessageInHistory(message); });
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lSendTextMessage, [this](QString message) {
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

QString ChatCore::getIdentifier() const {
	return mIdentifier;
}

QString ChatCore::getPeerAddress() const {
	return mPeerAddress;
}

void ChatCore::setPeerAddress(QString peerAddress) {
	if (mPeerAddress != peerAddress) {
		mPeerAddress = peerAddress;
		emit peerAddressChanged(peerAddress);
	}
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

QString ChatCore::getLastMessageInHistory() const {
	return mLastMessageInHistory;
}

void ChatCore::setLastMessageInHistory(QString lastMessageInHistory) {
	if (mLastMessageInHistory != lastMessageInHistory) {
		mLastMessageInHistory = lastMessageInHistory;
		emit lastMessageInHistoryChanged(lastMessageInHistory);
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