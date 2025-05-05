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

#include "ChatModel.hpp"

#include <QDebug>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ChatModel)

ChatModel::ChatModel(const std::shared_ptr<linphone::ChatRoom> &chatroom, QObject *parent)
    : ::Listener<linphone::ChatRoom, linphone::ChatRoomListener>(chatroom, parent) {
	lDebug() << "[ChatModel] new" << this << " / SDKModel=" << chatroom.get();
	mustBeInLinphoneThread(getClassName());
}

ChatModel::~ChatModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

QDateTime ChatModel::getLastUpdateTime() {
	// TODO : vérifier unité
	return QDateTime::fromSecsSinceEpoch(mMonitor->getLastUpdateTime());
}

std::list<std::shared_ptr<linphone::ChatMessage>> ChatModel::getHistory() const {
	auto history = mMonitor->getHistory(0, (int)linphone::ChatRoom::HistoryFilter::ChatMessage);
	std::list<std::shared_ptr<linphone::ChatMessage>> res;
	for (auto &eventLog : history) {
		if (!eventLog->getChatMessage()) res.push_back(eventLog->getChatMessage());
	}
	return res;
}

QString ChatModel::getIdentifier() const {
	return Utils::coreStringToAppString(mMonitor->getIdentifier());
}

QString ChatModel::getTitle() {
	if (mMonitor->hasCapability((int)linphone::ChatRoom::Capabilities::Basic)) {
		return ToolModel::getDisplayName(mMonitor->getPeerAddress()->clone());
	} else {
		if (mMonitor->hasCapability((int)linphone::ChatRoom::Capabilities::OneToOne)) {
			auto participants = mMonitor->getParticipants();
			if (participants.size() > 0) {
				auto peer = participants.front();
				return peer ? ToolModel::getDisplayName(peer->getAddress()->clone()) : "";
			} else {
				return "";
			}
		} else if (mMonitor->hasCapability((int)linphone::ChatRoom::Capabilities::Conference)) {
			return Utils::coreStringToAppString(mMonitor->getSubject());
		}
	}
	return QString();
}

QString ChatModel::getPeerAddress() const {
	return Utils::coreStringToAppString(mMonitor->getPeerAddress()->asStringUriOnly());
}

QString ChatModel::getLastMessageInHistory(std::list<std::shared_ptr<linphone::Content>> startList) const {
	if (startList.empty()) {
		auto lastMessage = mMonitor->getLastMessageInHistory();
		if (lastMessage) startList = lastMessage->getContents();
	}
	for (auto &content : startList) {
		if (content->isText()) {
			return Utils::coreStringToAppString(content->getUtf8Text());
		} else if (content->isFile()) {
			return Utils::coreStringToAppString(content->getName());
		} else if (content->isIcalendar()) {
			return QString("Invitation à une réunion");
		} else if (content->isMultipart()) {
			return getLastMessageInHistory(content->getParts());
		}
	}
	return QString("");
}

int ChatModel::getUnreadMessagesCount() const {
	return mMonitor->getUnreadMessagesCount();
}
//---------------------------------------------------------------//

void ChatModel::onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                      const std::shared_ptr<const linphone::Address> &remoteAddress,
                                      bool isComposing) {
	emit isComposingReceived(chatRoom, remoteAddress, isComposing);
}

void ChatModel::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                  const std::shared_ptr<linphone::ChatMessage> &message) {
	emit messageReceived(chatRoom, message);
}

void ChatModel::onMessagesReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                   const std::list<std::shared_ptr<linphone::ChatMessage>> &chatMessages) {
	emit messagesReceived(chatRoom, chatMessages);
}

void ChatModel::onNewEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                           const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit newEvent(chatRoom, eventLog);
}

void ChatModel::onNewEvents(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                            const std::list<std::shared_ptr<linphone::EventLog>> &eventLogs) {
	emit newEvents(chatRoom, eventLogs);
}

