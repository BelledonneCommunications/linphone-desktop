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

#ifndef CHAT_MESSAGE_MODEL_H_
#define CHAT_MESSAGE_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class ChatMessageModel : public ::Listener<linphone::ChatMessage, linphone::ChatMessageListener>,
                         public linphone::ChatMessageListener,
                         public AbstractObject {
	Q_OBJECT
public:
	ChatMessageModel(const std::shared_ptr<linphone::ChatMessage> &chatMessage, QObject *parent = nullptr);
	~ChatMessageModel();

	QString getText() const;
	QDateTime getTimestamp() const;

	QString getPeerAddress() const;
	QString getFromAddress() const;
	QString getToAddress() const;

	bool isRead() const;
	void markAsRead();

	void deleteMessageFromChatRoom();

	void computeDeliveryStatus();

	linphone::ChatMessage::State getState() const;

signals:
	void messageDeleted();
	void messageRead();

	void msgStateChanged(const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state);
	void newMessageReaction(const std::shared_ptr<linphone::ChatMessage> &message,
	                        const std::shared_ptr<const linphone::ChatMessageReaction> &reaction);
	void reactionRemoved(const std::shared_ptr<linphone::ChatMessage> &message,
	                     const std::shared_ptr<const linphone::Address> &address);
	void fileTransferTerminated(const std::shared_ptr<linphone::ChatMessage> &message,
	                            const std::shared_ptr<linphone::Content> &content);
	void fileTransferRecv(const std::shared_ptr<linphone::ChatMessage> &message,
	                      const std::shared_ptr<linphone::Content> &content,
	                      const std::shared_ptr<const linphone::Buffer> &buffer);
	void fileTransferSend(const std::shared_ptr<linphone::ChatMessage> &message,
	                      const std::shared_ptr<linphone::Content> &content,
	                      size_t offset,
	                      size_t size);
	void fileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> &message,
	                           const std::shared_ptr<linphone::Content> &content,
	                           size_t offset,
	                           size_t size,
	                           const std::shared_ptr<linphone::Buffer> &buffer);
	void fileTransferProgressIndication(const std::shared_ptr<linphone::ChatMessage> &message,
	                                    const std::shared_ptr<linphone::Content> &content,
	                                    size_t offset,
	                                    size_t total);
	void participantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> &message,
	                                 const std::shared_ptr<const linphone::ParticipantImdnState> &state);
	void ephemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> &message);
	void ephemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> &message);

private:
	linphone::ChatMessage::State mMessageState;

	DECLARE_ABSTRACT_OBJECT

	void onMsgStateChanged(const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state);
	void onNewMessageReaction(const std::shared_ptr<linphone::ChatMessage> &message,
	                          const std::shared_ptr<const linphone::ChatMessageReaction> &reaction);
	void onReactionRemoved(const std::shared_ptr<linphone::ChatMessage> &message,
	                       const std::shared_ptr<const linphone::Address> &address);
	void onFileTransferTerminated(const std::shared_ptr<linphone::ChatMessage> &message,
	                              const std::shared_ptr<linphone::Content> &content);
	void onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> &message,
	                        const std::shared_ptr<linphone::Content> &content,
	                        const std::shared_ptr<const linphone::Buffer> &buffer);
	std::shared_ptr<linphone::Buffer> onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> &message,
	                                                     const std::shared_ptr<linphone::Content> &content,
	                                                     size_t offset,
	                                                     size_t size);
	void onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> &message,
	                             const std::shared_ptr<linphone::Content> &content,
	                             size_t offset,
	                             size_t size,
	                             const std::shared_ptr<linphone::Buffer> &buffer);
	void onFileTransferProgressIndication(const std::shared_ptr<linphone::ChatMessage> &message,
	                                      const std::shared_ptr<linphone::Content> &content,
	                                      size_t offset,
	                                      size_t total);
	void onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> &message,
	                                   const std::shared_ptr<const linphone::ParticipantImdnState> &state);
	void onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> &message);
	void onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> &message);
};

#endif
