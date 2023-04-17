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
#include "components/chat-room/ChatRoomListener.hpp"
#include "utils/Utils.hpp"
#include "app/App.hpp"

#include "TimelineModel.hpp"
#include "TimelineListModel.hpp"

#include "../calls/CallsListModel.hpp"

#include <QDebug>
#include <qqmlapplicationengine.h>
#include <QTimer>

void TimelineModel::connectTo(ChatRoomListener * listener){
	connect(listener, &ChatRoomListener::isComposingReceived, this, &TimelineModel::onIsComposingReceived);
	connect(listener, &ChatRoomListener::messageReceived, this, &TimelineModel::onMessageReceived);
	connect(listener, &ChatRoomListener::messagesReceived, this, &TimelineModel::onMessagesReceived);
	connect(listener, &ChatRoomListener::newEvent, this, &TimelineModel::onNewEvent);
	connect(listener, &ChatRoomListener::chatMessageReceived, this, &TimelineModel::onChatMessageReceived);
	connect(listener, &ChatRoomListener::chatMessagesReceived, this, &TimelineModel::onChatMessagesReceived);
	connect(listener, &ChatRoomListener::chatMessageSending, this, &TimelineModel::onChatMessageSending);
	connect(listener, &ChatRoomListener::chatMessageSent, this, &TimelineModel::onChatMessageSent);
	connect(listener, &ChatRoomListener::participantAdded, this, &TimelineModel::onParticipantAdded);
	connect(listener, &ChatRoomListener::participantRemoved, this, &TimelineModel::onParticipantRemoved);
	connect(listener, &ChatRoomListener::participantAdminStatusChanged, this, &TimelineModel::onParticipantAdminStatusChanged);
	connect(listener, &ChatRoomListener::stateChanged, this, &TimelineModel::onStateChanged);
	connect(listener, &ChatRoomListener::securityEvent, this, &TimelineModel::onSecurityEvent);
	connect(listener, &ChatRoomListener::subjectChanged, this, &TimelineModel::onSubjectChanged);
	connect(listener, &ChatRoomListener::undecryptableMessageReceived, this, &TimelineModel::onUndecryptableMessageReceived);
	connect(listener, &ChatRoomListener::participantDeviceAdded, this, &TimelineModel::onParticipantDeviceAdded);
	connect(listener, &ChatRoomListener::participantDeviceRemoved, this, &TimelineModel::onParticipantDeviceRemoved);
	connect(listener, &ChatRoomListener::conferenceJoined, this, &TimelineModel::onConferenceJoined);
	connect(listener, &ChatRoomListener::conferenceLeft, this, &TimelineModel::onConferenceLeft);
	connect(listener, &ChatRoomListener::ephemeralEvent, this, &TimelineModel::onEphemeralEvent);
	connect(listener, &ChatRoomListener::ephemeralMessageTimerStarted, this, &TimelineModel::onEphemeralMessageTimerStarted);
	connect(listener, &ChatRoomListener::ephemeralMessageDeleted, this, &TimelineModel::onEphemeralMessageDeleted);
	connect(listener, &ChatRoomListener::conferenceAddressGeneration, this, &TimelineModel::onConferenceAddressGeneration);
	connect(listener, &ChatRoomListener::participantRegistrationSubscriptionRequested, this, &TimelineModel::onParticipantRegistrationSubscriptionRequested);
	connect(listener, &ChatRoomListener::participantRegistrationUnsubscriptionRequested, this, &TimelineModel::onParticipantRegistrationUnsubscriptionRequested);
	connect(listener, &ChatRoomListener::chatMessageShouldBeStored, this, &TimelineModel::onChatMessageShouldBeStored);
	connect(listener, &ChatRoomListener::chatMessageParticipantImdnStateChanged, this, &TimelineModel::onChatMessageParticipantImdnStateChanged);
}

// =============================================================================
QSharedPointer<TimelineModel> TimelineModel::create(TimelineListModel * mainList, std::shared_ptr<linphone::ChatRoom> chatRoom, const std::list<std::shared_ptr<linphone::CallLog>>& callLogs, QObject *parent){
	if((!chatRoom || chatRoom->getState() != linphone::ChatRoom::State::Deleted)  && (!mainList || !mainList->getTimeline(chatRoom, false)) ) {
		QSharedPointer<TimelineModel> model = QSharedPointer<TimelineModel>::create(chatRoom,callLogs, parent);
		if(model && model->getChatRoomModel()){
			return model;
		}
	}
	return nullptr;
}

TimelineModel::TimelineModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject *parent) : QObject(parent) {
	TimelineModel(chatRoom, std::list<std::shared_ptr<linphone::CallLog>>(), parent);
}
TimelineModel::TimelineModel (std::shared_ptr<linphone::ChatRoom> chatRoom, const std::list<std::shared_ptr<linphone::CallLog>>& callLogs, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mChatRoomModel = ChatRoomModel::create(chatRoom, callLogs);
	if( mChatRoomModel ){
		CoreManager::getInstance()->handleChatRoomCreated(mChatRoomModel);
		QObject::connect(this, &TimelineModel::selectedChanged, this, &TimelineModel::updateUnreadCount);
		QObject::connect(CoreManager::getInstance()->getAccountSettingsModel(), &AccountSettingsModel::defaultAccountChanged, this, &TimelineModel::onDefaultAccountChanged);
		QObject::connect(mChatRoomModel.get(), &ChatRoomModel::chatRoomDeleted, this, &TimelineModel::onChatRoomDeleted);
		QObject::connect(mChatRoomModel.get(), &ChatRoomModel::updatingChanged, this, &TimelineModel::updatingChanged);
		QObject::connect(mChatRoomModel.get(), &ChatRoomModel::stateChanged, this, &TimelineModel::onChatRoomStateChanged);
	}
	if(chatRoom){
		mChatRoomListener = std::make_shared<ChatRoomListener>();
		connectTo(mChatRoomListener.get());
		chatRoom->addListener(mChatRoomListener);
	}
	mSelected = false;
}

