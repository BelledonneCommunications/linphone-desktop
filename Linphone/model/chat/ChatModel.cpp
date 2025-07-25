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
	// lDebug() << "[ChatModel] new" << this << " / SDKModel=" << chatroom.get();
	mustBeInLinphoneThread(getClassName());
	auto coreModel = CoreModel::getInstance();
	if (coreModel)
		connect(coreModel.get(), &CoreModel::messageReadInChatRoom, this,
		        [this](std::shared_ptr<linphone::ChatRoom> chatroom) {
			        if (chatroom == mMonitor) emit messagesRead();
		        });
}

ChatModel::~ChatModel() {
	mustBeInLinphoneThread("~" + getClassName());
	disconnect(CoreModel::getInstance().get(), &CoreModel::messageReadInChatRoom, this, nullptr);
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

int ChatModel::getCapabilities() const {
	return mMonitor->getCapabilities();
}

bool ChatModel::hasCapability(int capability) const {
	return mMonitor->hasCapability(capability);
}

std::shared_ptr<linphone::ChatMessage> ChatModel::getLastChatMessage() {
	return mMonitor->getLastMessageInHistory();
}

int ChatModel::getUnreadMessagesCount() const {
	return mMonitor->getUnreadMessagesCount();
}

void ChatModel::markAsRead() {
	mMonitor->markAsRead();
	for (auto &message : getHistory()) {
		message->markAsRead();
	}
	emit messagesRead();
}

void ChatModel::setMuted(bool muted) {
	mMonitor->setMuted(muted);
	emit mutedChanged(muted);
}

void ChatModel::enableEphemeral(bool enable) {
	mMonitor->enableEphemeral(enable);
	emit ephemeralEnableChanged(enable);
}

void ChatModel::setEphemeralLifetime(int time) {
	mMonitor->setEphemeralLifetime(time);
	emit ephemeralLifetimeChanged(time);
	enableEphemeral(time != 0);
}

void ChatModel::deleteHistory() {
	mMonitor->deleteHistory();
	emit historyDeleted();
}

void ChatModel::deleteMessage(std::shared_ptr<linphone::ChatMessage> message) {
	mMonitor->deleteMessage(message);
}

void ChatModel::leave() {
	mMonitor->leave();
}

void ChatModel::deleteChatRoom() {
	CoreModel::getInstance()->getCore()->deleteChatRoom(mMonitor);
	emit deleted();
}

std::shared_ptr<linphone::ChatMessage>
ChatModel::createVoiceRecordingMessage(const std::shared_ptr<linphone::Recorder> &recorder) {
	return mMonitor->createVoiceRecordingMessage(recorder);
}

std::shared_ptr<linphone::ChatMessage>
ChatModel::createReplyMessage(const std::shared_ptr<linphone::ChatMessage> &message) {
	return mMonitor->createReplyMessage(message);
}

std::shared_ptr<linphone::ChatMessage>
ChatModel::createForwardMessage(const std::shared_ptr<linphone::ChatMessage> &message) {
	return mMonitor->createForwardMessage(message);
}

std::shared_ptr<linphone::ChatMessage> ChatModel::createTextMessageFromText(QString text) {
	return mMonitor->createMessageFromUtf8(Utils::appStringToCoreString(text));
}

std::shared_ptr<linphone::ChatMessage>
ChatModel::createMessage(QString text, QList<std::shared_ptr<ChatMessageContentModel>> filesContent) {
	auto message = mMonitor->createEmptyMessage();
	for (auto &content : filesContent) {
		message->addFileContent(content->getContent());
	}
	if (!text.isEmpty()) message->addUtf8TextContent(Utils::appStringToCoreString(text));
	return message;
}

void ChatModel::compose() {
	mMonitor->compose();
}

linphone::ChatRoom::State ChatModel::getState() const {
	return mMonitor->getState();
}

void ChatModel::setSubject(QString subject) const {
	return mMonitor->setSubject(Utils::appStringToCoreString(subject));
}

void ChatModel::removeParticipantAtIndex(int index) const {
	auto participant = *std::next(mMonitor->getParticipants().begin(), index);
	mMonitor->removeParticipant(participant);
}

void ChatModel::toggleParticipantAdminStatusAtIndex(int index) const {
	auto participant = *std::next(mMonitor->getParticipants().begin(), index);
	mMonitor->setParticipantAdminStatus(participant, !participant->isAdmin());
}

void ChatModel::setParticipantAddresses(const QStringList &addresses) const {
	QSet<QString> s{addresses.cbegin(), addresses.cend()};
	for (auto p : mMonitor->getParticipants()) {
		auto address = Utils::coreStringToAppString(p->getAddress()->asStringUriOnly());
		if (s.contains(address)) s.remove(address);
		else mMonitor->removeParticipant(p);
	}
	for (const auto &a : s) {
		auto address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(a));
		if (address) mMonitor->addParticipant(address);
	}
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
	emit ephemeralMessageDeleted(chatRoom, eventLog);
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