void ChatModel::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                      const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit chatMessageReceived(chatRoom, eventLog);
}

void ChatModel::onChatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                       const std::list<std::shared_ptr<linphone::EventLog>> &eventLogs) {
	emit chatMessagesReceived(chatRoom, eventLogs);
}

void ChatModel::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                     const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit chatMessageSending(chatRoom, eventLog);
}

void ChatModel::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                  const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit chatMessageSent(chatRoom, eventLog);
}

void ChatModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                   const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit participantAdded(chatRoom, eventLog);
}

void ChatModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                     const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit participantRemoved(chatRoom, eventLog);
}

void ChatModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit participantAdminStatusChanged(chatRoom, eventLog);
}

void ChatModel::onStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                               linphone::ChatRoom::State newState) {
	emit stateChanged(chatRoom, newState);
}

void ChatModel::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit securityEvent(chatRoom, eventLog);
}

void ChatModel::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                 const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit subjectChanged(chatRoom, eventLog);
}

void ChatModel::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                               const std::shared_ptr<linphone::ChatMessage> &message) {
	emit undecryptableMessageReceived(chatRoom, message);
}

void ChatModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                         const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit participantDeviceAdded(chatRoom, eventLog);
}

void ChatModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                           const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit participantDeviceRemoved(chatRoom, eventLog);
}

void ChatModel::onParticipantDeviceStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                                const std::shared_ptr<const linphone::EventLog> &eventLog,
                                                linphone::ParticipantDevice::State state) {
	emit participantDeviceStateChanged(chatRoom, eventLog, state);
}

void ChatModel::onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                                            const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit participantDeviceMediaAvailabilityChanged(chatRoom, eventLog);
}

void ChatModel::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                   const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit conferenceJoined(chatRoom, eventLog);
}

void ChatModel::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                 const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit conferenceLeft(chatRoom, eventLog);
}

void ChatModel::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                 const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit ephemeralEvent(chatRoom, eventLog);
}

void ChatModel::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                               const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit ephemeralMessageTimerStarted(chatRoom, eventLog);
}

void ChatModel::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                          const std::shared_ptr<const linphone::EventLog> &eventLog) {
	emit onEphemeralMessageDeleted(chatRoom, eventLog);
}

void ChatModel::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> &chatRoom) {
	emit conferenceAddressGeneration(chatRoom);
}

void ChatModel::onParticipantRegistrationSubscriptionRequested(
    const std::shared_ptr<linphone::ChatRoom> &chatRoom,
    const std::shared_ptr<const linphone::Address> &participantAddress) {
	emit participantRegistrationSubscriptionRequested(chatRoom, participantAddress);
}

void ChatModel::onParticipantRegistrationUnsubscriptionRequested(
    const std::shared_ptr<linphone::ChatRoom> &chatRoom,
    const std::shared_ptr<const linphone::Address> &participantAddress) {
	emit participantRegistrationUnsubscriptionRequested(chatRoom, participantAddress);
}

void ChatModel::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                            const std::shared_ptr<linphone::ChatMessage> &message) {
	emit chatMessageShouldBeStored(chatRoom, message);
}

void ChatModel::onChatMessageParticipantImdnStateChanged(
    const std::shared_ptr<linphone::ChatRoom> &chatRoom,
    const std::shared_ptr<linphone::ChatMessage> &message,
    const std::shared_ptr<const linphone::ParticipantImdnState> &state) {
	emit chatMessageParticipantImdnStateChanged(chatRoom, message, state);
}

void ChatModel::onChatRoomRead(const std::shared_ptr<linphone::ChatRoom> &chatRoom) {
	emit chatRoomRead(chatRoom);
}

void ChatModel::onNewMessageReaction(const std::shared_ptr<linphone::ChatRoom> &chatRoom,
                                     const std::shared_ptr<linphone::ChatMessage> &message,
                                     const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) {
	// emit onNewMessageReaction(chatRoom, message, reaction);
}
