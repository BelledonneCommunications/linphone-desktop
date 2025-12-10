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

#include "ChatMessageModel.hpp"

#include <QDebug>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ChatMessageModel)

ChatMessageModel::ChatMessageModel(const std::shared_ptr<linphone::ChatMessage> &chatMessage, QObject *parent)
    : ::Listener<linphone::ChatMessage, linphone::ChatMessageListener>(chatMessage, parent) {
	// lDebug() << "[ChatMessageModel] new" << this << " / SDKModel=" << chatMessage.get();
	mustBeInLinphoneThread(getClassName());
	mEphemeralTimer.setInterval(60);
	mEphemeralTimer.setSingleShot(false);
	if (mMonitor->getEphemeralExpireTime() != 0) mEphemeralTimer.start();
	connect(&mEphemeralTimer, &QTimer::timeout, this,
	        [this] { emit ephemeralMessageTimeUpdated(mMonitor, mMonitor->getEphemeralExpireTime()); });
	connect(this, &ChatMessageModel::ephemeralMessageTimerStarted, this, [this] { mEphemeralTimer.start(); });
	connect(this, &ChatMessageModel::ephemeralMessageDeleted, this, [this] {
		mEphemeralTimer.stop();
		deleteMessageFromChatRoom(false);
	});
}

ChatMessageModel::~ChatMessageModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

QString ChatMessageModel::getText() const {
	return ToolModel::getMessageFromMessage(mMonitor);
}

QString ChatMessageModel::getUtf8Text() const {
	return Utils::coreStringToAppString(mMonitor->getUtf8Text());
}

bool ChatMessageModel::getHasTextContent() const {
	for (auto content : mMonitor->getContents()) {
		if (content->isText()) return true;
	}
	return false;
}

QString ChatMessageModel::getPeerAddress() const {
	return Utils::coreStringToAppString(mMonitor->getPeerAddress()->asStringUriOnly());
}

QString ChatMessageModel::getFromAddress() const {
	return Utils::coreStringToAppString(mMonitor->getFromAddress()->asStringUriOnly());
}

QString ChatMessageModel::getToAddress() const {
	return Utils::coreStringToAppString(mMonitor->getToAddress()->asStringUriOnly());
}

QString ChatMessageModel::getMessageId() const {
	return Utils::coreStringToAppString(mMonitor->getMessageId());
}

QDateTime ChatMessageModel::getTimestamp() const {
	return QDateTime::fromSecsSinceEpoch(mMonitor->getTime());
}

bool ChatMessageModel::isRead() const {
	return mMonitor->isRead();
}

void ChatMessageModel::markAsRead() {
	mMonitor->markAsRead();
	emit messageRead();
	emit CoreModel::getInstance() -> messageReadInChatRoom(mMonitor->getChatRoom());
}

void ChatMessageModel::deleteMessageFromChatRoom(bool deletedByUser) {
	auto chatRoom = mMonitor->getChatRoom();
	if (chatRoom) {
		chatRoom->deleteMessage(mMonitor);
		emit messageDeleted(deletedByUser);
	}
}

void ChatMessageModel::retractMessageFromChatRoom() {
	auto chatRoom = mMonitor->getChatRoom();
	if (chatRoom) {
		chatRoom->retractMessage(mMonitor);
	}
}

void ChatMessageModel::sendReaction(const QString &reaction) {
	auto linReaction = mMonitor->createReaction(Utils::appStringToCoreString(reaction));
	linReaction->send();
}

void ChatMessageModel::removeReaction() {
	sendReaction(QString());
}

void ChatMessageModel::send() {
	mMonitor->send();
}

QString ChatMessageModel::getOwnReaction() const {
	auto reaction = mMonitor->getOwnReaction();
	return reaction ? Utils::coreStringToAppString(reaction->getBody()) : QString();
}

linphone::ChatMessage::State ChatMessageModel::getState() const {
	return mMonitor->getState();
}

void ChatMessageModel::onMsgStateChanged(const std::shared_ptr<linphone::ChatMessage> &message,
                                         linphone::ChatMessage::State state) {
	emit msgStateChanged(message, state);
}

void ChatMessageModel::onNewMessageReaction(const std::shared_ptr<linphone::ChatMessage> &message,
                                            const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) {
	emit newMessageReaction(message, reaction);
}

void ChatMessageModel::onReactionRemoved(const std::shared_ptr<linphone::ChatMessage> &message,
                                         const std::shared_ptr<const linphone::Address> &address) {
	emit reactionRemoved(message, address);
}

void ChatMessageModel::onFileTransferTerminated(const std::shared_ptr<linphone::ChatMessage> &message,
                                                const std::shared_ptr<linphone::Content> &content) {
	emit fileTransferTerminated(message, content);
}

void ChatMessageModel::onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> &message,
                                          const std::shared_ptr<linphone::Content> &content,
                                          const std::shared_ptr<const linphone::Buffer> &buffer) {
	emit fileTransferRecv(message, content, buffer);
}

std::shared_ptr<linphone::Buffer>
ChatMessageModel::onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> &message,
                                     const std::shared_ptr<linphone::Content> &content,
                                     size_t offset,
                                     size_t size) {
	emit fileTransferSend(message, content, offset, size);
	return nullptr;
}

void ChatMessageModel::onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> &message,
                                               const std::shared_ptr<linphone::Content> &content,
                                               size_t offset,
                                               size_t size,
                                               const std::shared_ptr<linphone::Buffer> &buffer) {
	emit fileTransferSendChunk(message, content, offset, size, buffer);
}

void ChatMessageModel::onFileTransferProgressIndication(const std::shared_ptr<linphone::ChatMessage> &message,
                                                        const std::shared_ptr<linphone::Content> &content,
                                                        size_t offset,
                                                        size_t total) {
	emit fileTransferProgressIndication(message, content, offset, total);
}

void ChatMessageModel::onParticipantImdnStateChanged(
    const std::shared_ptr<linphone::ChatMessage> &message,
    const std::shared_ptr<const linphone::ParticipantImdnState> &state) {
	emit participantImdnStateChanged(message, state);
}

void ChatMessageModel::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> &message) {
	emit ephemeralMessageTimerStarted(message);
}

void ChatMessageModel::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> &message) {
	emit ephemeralMessageDeleted(message);
}

void ChatMessageModel::onRetracted(const std::shared_ptr<linphone::ChatMessage> &message) {
	emit retracted(message);
}
