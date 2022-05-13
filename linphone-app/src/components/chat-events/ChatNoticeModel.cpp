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

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "ChatNoticeModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"
#include "utils/Utils.hpp"

// =============================================================================

ChatNoticeModel::ChatNoticeModel ( std::shared_ptr<linphone::EventLog> eventLog, QObject * parent) : ChatEvent(ChatRoomModel::EntryType::NoticeEntry, parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mEventLog = eventLog;
	mEventLogType = LinphoneEnums::EventLogType::EventLogTypeNone;
	setEventLogType(LinphoneEnums::fromLinphone(mEventLog->getType()));
	mTimestamp = QDateTime::fromMSecsSinceEpoch(eventLog->getCreationTime() * 1000);
}

ChatNoticeModel::ChatNoticeModel ( NoticeType noticeType, const QDateTime& timestamp, const QString& txt, QObject * parent) : ChatEvent(ChatRoomModel::EntryType::NoticeEntry, parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mEventLogType = LinphoneEnums::EventLogType::EventLogTypeNone;
	setStatus(noticeType);
	setName(txt);
	mTimestamp = timestamp;
}

ChatNoticeModel::~ChatNoticeModel(){
}

QSharedPointer<ChatNoticeModel> ChatNoticeModel::create(std::shared_ptr<linphone::EventLog> eventLog, QObject * parent){
	auto model = QSharedPointer<ChatNoticeModel>::create(eventLog, parent);
	if(model && model->update()){
		return model;
	}else
		return nullptr;
}

QSharedPointer<ChatNoticeModel> ChatNoticeModel::create(NoticeType noticeType, const QDateTime& timestamp, const QString& txt, QObject * parent){
	auto model = QSharedPointer<ChatNoticeModel>::create(noticeType, timestamp, txt, parent);
	if(model ){
		return model;
	}else
		return nullptr;
}

std::shared_ptr<linphone::EventLog> ChatNoticeModel::getEventLog(){
	return mEventLog;
}

//---------------------------------------------------------------------------------------------
bool ChatNoticeModel::update(){
	bool handledEvent = true;
	if(!mEventLog)
		return false;
	auto participantAddress = mEventLog->getParticipantAddress();
	
	switch(mEventLog->getType()){
		case linphone::EventLog::Type::ConferenceCreated: 
			setName("");
			setStatus(NoticeType::NoticeMessage);
			//dest["message"] = "You have joined the group";
			break;
		case linphone::EventLog::Type::ConferenceTerminated: 
			setName("");
			setStatus(NoticeType::NoticeMessage);
			//	dest["message"] = "You have left the group";
			break;
		case linphone::EventLog::Type::ConferenceParticipantAdded:
			setName(Utils::getDisplayName(participantAddress));
			setStatus(NoticeType::NoticeMessage);
			//dest["message"] = "%1 has joined";
			break;
		case linphone::EventLog::Type::ConferenceParticipantRemoved: 
			setName(Utils::getDisplayName(participantAddress));
			setStatus(NoticeType::NoticeMessage);
			//dest["message"] = "%1 has left";
			break;
		case linphone::EventLog::Type::ConferenceSecurityEvent: {
			if(mEventLog->getSecurityEventType() == linphone::EventLog::SecurityEventType::SecurityLevelDowngraded ){
				auto faultyParticipant = mEventLog->getSecurityEventFaultyDeviceAddress();
				if(faultyParticipant)
					setName(Utils::getDisplayName(faultyParticipant));
				else if(participantAddress)
					setName(Utils::getDisplayName(participantAddress));
				setStatus(NoticeType::NoticeError);
				//dest["message"] = "Security level degraded by %1";
			}else// No callback from SDK on upgraded security event yet
				handledEvent = false;
				break;
		}
		case linphone::EventLog::Type::ConferenceEphemeralMessageEnabled :
		case linphone::EventLog::Type::ConferenceEphemeralMessageLifetimeChanged :
		{
			int selectedTime = mEventLog->getEphemeralMessageLifetime();
			if(selectedTime == 60)
				setName( tr("nMinute", "", 1).arg(1) );
			else if(selectedTime == 3600)
				setName( tr("nHour", "", 1).arg(1));
			else if(selectedTime == 86400)
				setName(tr("nDay", "", 1).arg(1) );
			else if(selectedTime == 259200)
				setName( tr("nDay", "", 3).arg(3) );
			else if(selectedTime == 604800)
				setName( tr("nWeek", "", 1).arg(1) );
			setStatus(NoticeType::NoticeMessage);
			break;
		}
		case linphone::EventLog::Type::ConferenceEphemeralMessageDisabled :{
			setName("");
			setStatus(NoticeType::NoticeMessage);
			break;
		}
		
		case linphone::EventLog::Type::ConferenceSubjectChanged : {
			setName(QString::fromStdString(mEventLog->getSubject()));
			setStatus(NoticeType::NoticeMessage);
			break;
		}
		
		case linphone::EventLog::Type::ConferenceParticipantSetAdmin :
		case linphone::EventLog::Type::ConferenceParticipantUnsetAdmin :
		 {
			setName(Utils::getDisplayName(participantAddress));
			setStatus(NoticeType::NoticeMessage);
			break;
		}
		
		
		
		default:{
			handledEvent = false;
		}
	}
	setEventLogType(LinphoneEnums::fromLinphone(mEventLog->getType()));
	return handledEvent;
}

void ChatNoticeModel::setName(const QString& data){
	if(data != mName) {
		mName = data;
		emit nameChanged();
	}
}

void ChatNoticeModel::setStatus(NoticeType data){
	if(data != mStatus) {
		mStatus = data;
		emit statusChanged();
	}
}

void ChatNoticeModel::setEventLogType(const LinphoneEnums::EventLogType& data){
	if(data != mEventLogType) {
		mEventLogType = data;
		emit eventLogTypeChanged();
	}
}

void ChatNoticeModel::deleteEvent(){
	if(mEventLog)
		mEventLog->deleteFromDatabase();
}