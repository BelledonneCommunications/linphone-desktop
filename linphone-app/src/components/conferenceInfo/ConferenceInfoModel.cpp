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
#include "components/conferenceScheduler/ConferenceScheduler.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/other/timeZone/TimeZoneModel.hpp"
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
QSharedPointer<ConferenceInfoModel> ConferenceInfoModel::create(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo){
	return QSharedPointer<ConferenceInfoModel>::create(conferenceInfo);
}

// Callable from QML
ConferenceInfoModel::ConferenceInfoModel (QObject * parent) : QObject(parent){
	mTimeZone = QTimeZone::systemTimeZone();
	mConferenceInfo = linphone::Factory::get()->createConferenceInfo();
	QDateTime currentDateTime = QDateTime::currentDateTime();
	QDateTime utc = currentDateTime.addSecs( -mTimeZone.offsetFromUtc(currentDateTime));
	mConferenceInfo->setDateTime(0);
	mConferenceInfo->setDuration(0);
	mIsScheduled = false;
	auto accountAddress = CoreManager::getInstance()->getCore()->getDefaultAccount()->getContactAddress();
	if(accountAddress){
		auto cleanedClonedAddress = accountAddress->clone();
		cleanedClonedAddress->clean();
		mConferenceInfo->setOrganizer(cleanedClonedAddress);
	}
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::timeZoneModelChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::dateTimeChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::durationChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::organizerChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::subjectChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::descriptionChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::participantsChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::uriChanged);// Useless but just in case.
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::isScheduledChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::inviteModeChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::conferenceInfoStateChanged);
}

// Callable from C++
ConferenceInfoModel::ConferenceInfoModel (std::shared_ptr<linphone::ConferenceInfo> conferenceInfo, QObject * parent) : QObject(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mTimeZone = QTimeZone::systemTimeZone();
	mConferenceInfo = conferenceInfo;
	mIsScheduled = (mConferenceInfo->getDateTime() != 0 || mConferenceInfo->getDuration() != 0);
	
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::timeZoneModelChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::dateTimeChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::durationChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::organizerChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::subjectChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::descriptionChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::participantsChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::uriChanged);// Useless but just in case.
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::isScheduledChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::inviteModeChanged);
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::conferenceInfoStateChanged);
}

ConferenceInfoModel::~ConferenceInfoModel () {
}

std::shared_ptr<linphone::ConferenceInfo> ConferenceInfoModel::getConferenceInfo(){
	return mConferenceInfo;
}

std::shared_ptr<linphone::ConferenceInfo> ConferenceInfoModel::findConferenceInfo(const std::shared_ptr<const linphone::ConferenceInfo> & conferenceInfo){
	return CoreManager::getInstance()->getCore()->findConferenceInformationFromUri(conferenceInfo->getUri()->clone());
}

//------------------------------------------------------------------------------------------------


QDateTime ConferenceInfoModel::getDateTimeUtc() const{
	return QDateTime::fromMSecsSinceEpoch(mConferenceInfo->getDateTime() * 1000).toUTC();
}

QDateTime ConferenceInfoModel::getDateTimeSystem() const{
	QDateTime utc = getDateTimeUtc();
	return utc.addSecs(QTimeZone::systemTimeZone().offsetFromUtc(utc));
}

int ConferenceInfoModel::getDuration() const{
	return mConferenceInfo->getDuration();
}

QDateTime ConferenceInfoModel::getEndDateTime() const{
	return getDateTimeUtc().addSecs(getDuration()*60);
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
	return txt.join(", ");
}

QString ConferenceInfoModel::getUri() const{
	auto address = mConferenceInfo->getUri();
	return address->isValid() && !address->getDomain().empty() ? QString::fromStdString(address->asStringUriOnly()) : "";
}

bool ConferenceInfoModel::isScheduled() const{
	return mIsScheduled;
}

int ConferenceInfoModel::getInviteMode() const{
	return mInviteMode;
}

QVariantList ConferenceInfoModel::getParticipants() const{
	QVariantList addresses;
	for(auto item : mConferenceInfo->getParticipants()){
		QVariantMap participant;
		participant["displayName"] = Utils::getDisplayName(item);
		participant["address"] = QString::fromStdString(item->asStringUriOnly());
		addresses << participant;
	}
	return addresses;
}

int ConferenceInfoModel::getParticipantCount()const{
	return mConferenceInfo->getParticipants().size();
}

