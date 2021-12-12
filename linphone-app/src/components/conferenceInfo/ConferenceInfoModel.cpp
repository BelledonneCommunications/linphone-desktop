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

#include "ConferenceInfoModel.hpp"

#include <algorithm>

#include <QDateTime>
#include <QDesktopServices>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QTimer>
#include <QUuid>
#include <QMessageBox>
#include <QUrlQuery>
#include <QImageReader>
#include <qqmlapplicationengine.h>

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "app/providers/ThumbnailProvider.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/chat-events/ChatCallModel.hpp"
#include "components/chat-events/ChatEvent.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/chat-events/ChatNoticeModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/participant/ParticipantModel.hpp"
#include "components/participant/ParticipantListModel.hpp"
#include "components/presence/Presence.hpp"
#include "components/recorder/RecorderManager.hpp"
#include "components/recorder/RecorderModel.hpp"
#include "components/timeline/TimelineModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "components/core/event-count-notifier/AbstractEventCountNotifier.hpp"
#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "utils/LinphoneEnums.hpp"



// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
std::shared_ptr<ConferenceInfoModel> ConferenceInfoModel::create(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo){
	std::shared_ptr<ConferenceInfoModel> model = std::make_shared<ConferenceInfoModel>(conferenceInfo);
	if(model){
		//model->mSelf = model;
		 //chatRoom->addListener(model);
		return model;
	}else
		return nullptr;
}

ConferenceInfoModel::ConferenceInfoModel (QObject * parent) : QObject(parent){
	//App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mConferenceInfo = linphone::Factory::get()->createConferenceInfo();
}

ConferenceInfoModel::ConferenceInfoModel (std::shared_ptr<linphone::ConferenceInfo> conferenceInfo, QObject * parent) : QObject(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	
	mConferenceInfo = conferenceInfo;
}

ConferenceInfoModel::~ConferenceInfoModel () {
}

std::shared_ptr<linphone::ConferenceInfo> ConferenceInfoModel::getConferenceInfo(){
	return mConferenceInfo;
}


//------------------------------------------------------------------------------------------------


QDateTime ConferenceInfoModel::getDateTime() const{
	return QDateTime::fromMSecsSinceEpoch(mConferenceInfo->getDateTime() * 1000);
}

int ConferenceInfoModel::getDuration() const{
	int duration = mConferenceInfo->getDuration();
	qWarning() << "Duration: " << duration;
	return duration;
}

QDateTime ConferenceInfoModel::getEndDateTime() const{
	return getDateTime().addSecs(getDuration()*60);
}

QString ConferenceInfoModel::getOrganizer() const{
	return QString::fromStdString(mConferenceInfo->getOrganizer()->asString());
}

QString ConferenceInfoModel::getSubject() const{
	return QString::fromStdString(mConferenceInfo->getSubject());	
}

QString ConferenceInfoModel::getDescription() const{
	return QString::fromStdString(mConferenceInfo->getDescription());
}

QString ConferenceInfoModel::displayNamesToString()const{
	QStringList txt;
	for(auto participant : mConferenceInfo->getParticipants()){
		if(participant){
			QString displayName = Utils::getDisplayName(participant);
			if(displayName != "")
				txt << displayName;
		}
	}
	//txt.removeFirst();// Remove me
	return txt.join(", ");
}

QString ConferenceInfoModel::getUri() const{
	return QString::fromStdString(mConferenceInfo->getUri()->asString());
}

//------------------------------------------------------------------------------------------------

void ConferenceInfoModel::setDateTime(const QDateTime& dateTime){
	mConferenceInfo->setDateTime(dateTime.toMSecsSinceEpoch() / 1000);
	emit dateTimeChanged();
}

void ConferenceInfoModel::setDuration(const int& duration){
	qWarning() << "Set Duration: " << duration;
	mConferenceInfo->setDuration(duration);
	emit durationChanged();
}

void ConferenceInfoModel::setSubject(const QString& subject){
	mConferenceInfo->setSubject(subject.toStdString());
	emit subjectChanged();
}

void ConferenceInfoModel::setOrganizer(const QString& organizerAddress){
	mConferenceInfo->setOrganizer(Utils::interpretUrl(organizerAddress));
	emit organizerChanged();
}

void ConferenceInfoModel::setDescription(const QString& description){
	mConferenceInfo->setDescription(description.toStdString());
	emit descriptionChanged();
}

void ConferenceInfoModel::setParticipants(ParticipantListModel * participants){
	mConferenceInfo->setParticipants(participants->getParticipants());
}
