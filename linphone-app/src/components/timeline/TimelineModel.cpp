/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"
#include "utils/Utils.hpp"

#include "TimelineModel.hpp"

#include <QDebug>


// =============================================================================

TimelineModel::TimelineModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject *parent) : QObject(parent) {
	mChatRoomModel = CoreManager::getInstance()->getChatRoomModel(chatRoom);
	
	QObject::connect(mChatRoomModel.get(), &ChatRoomModel::unreadMessagesCountChanged, this, &TimelineModel::updateUnreadCount);
	QObject::connect(mChatRoomModel.get(), &ChatRoomModel::missedCallsCountChanged, this, &TimelineModel::updateUnreadCount);
	QObject::connect(mChatRoomModel.get(), &ChatRoomModel::conferenceLeft, this, &TimelineModel::onConferenceLeft);
	//mTimestamp = QDateTime::fromMSecsSinceEpoch(mChatRoomModel->getChatRoom()->getLastUpdateTime());
	mSelected = false;
}

TimelineModel::~TimelineModel(){
}

QString TimelineModel::getFullPeerAddress() const{
	return mChatRoomModel->getFullPeerAddress();
}
QString TimelineModel::getFullLocalAddress() const{
	return mChatRoomModel->getLocalAddress();
}


QString TimelineModel::getUsername() const{
	std::string username = mChatRoomModel->getChatRoom()->getSubject();
	if(username != ""){
		return QString::fromStdString(username);
	}
	username = mChatRoomModel->getChatRoom()->getPeerAddress()->getDisplayName();
	if(username != "")
		return QString::fromStdString(username);
	username = mChatRoomModel->getChatRoom()->getPeerAddress()->getUsername();
	if(username != "")
		return QString::fromStdString(username);
	return QString::fromStdString(mChatRoomModel->getChatRoom()->getPeerAddress()->asStringUriOnly());
}

QString TimelineModel::getAvatar() const{
	return "";
}

int TimelineModel::getPresenceStatus() const{
	return 0;
}

ChatRoomModel *TimelineModel::getChatRoomModel() const{
	return mChatRoomModel.get();
}

void TimelineModel::setSelected(const bool& selected){
	if(selected != mSelected){
		mSelected = selected;
		emit selectedChanged(mSelected);
	}
}

void TimelineModel::updateUnreadCount(){
	if(mSelected){
		mChatRoomModel->resetMessageCount();
	}
}
//----------------------------------------------------------
//------				CHAT ROOM HANDLERS
//----------------------------------------------------------

void TimelineModel::onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing){
}
void TimelineModel::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){}
void TimelineModel::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){}
void TimelineModel::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog)
{
	emit usernameChanged();
}
void TimelineModel::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){}
void TimelineModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
}
void TimelineModel::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	
}
void TimelineModel::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom){}
void TimelineModel::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){}
void TimelineModel::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){}
void TimelineModel::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){}
void TimelineModel::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){}
