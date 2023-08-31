/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef CHAT_MESSAGE_LISTENER_H
#define CHAT_MESSAGE_LISTENER_H

#include "utils/LinphoneEnums.hpp"

#include <QDateTime>

// =============================================================================


class ChatMessageModel;

class ChatMessageListener : public QObject, public linphone::ChatMessageListener {
Q_OBJECT
public:
	ChatMessageListener(QObject * parent = nullptr);
	virtual ~ChatMessageListener(){}
	
	virtual void onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer) override;
	virtual void onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer) override;
	virtual std::shared_ptr<linphone::Buffer> onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size) override;
	virtual void onFileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &, size_t offset, size_t) override;
	virtual void onMsgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state) override;
	virtual void onNewMessageReaction(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction) override;
	virtual void onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state) override;
	virtual void onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message) override;
	virtual void onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message) override;
signals:
	void fileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer);
	void fileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer);
	std::shared_ptr<linphone::Buffer> fileTransferSend (const std::shared_ptr<linphone::ChatMessage> &,const std::shared_ptr<linphone::Content> &,size_t,size_t);
	void fileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &, size_t offset, size_t);
	void msgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state);
	void newMessageReaction(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction);
	void participantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state);
	void ephemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message);
	void ephemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message);
};

Q_DECLARE_METATYPE(ChatMessageListener*)
#endif