TimeZoneModel* ConferenceInfoModel::getTimeZoneModel() const{
	TimeZoneModel * model = new TimeZoneModel(mTimeZone);
	App::getInstance()->getEngine()->setObjectOwnership(model, QQmlEngine::JavaScriptOwnership);
	return model;
}

QString ConferenceInfoModel::getIcalendarString() const{
	return Utils::coreStringToAppString(mConferenceInfo->getIcalendarString());
}

LinphoneEnums::ConferenceInfoState ConferenceInfoModel::getConferenceInfoState() const{
	return LinphoneEnums::fromLinphone(mConferenceInfo->getState());
}

//------------------------------------------------------------------------------------------------
// Convert into UTC with TimeZone and pass system timezone to conference info
void ConferenceInfoModel::setDateTime(const QDateTime& dateTime){
	QDateTime utc = dateTime.addSecs( -mTimeZone.offsetFromUtc(dateTime));
	QDateTime system = utc.addSecs(QTimeZone::systemTimeZone().offsetFromUtc(utc));
	mConferenceInfo->setDateTime(system.toMSecsSinceEpoch() / 1000);
	emit dateTimeChanged();
}

void ConferenceInfoModel::setDuration(const int& duration){
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

void ConferenceInfoModel::setTimeZoneModel(TimeZoneModel * model){
	if( mTimeZone != model->getTimeZone()){
		mTimeZone = model->getTimeZone();
		emit timeZoneModelChanged();
	}
}

void ConferenceInfoModel::setIsScheduled(const bool& on){
	if( mIsScheduled != on){
		mIsScheduled = on;
		if(!mIsScheduled){
			mConferenceInfo->setDateTime(0);
			mConferenceInfo->setDuration(0);
		}else{
			mTimeZone = QTimeZone::systemTimeZone();
			QDateTime currentDateTime = QDateTime::currentDateTime();
			QDateTime utc = currentDateTime.addSecs( -mTimeZone.offsetFromUtc(currentDateTime));
			mConferenceInfo->setDateTime(utc.toMSecsSinceEpoch() / 1000);
			mConferenceInfo->setDuration(1200);
		}
		emit dateTimeChanged();
		emit durationChanged();
		emit isScheduledChanged();
	}
}

void ConferenceInfoModel::setInviteMode(const int& mode){
	if( mode != mInviteMode){
		mInviteMode = mode;
		emit inviteModeChanged();
	}
}

void ConferenceInfoModel::setConferenceInfo(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo){
	mConferenceInfo = conferenceInfo;
	mIsScheduled = (mConferenceInfo->getDateTime() != 0 || mConferenceInfo->getDuration() != 0);
	emit conferenceInfoChanged();
}

//-------------------------------------------------------------------------------------------------

void ConferenceInfoModel::createConference(const int& securityLevel) {
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = false;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	static std::shared_ptr<linphone::Conference> conference;
	qInfo() << "Conference creation of " << getSubject() << " at " << securityLevel << " security, organized by " << getOrganizer();
	qInfo() << "Participants:";
	for(auto p : mConferenceInfo->getParticipants())
		qInfo() << "\t" << p->asString().c_str();
	
	
	mConferenceScheduler = ConferenceScheduler::create();
	mConferenceScheduler->mSendInvite = mInviteMode;
	connect(mConferenceScheduler.get(), &ConferenceScheduler::invitationsSent, this, &ConferenceInfoModel::onInvitationsSent);
	connect(mConferenceScheduler.get(), &ConferenceScheduler::stateChanged, this, &ConferenceInfoModel::onStateChanged);
	mConferenceScheduler->getConferenceScheduler()->setInfo(mConferenceInfo);
}

void ConferenceInfoModel::deleteConferenceInfo(){
	if(mConferenceInfo) {
		CoreManager::getInstance()->getCore()->deleteConferenceInformation(mConferenceInfo);
		emit removed(true);
	}
}

//-------------------------------------------------------------------------------------------------

void ConferenceInfoModel::onStateChanged(linphone::ConferenceSchedulerState state){
	qDebug() << "ConferenceInfoModel::onStateChanged: " << (int) state;
	if( state == linphone::ConferenceSchedulerState::Ready)
		emit conferenceCreated();
	else if( state == linphone::ConferenceSchedulerState::Error)
		emit conferenceCreationFailed();
}
void ConferenceInfoModel::onInvitationsSent(const std::list<std::shared_ptr<linphone::Address>> & failedInvitations) {
	qDebug() << "ConferenceInfoModel::onInvitationsSent";
	emit invitationsSent();
}
