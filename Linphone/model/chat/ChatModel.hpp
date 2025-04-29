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

#ifndef CHAT_MODEL_H_
#define CHAT_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class ChatModel : public ::Listener<linphone::ChatRoom, linphone::ChatRoomListener>,
                  public linphone::ChatRoomListener,
                  public AbstractObject {
	Q_OBJECT
public:
	ChatModel(const std::shared_ptr<linphone::ChatRoom> &chatRoom, QObject *parent = nullptr);
	~ChatModel();

	QDateTime getLastUpdateTime();
	QString getTitle();
	QString getPeerAddress() const;
	QString getLastMessageInHistory(std::list<std::shared_ptr<linphone::Content>> startList = {}) const;
	int getUnreadMessagesCount() const;
	std::list<std::shared_ptr<linphone::ChatMessage>> getHistory() const;
	QString getIdentifier() const;

private:
	DECLARE_ABSTRACT_OBJECT

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                   const std::shared_ptr<const linphone::Address> &remoteAddress,
	                                   bool isComposing) override;
	virtual void onMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                               const std::shared_ptr<linphone::ChatMessage> &message) override;
	virtual void onMessagesReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                const std::list<std::shared_ptr<linphone::ChatMessage>> &chatMessages) override;
	virtual void onNewEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                        const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onNewEvents(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                         const std::list<std::shared_ptr<linphone::EventLog>> &eventLogs) override;
	virtual void onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                   const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onChatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                    const std::list<std::shared_ptr<linphone::EventLog>> &eventLogs) override;
	virtual void onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                  const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                               const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                  const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                             const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                            linphone::ChatRoom::State newState) override;
	virtual void onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                             const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                              const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                            const std::shared_ptr<linphone::ChatMessage> &message) override;
	virtual void onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                      const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                        const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onParticipantDeviceStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                             const std::shared_ptr<const linphone::EventLog> &eventLog,
	                                             linphone::ParticipantDevice::State state) override;
	virtual void
	onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                            const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                              const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                              const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                            const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                       const std::shared_ptr<const linphone::EventLog> &eventLog) override;
	virtual void onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> &chatRoom) override;
	virtual void onParticipantRegistrationSubscriptionRequested(
	    const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	    const std::shared_ptr<const linphone::Address> &participantAddress) override;
	virtual void onParticipantRegistrationUnsubscriptionRequested(
	    const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	    const std::shared_ptr<const linphone::Address> &participantAddress) override;
	virtual void onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                         const std::shared_ptr<linphone::ChatMessage> &message) override;
	virtual void onChatMessageParticipantImdnStateChanged(
	    const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	    const std::shared_ptr<linphone::ChatMessage> &message,
	    const std::shared_ptr<const linphone::ParticipantImdnState> &state) override;
	virtual void onChatRoomRead(const std::shared_ptr<linphone::ChatRoom> &chatRoom) override;
	virtual void onNewMessageReaction(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                  const std::shared_ptr<linphone::ChatMessage> &message,
	                                  const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) override;

signals:
	void isComposingReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                         const std::shared_ptr<const linphone::Address> &remoteAddress,
	                         bool isComposing);
	void messageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                     const std::shared_ptr<linphone::ChatMessage> &message);
	void messagesReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                      const std::list<std::shared_ptr<linphone::ChatMessage>> &chatMessages);
	void newEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	              const std::shared_ptr<const linphone::EventLog> &eventLog);
	void newEvents(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	               const std::list<std::shared_ptr<linphone::EventLog>> &eventLogs);
	void chatMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                         const std::shared_ptr<const linphone::EventLog> &eventLog);
	void chatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                          const std::list<std::shared_ptr<linphone::EventLog>> &eventLogs);
	void chatMessageSending(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                        const std::shared_ptr<const linphone::EventLog> &eventLog);
	void chatMessageSent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                     const std::shared_ptr<const linphone::EventLog> &eventLog);
	void participantAdded(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                      const std::shared_ptr<const linphone::EventLog> &eventLog);
	void participantRemoved(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                        const std::shared_ptr<const linphone::EventLog> &eventLog);
	void participantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                   const std::shared_ptr<const linphone::EventLog> &eventLog);
	void stateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom, linphone::ChatRoom::State newState);
	void securityEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                   const std::shared_ptr<const linphone::EventLog> &eventLog);
	void subjectChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                    const std::shared_ptr<const linphone::EventLog> &eventLog);
	void undecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                  const std::shared_ptr<linphone::ChatMessage> &message);
	void participantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                            const std::shared_ptr<const linphone::EventLog> &eventLog);
	void participantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                              const std::shared_ptr<const linphone::EventLog> &eventLog);
	void participantDeviceStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                   const std::shared_ptr<const linphone::EventLog> &eventLog,
	                                   linphone::ParticipantDevice::State state);
	void participantDeviceMediaAvailabilityChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                               const std::shared_ptr<const linphone::EventLog> &eventLog);
	void conferenceJoined(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                      const std::shared_ptr<const linphone::EventLog> &eventLog);
	void conferenceLeft(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                    const std::shared_ptr<const linphone::EventLog> &eventLog);
	void ephemeralEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                    const std::shared_ptr<const linphone::EventLog> &eventLog);
	void ephemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                  const std::shared_ptr<const linphone::EventLog> &eventLog);
	void ephemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                             const std::shared_ptr<const linphone::EventLog> &eventLog);
	void conferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	void
	participantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                             const std::shared_ptr<const linphone::Address> &participantAddress);
	void
	participantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                               const std::shared_ptr<const linphone::Address> &participantAddress);
	void chatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                               const std::shared_ptr<linphone::ChatMessage> &message);
	void chatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                            const std::shared_ptr<linphone::ChatMessage> &message,
	                                            const std::shared_ptr<const linphone::ParticipantImdnState> &state);
	void chatRoomRead(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	void newMessageReaction(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                        const std::shared_ptr<linphone::ChatMessage> &message,
	                        const std::shared_ptr<const linphone::ChatMessageReaction> &reaction);
};

#endif
