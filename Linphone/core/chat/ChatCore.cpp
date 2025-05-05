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
	// mChatModelConnection->makeConnectToCore(&ChatCore::lSetMicrophoneMuted, [this](bool isMuted) {
	// 	mChatModelConnection->invokeToModel(
	// 	    [this, isMuted]() { mChatModel->setMicrophoneMuted(isMuted); });
	// });
	mChatModelConnection->makeConnectToModel(&ChatModel::chatMessageReceived,
	                                         [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
		                                         if (mChatModel->getMonitor() != chatRoom) return;
		                                         qDebug() << "MESSAGE RECEIVED IN CHATROOM" << mChatModel->getTitle();
		                                         //		mChatModelConnection->invokeToCore([this, isMuted]() {
		                                         // setMicrophoneMuted(isMuted); });
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
	if (nbAdded > 0) emit messageListChanged();
}

void ChatCore::removeMessagesFromMessageList(QList<QSharedPointer<ChatMessageCore>> list) {
	int nbRemoved = 0;
	for (auto &message : list) {
		if (mChatMessageList.contains(message)) {
			mChatMessageList.removeAll(message);
			++nbRemoved;
		}
	}
	if (nbRemoved > 0) emit messageListChanged();
}

std::shared_ptr<ChatModel> ChatCore::getModel() const {
	return mChatModel;
}