TimelineModel::TimelineModel(const TimelineModel * model){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mChatRoomModel = model->mChatRoomModel;
	if( mChatRoomModel ){
		QObject::connect(this, &TimelineModel::selectedChanged, this, &TimelineModel::updateUnreadCount);
		QObject::connect(CoreManager::getInstance()->getAccountSettingsModel(), &AccountSettingsModel::defaultAccountChanged, this, &TimelineModel::onDefaultAccountChanged);
		QObject::connect(mChatRoomModel.get(), &ChatRoomModel::chatRoomDeleted, this, &TimelineModel::onChatRoomDeleted);
		QObject::connect(mChatRoomModel.get(), &ChatRoomModel::updatingChanged, this, &TimelineModel::updatingChanged);
		QObject::connect(mChatRoomModel.get(), &ChatRoomModel::stateChanged, this, &TimelineModel::onChatRoomStateChanged);
	}
	if(mChatRoomModel->getChatRoom()){
		mChatRoomListener = model->mChatRoomListener;
		connectTo(mChatRoomListener.get());
		mChatRoomModel->getChatRoom()->addListener(mChatRoomListener);
	}
	mSelected = model->mSelected;
}

QSharedPointer<TimelineModel> TimelineModel::clone()const{
	return QSharedPointer<TimelineModel>::create(this);
}

TimelineModel::~TimelineModel(){
	if(mChatRoomModel && mChatRoomListener && mChatRoomModel->getChatRoom())
		mChatRoomModel->getChatRoom()->removeListener(mChatRoomListener);
}

QString TimelineModel::getFullPeerAddress() const{
	return mChatRoomModel->getFullPeerAddress();
}
QString TimelineModel::getFullLocalAddress() const{
	return mChatRoomModel->getLocalAddress();
}


QString TimelineModel::getUsername() const{
	return mChatRoomModel->getUsername();
}

QString TimelineModel::getAvatar() const{
	return "";
}

int TimelineModel::getPresenceStatus() const{
	return 0;
}

bool TimelineModel::isUpdating() const{
	return !mChatRoomModel || mChatRoomModel->isUpdating();
}

ChatRoomModel *TimelineModel::getChatRoomModel() const{
	return mChatRoomModel.get();
}

void TimelineModel::setSelected(const bool& selected){
	if(mChatRoomModel && (selected != mSelected || selected)){
		mSelected = selected;
		if(mSelected){
			qInfo() << "Chat room selected : Subject :" << mChatRoomModel->getSubject()
				<< ", Username:" << mChatRoomModel->getUsername()
				<< ", GroupEnabled:"<< mChatRoomModel->isGroupEnabled()
				<< ", isConference:"<< mChatRoomModel->isConference()
				<< ", isOneToOne:"<< mChatRoomModel->isOneToOne()
				<< ", Encrypted:"<< mChatRoomModel->haveEncryption()
				<< ", ephemeralEnabled:" << mChatRoomModel->isEphemeralEnabled()
				<< ", isAdmin:"<< mChatRoomModel->isMeAdmin()
				<< ", canHandleParticipants:"<< mChatRoomModel->canHandleParticipants()
				<< ", isReadOnly:" << mChatRoomModel->isReadOnly()
				<< ", state:" << mChatRoomModel->getState();
		}
		emit selectedChanged(mSelected);
	}
}

void TimelineModel::delaySelected(){
	if( mChatRoomModel->getState() == LinphoneEnums::ChatRoomStateCreated || mChatRoomModel->getState() == LinphoneEnums::ChatRoomStateTerminated){
		QTimer::singleShot(200, [&](){// Delay process in order to let GUI time for Timeline building/linking before doing actions
			setSelected(true);
		});
	}else
		mDelaySelection = true;
}

void TimelineModel::updateUnreadCount(){
	if(!mSelected){// updateUnreadCount is called when selected has changed;: So if mSelected is false then we are going out of it.
		mChatRoomModel->resetMessageCount();// The reset will appear when the chat room has "mark as read enabled", that means that we should have read messages when going out.
	}
}
void TimelineModel::onDefaultAccountChanged(){
	if( mSelected && !mChatRoomModel->isCurrentAccount())
		setSelected(false);
}

void TimelineModel::disconnectChatRoomListener(){
	if( mChatRoomModel && mChatRoomListener && mChatRoomModel->getChatRoom()){
		mChatRoomModel->getChatRoom()->removeListener(mChatRoomListener);
		mChatRoomListener = nullptr;
	}
}

//----------------------------------------------------------
//------				CHAT ROOM HANDLERS
//----------------------------------------------------------

void TimelineModel::onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing){
}
void TimelineModel::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){}
void TimelineModel::onMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::ChatMessage>> & messages){}
void TimelineModel::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onChatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::EventLog>> & eventLogs){}
void TimelineModel::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void TimelineModel::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){
	if(newState == linphone::ChatRoom::State::Created && CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation) {
		CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = false;
		QTimer::singleShot(200, [=](){// Delay process in order to let GUI time for Timeline building/linking before doing actions
				setSelected(true);
			});
	}
}
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

void TimelineModel::onChatRoomDeleted(){
	emit chatRoomDeleted();
}

void TimelineModel::onChatRoomStateChanged(){
	if(mDelaySelection && mChatRoomModel->getState() == LinphoneEnums::ChatRoomStateCreated){
		mDelaySelection = false;
		setSelected(true);
	}
}