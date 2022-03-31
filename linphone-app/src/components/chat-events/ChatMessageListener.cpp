/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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
#include "ChatMessageListener.hpp"


#include <QQmlApplicationEngine>

#include <algorithm>
#include "ChatMessageModel.hpp"

// =============================================================================



// =============================================================================
ChatMessageListener::ChatMessageListener(QObject* parent) : QObject(parent){
}

void ChatMessageListener::onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer){
	emit fileTransferRecv(message, content, buffer);
}
void ChatMessageListener::onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer){
	emit fileTransferSendChunk(message, content, offset, size, buffer);
}
std::shared_ptr<linphone::Buffer> ChatMessageListener::onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size) {
	emit fileTransferSend(message, content, offset, size);
	return nullptr;
}
void ChatMessageListener::onFileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t total){
	emit fileTransferProgressIndication(message, content, offset, total);
}
void ChatMessageListener::onMsgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state){
	emit msgStateChanged(message, state);
}
void ChatMessageListener::onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	emit participantImdnStateChanged(message, state);
}
void ChatMessageListener::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message){
	emit ephemeralMessageTimerStarted(message);
}
void ChatMessageListener::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message){
	emit ephemeralMessageDeleted(message);
}
