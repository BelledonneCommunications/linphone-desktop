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

#include "ChatRoomListener.hpp"

#include "../calls/CallsListModel.hpp"

#include <QDebug>
#include <qqmlapplicationengine.h>
#include <QTimer>

ChatRoomListener::ChatRoomListener(QObject * parent): QObject(parent){
}
ChatRoomListener::~ChatRoomListener(){
}
//---------------------------------------------------------------------------------------------------

void ChatRoomListener::onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing){
	emit isComposingReceived(chatRoom, remoteAddress, isComposing);
}
void ChatRoomListener::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	emit messageReceived(chatRoom, message);
}
void ChatRoomListener::onMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::ChatMessage>> & messages){
	emit messagesReceived(chatRoom, messages);
}
void ChatRoomListener::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit newEvent(chatRoom, eventLog);
}
void ChatRoomListener::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit chatMessageReceived(chatRoom, eventLog);
}
void ChatRoomListener::onChatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::EventLog>> & eventLogs){
	emit chatMessagesReceived(chatRoom, eventLogs);
}
void ChatRoomListener::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit chatMessageSending(chatRoom, eventLog);
}
void ChatRoomListener::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit chatMessageSent(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantAdded(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantRemoved(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantAdminStatusChanged(chatRoom, eventLog);
}
void ChatRoomListener::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){
	emit stateChanged(chatRoom, newState);
}
void ChatRoomListener::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit securityEvent(chatRoom, eventLog);
}
void ChatRoomListener::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit subjectChanged(chatRoom, eventLog);
}
void ChatRoomListener::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	emit undecryptableMessageReceived(chatRoom, message);
}
void ChatRoomListener::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantDeviceAdded(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantDeviceRemoved(chatRoom, eventLog);
}
void ChatRoomListener::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit conferenceJoined(chatRoom, eventLog);
}
void ChatRoomListener::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit conferenceLeft(chatRoom, eventLog);
}
void ChatRoomListener::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit ephemeralEvent(chatRoom, eventLog);
}
void ChatRoomListener::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit ephemeralMessageTimerStarted(chatRoom, eventLog);
}
void ChatRoomListener::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit ephemeralMessageDeleted(chatRoom, eventLog);
}
void ChatRoomListener::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom){
	emit conferenceAddressGeneration(chatRoom);
}
void ChatRoomListener::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationSubscriptionRequested(chatRoom, participantAddress);
}
void ChatRoomListener::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationUnsubscriptionRequested(chatRoom, participantAddress);
}
void ChatRoomListener::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	emit chatMessageShouldBeStored(chatRoom, message);
}
void ChatRoomListener::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	emit chatMessageParticipantImdnStateChanged(chatRoom, message, state);
}
