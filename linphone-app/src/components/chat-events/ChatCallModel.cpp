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
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "ChatCallModel.hpp"

// =============================================================================

ChatCallModel::ChatCallModel ( std::shared_ptr<linphone::CallLog> callLog, const bool& isStart, QObject * parent) : ChatEvent(ChatRoomModel::EntryType::CallEntry, parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mCallLog = callLog;
	mIsStart = isStart;
	if(isStart){
		mTimestamp = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
		mReceivedTimestamp = mTimestamp;
	}else{
		mTimestamp = QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000);
		mReceivedTimestamp = mTimestamp;
	}
	mIsOutgoing = (mCallLog->getDir() == linphone::Call::Dir::Outgoing);
	mStatus = (LinphoneEnums::fromLinphone(mCallLog->getStatus()));
}

ChatCallModel::~ChatCallModel(){
}

QSharedPointer<ChatCallModel> ChatCallModel::create(std::shared_ptr<linphone::CallLog> callLog, const bool& isStart,  QObject * parent){
	auto model = QSharedPointer<ChatCallModel>::create(callLog, isStart, parent);
	if(model ){
		model->update();
		return model;
	}else
		return nullptr;
}


std::shared_ptr<linphone::CallLog> ChatCallModel::getCallLog(){
	return mCallLog;
}

QString ChatCallModel::getFromDisplayName(){
	if(!mFromDisplayNameCache.isEmpty())
		return mFromDisplayNameCache;
	if(!mCallLog)
		return "";
	mFromDisplayNameCache = Utils::getDisplayName(mCallLog->getFromAddress());
	return mFromDisplayNameCache;
}

//--------------------------------------------------------------------------------------------------------------------------
void ChatCallModel::setIsStart(const bool& data){
		if(data != mIsStart) {
		mIsStart = data;
		emit isStartChanged();
	}
}
void ChatCallModel::setStatus(const LinphoneEnums::CallStatus& data){
	if(data != mStatus) {
		mStatus = data;
		emit statusChanged();
	}
}
void ChatCallModel::setIsOutgoing(const bool& data){
	if(data != mIsOutgoing) {
		mIsOutgoing = data;
		emit isOutgoingChanged();
	}
}
	
	
void ChatCallModel::update(){
	setIsOutgoing(mCallLog->getDir() == linphone::Call::Dir::Outgoing);
	setStatus(LinphoneEnums::fromLinphone(mCallLog->getStatus()));
}

void ChatCallModel::deleteEvent(){
	CoreManager::getInstance()->getCore()->removeCallLog(mCallLog);
	emit CoreManager::getInstance()->callLogsCountChanged();
}