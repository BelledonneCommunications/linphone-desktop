/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#include "CallHistoryModel.hpp"

#include "utils/Utils.hpp"

#include <QDebug>

CallHistoryModel::CallHistoryModel(QObject *parent) : QObject(parent){
	
}

CallHistoryModel::CallHistoryModel(const std::shared_ptr<linphone::CallLog> callLog, QObject *parent)  : QObject(parent){
	mRemoteAddress = callLog->getRemoteAddress()->clone();
	mRemoteAddress->clean();
	mLastCallStatus = LinphoneEnums::fromLinphone(callLog->getStatus());
	if(mShowEnd && mLastCallStatus == LinphoneEnums::CallStatusSuccess){
		mLastCallDate = QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000);
		mLastCallIsStart = false;
	}else {
		mLastCallDate = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
		mLastCallIsStart = true;
	}
	mLastCallIsOutgoing = callLog->getDir() == linphone::Call::Dir::Outgoing;
	mConferenceInfoModel = ConferenceInfoModel::create(callLog->getConferenceInfo());
	if(!mConferenceInfoModel && callLog->wasConference())
		qWarning() << "Was conf without info : " << Utils::coreStringToAppString(mRemoteAddress->asStringUriOnly());
}

QString CallHistoryModel::getRemoteAddress() const{
	return Utils::coreStringToAppString(mRemoteAddress->asStringUriOnly());
}

QString CallHistoryModel::getSipAddress() const{
	if( mConferenceInfoModel )
		return Utils::coreStringToAppString(mConferenceInfoModel->getConferenceInfo()->getUri()->asStringUriOnly());
	else
		return Utils::coreStringToAppString(mRemoteAddress->asStringUriOnly());
}


ConferenceInfoModel * CallHistoryModel::getConferenceInfoModel() const {
	return mConferenceInfoModel.get();
}

bool CallHistoryModel::wasConference() const {
	return mConferenceInfoModel;
}

QString CallHistoryModel::getTitle() const {
	if(mConferenceInfoModel)
		return mConferenceInfoModel->getSubject();
	else
		return "";
}

void CallHistoryModel::update(const std::shared_ptr<linphone::CallLog> callLog){
	QDateTime callDate;
	if(mShowEnd && mLastCallStatus == LinphoneEnums::CallStatusSuccess){
		callDate = QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000);
	}else {
		callDate = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
	}
	if(callDate >= mLastCallDate){
		setLastCallStatus(LinphoneEnums::fromLinphone(callLog->getStatus()));	
		if(mShowEnd && mLastCallStatus == LinphoneEnums::CallStatusSuccess){
			setLastCallDate(QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000));
			setLastCallIsStart(false);
		}else {
			setLastCallDate(QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000));
			setLastCallIsStart(true);
		}
		mConferenceInfoModel = ConferenceInfoModel::create(callLog->getConferenceInfo());
		emit conferenceInfoModelChanged();
	}
}

void CallHistoryModel::setLastCallStatus(LinphoneEnums::CallStatus status) {
	if(mLastCallStatus != status){
		mLastCallStatus = status;
		emit lastCallStatusChanged();
	}
}

void CallHistoryModel::setLastCallDate(const QDateTime& date) {
	if( mLastCallDate != date) {
		mLastCallDate = date;
		emit lastCallDateChanged();
	}
}

void CallHistoryModel::setLastCallIsStart(const bool& start) {
	if( mLastCallIsStart != start) {
		mLastCallIsStart = start;
		emit lastCallIsStartChanged();
	}
}

void CallHistoryModel::setLastCallIsOutgoing(const bool& outgoing){
	if( mLastCallIsOutgoing != outgoing) {
		mLastCallIsOutgoing = outgoing;
		emit lastCallIsOutgoingChanged();
	}
}

void CallHistoryModel::setSelected(const bool& selected){
	if(selected != mSelected || selected){
		mSelected = selected;
		if(mSelected){
			qInfo() << "Call room selected : Address :" << getRemoteAddress();
		}else{
			qInfo() << "Unselect call room "<< getRemoteAddress();
		}
		emit selectedChanged(mSelected, this);
	}
}

void CallHistoryModel::selectOnly(){
	setSelected(true);
	emit selectOnlyRequested();
}

