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
#include "app/App.hpp"

#include "TimelineModel.hpp"
#include "TimelineListModel.hpp"

#include <QDebug>
#include <qqmlapplicationengine.h>
#include <QTimer>


// =============================================================================
std::shared_ptr<TimelineModel> TimelineModel::create(std::shared_ptr<linphone::ChatRoom> chatRoom, QObject *parent){
	if(!CoreManager::getInstance()->getTimelineListModel() || !CoreManager::getInstance()->getTimelineListModel()->getTimeline(chatRoom, false)) {
		std::shared_ptr<TimelineModel> model = std::make_shared<TimelineModel>(chatRoom, parent);
		if(model && model->getChatRoomModel()){
			model->mSelf = model;
			chatRoom->addListener(model);
			return model;
		}
	}
	return nullptr;
}

TimelineModel::TimelineModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mChatRoomModel = ChatRoomModel::create(chatRoom);
	if( mChatRoomModel ){
		CoreManager::getInstance()->handleChatRoomCreated(mChatRoomModel);
		QObject::connect(this, &TimelineModel::selectedChanged, this, &TimelineModel::updateUnreadCount);
		QObject::connect(CoreManager::getInstance()->getAccountSettingsModel(), &AccountSettingsModel::defaultProxyChanged, this, &TimelineModel::onDefaultProxyChanged);
	}
	mSelected = false;
}

TimelineModel::~TimelineModel(){
	//mChatRoomModel->getChatRoom()->removeListener(mChatRoomModel);
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

ChatRoomModel *TimelineModel::getChatRoomModel() const{
	return mChatRoomModel.get();
}

void TimelineModel::setSelected(const bool& selected){
	if(selected != mSelected){
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
				<< ", hasBeenLeft:" << mChatRoomModel->hasBeenLeft();
			mChatRoomModel->initEntries();
		}
		emit selectedChanged(mSelected);
	}else if(selected)//  Warning, Setting to true is only when we want to force a selection. It's why we send a signal only in this case. We want avoid to change the counter on timelines that are already unselected.
	// This only work because we want at least only one timeline selected
		emit selectedChanged(mSelected);
	
}

void TimelineModel::updateUnreadCount(){
	if(mSelected){
		mChatRoomModel->resetMessageCount();
	}
}
void TimelineModel::onDefaultProxyChanged(){
	if( mSelected && !mChatRoomModel->isCurrentProxy())
		setSelected(false);
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
