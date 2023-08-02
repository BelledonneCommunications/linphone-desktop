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
	//qDebug() << "ChatRoomListener::onIsComposingReceived";
	emit isComposingReceived(chatRoom, remoteAddress, isComposing);
}
void ChatRoomListener::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	//qDebug() << "ChatRoomListener::onMessageReceived";
	emit messageReceived(chatRoom, message);
}
void ChatRoomListener::onMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::ChatMessage>> & messages){
	//qDebug() << "ChatRoomListener::onMessagesReceived";
	emit messagesReceived(chatRoom, messages);
}
void ChatRoomListener::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onNewEvent";
	emit newEvent(chatRoom, eventLog);
}
void ChatRoomListener::onNewEvents(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::EventLog>> & eventLogs){
	//qDebug() << "ChatRoomListener::onNewEvents";
	emit newEvents(chatRoom, eventLogs);
}
void ChatRoomListener::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onChatMessageReceived";
	emit chatMessageReceived(chatRoom, eventLog);
}
void ChatRoomListener::onChatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::EventLog>> & eventLogs){
	//qDebug() << "ChatRoomListener::onChatMessagesReceived";
	emit chatMessagesReceived(chatRoom, eventLogs);
}
void ChatRoomListener::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onChatMessageSending";
	emit chatMessageSending(chatRoom, eventLog);
}
void ChatRoomListener::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onChatMessageSent";
	emit chatMessageSent(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onParticipantAdded";
	emit participantAdded(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onParticipantRemoved";
	emit participantRemoved(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onParticipantAdminStatusChanged";
	emit participantAdminStatusChanged(chatRoom, eventLog);
}
void ChatRoomListener::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){
	//qDebug() << "ChatRoomListener::onStateChanged";
	emit stateChanged(chatRoom, newState);
}
void ChatRoomListener::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onSecurityEvent";
	emit securityEvent(chatRoom, eventLog);
}
void ChatRoomListener::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onSubjectChanged";
	emit subjectChanged(chatRoom, eventLog);
}
void ChatRoomListener::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	//qDebug() << "ChatRoomListener::onUndecryptableMessageReceived";
	emit undecryptableMessageReceived(chatRoom, message);
}
void ChatRoomListener::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onParticipantDeviceAdded";
	emit participantDeviceAdded(chatRoom, eventLog);
}
void ChatRoomListener::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onParticipantDeviceRemoved";
	emit participantDeviceRemoved(chatRoom, eventLog);
}
void ChatRoomListener::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onConferenceJoined";
	emit conferenceJoined(chatRoom, eventLog);
}
void ChatRoomListener::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onConferenceLeft";
	emit conferenceLeft(chatRoom, eventLog);
}
void ChatRoomListener::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onEphemeralEvent";
	emit ephemeralEvent(chatRoom, eventLog);
}
void ChatRoomListener::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onEphemeralMessageTimerStarted";
	emit ephemeralMessageTimerStarted(chatRoom, eventLog);
}
void ChatRoomListener::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	//qDebug() << "ChatRoomListener::onEphemeralMessageDeleted";
	emit ephemeralMessageDeleted(chatRoom, eventLog);
}
void ChatRoomListener::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom){
	//qDebug() << "ChatRoomListener::onConferenceAddressGeneration";
	emit conferenceAddressGeneration(chatRoom);
}
void ChatRoomListener::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	//qDebug() << "ChatRoomListener::onParticipantRegistrationSubscriptionRequested";
	emit participantRegistrationSubscriptionRequested(chatRoom, participantAddress);
}
void ChatRoomListener::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	//qDebug() << "ChatRoomListener::onParticipantRegistrationUnsubscriptionRequested";
	emit participantRegistrationUnsubscriptionRequested(chatRoom, participantAddress);
}
void ChatRoomListener::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	//qDebug() << "ChatRoomListener::onChatMessageShouldBeStored";
	emit chatMessageShouldBeStored(chatRoom, message);
}
void ChatRoomListener::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	//qDebug() << "ChatRoomListener::onChatMessageParticipantImdnStateChanged";
	emit chatMessageParticipantImdnStateChanged(chatRoom, message, state);
}
