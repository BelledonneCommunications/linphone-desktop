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
#include "components/calls/CallsListModel.hpp"
#include "components/conferenceScheduler/ConferenceScheduler.hpp"
#include "components/core/CoreManager.hpp"
#include "components/other/timeZone/TimeZoneModel.hpp"
#include "components/participant/ParticipantListModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "utils/LinphoneEnums.hpp"
#include "utils/Utils.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
QSharedPointer<ConferenceInfoModel> ConferenceInfoModel::create(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo){
	if(conferenceInfo)
		return QSharedPointer<ConferenceInfoModel>::create(conferenceInfo);
	else
		return nullptr;
}

// Callable from QML
ConferenceInfoModel::ConferenceInfoModel (QObject * parent) : QObject(parent){
	mConferenceInfo = linphone::Factory::get()->createConferenceInfo();
	mIsScheduled = false;
	if(CoreManager::getInstance()->getSettingsModel()->getSecureChatEnabled())
		mConferenceInfo->setSecurityLevel(linphone::Conference::SecurityLevel::EndToEnd);
	initDateTime();
	auto defaultAccount = CoreManager::getInstance()->getCore()->getDefaultAccount();
	if(defaultAccount){
		std::shared_ptr<const linphone::Address> accountAddress = defaultAccount->getContactAddress();
		if(!accountAddress)
			accountAddress = defaultAccount->getParams()->getIdentityAddress();
		if(accountAddress){
			auto cleanedClonedAddress = accountAddress->clone();
			cleanedClonedAddress->clean();
			mConferenceInfo->setOrganizer(cleanedClonedAddress);
		}
	}
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
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::conferenceSchedulerStateChanged);
	
	mCheckEndTimer.callOnTimeout(this, [this]()mutable{setIsEnded(getIsEnded());});
	mCheckEndTimer.setInterval(10000);	// 10s of reaction in order to not overload processes if many calendar
	mIsEnded = getIsEnded();
	if(!mIsEnded)
		mCheckEndTimer.start();
}

// Callable from C++
ConferenceInfoModel::ConferenceInfoModel (std::shared_ptr<linphone::ConferenceInfo> conferenceInfo, QObject * parent) : QObject(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mConferenceInfo = conferenceInfo;
	mIsScheduled = (mConferenceInfo->getDateTime() != 0 || mConferenceInfo->getDuration() != 0);
	
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
	connect(this, &ConferenceInfoModel::conferenceInfoChanged, this, &ConferenceInfoModel::conferenceSchedulerStateChanged);
	
	mCheckEndTimer.callOnTimeout(this, [this]()mutable{setIsEnded(getIsEnded());});
	mCheckEndTimer.setInterval(10000);	// 10s of reaction in order to not overload processes if many calendar.
	mIsEnded = getIsEnded();
	if(!mIsEnded)
		mCheckEndTimer.start();
}

ConferenceInfoModel::~ConferenceInfoModel () {
	mCheckEndTimer.stop();
}

std::shared_ptr<linphone::ConferenceInfo> ConferenceInfoModel::getConferenceInfo(){
	return mConferenceInfo;
}

std::shared_ptr<linphone::ConferenceInfo> ConferenceInfoModel::findConferenceInfo(const std::shared_ptr<const linphone::ConferenceInfo> & conferenceInfo){
	return CoreManager::getInstance()->getCore()->findConferenceInformationFromUri(conferenceInfo->getUri()->clone());
}

//------------------------------------------------------------------------------------------------

void ConferenceInfoModel::initDateTime(){
	if(!mIsScheduled){
		setDateTime(QDateTime::fromMSecsSinceEpoch(0));
		setDuration(0);
	}else{
		setDateTime(QDateTime::currentDateTimeUtc());
		setDuration(60);
	}
}

//Note conferenceInfo->getDateTime uses UTC
QDateTime ConferenceInfoModel::getDateTimeUtc() const{
	return getDateTimeSystem().toUTC();
}

QDateTime ConferenceInfoModel::getDateTimeSystem() const{
	return QDateTime::fromMSecsSinceEpoch(mConferenceInfo->getDateTime() * 1000, Qt::LocalTime);
}

int ConferenceInfoModel::getDuration() const{
	return mConferenceInfo->getDuration();
}

QDateTime ConferenceInfoModel::getEndDateTime() const{
	return getDateTimeSystem().addSecs(getDuration()*60);
}

QDateTime ConferenceInfoModel::getEndDateTimeUtc() const{
	return getDateTimeUtc().addSecs(getDuration()*60);
}

QString ConferenceInfoModel::getOrganizer() const{
	return Utils::coreStringToAppString(mConferenceInfo->getOrganizer() ? mConferenceInfo->getOrganizer()->asString() : "Self");
}

QString ConferenceInfoModel::getSubject() const{
	return Utils::coreStringToAppString(mConferenceInfo->getSubject());
}

QString ConferenceInfoModel::getDescription() const{
	return Utils::coreStringToAppString(mConferenceInfo->getDescription());
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
	return address && address->isValid() && !address->getDomain().empty() ? QString::fromStdString(address->asStringUriOnly()) : "";
}

bool ConferenceInfoModel::isScheduled() const{
	return mIsScheduled;
}

bool ConferenceInfoModel::isEnded() const{
	return mIsEnded;
}

bool ConferenceInfoModel::isSecured() const{
	return mConferenceInfo ? mConferenceInfo->getSecurityLevel() != linphone::Conference::SecurityLevel::None
		: CoreManager::getInstance()->getSettingsModel()->getSecureChatEnabled();
}

bool ConferenceInfoModel::getIsEnded() const{
	return getEndDateTimeUtc() < QDateTime::currentDateTimeUtc();
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
QVariantList ConferenceInfoModel::getAllParticipants() const{
	QVariantList addresses = getParticipants();
	QString organizerAddress = QString::fromStdString(mConferenceInfo->getOrganizer()->asStringUriOnly());
	for(auto item : addresses){
		if( item.toMap()["address"] == organizerAddress)
			return addresses;
	}
	QVariantMap participant;
	participant["displayName"] = Utils::getDisplayName(mConferenceInfo->getOrganizer());
	participant["address"] = organizerAddress;
	addresses << participant;
	return addresses;
}


int ConferenceInfoModel::getParticipantCount()const{
	return mConferenceInfo->getParticipants().size();
}

int ConferenceInfoModel::getAllParticipantCount()const{
	return getAllParticipants().size();
}

TimeZoneModel* ConferenceInfoModel::getTimeZoneModel() const{
	TimeZoneModel * model = new TimeZoneModel(QTimeZone::systemTimeZone());// Always return system timezone because this info is not stored in database. 
	App::getInstance()->getEngine()->setObjectOwnership(model, QQmlEngine::JavaScriptOwnership);
	return model;
}

QString ConferenceInfoModel::getIcalendarString() const{
	return Utils::coreStringToAppString(mConferenceInfo->getIcalendarString());
}

LinphoneEnums::ConferenceInfoState ConferenceInfoModel::getConferenceInfoState() const{
	return LinphoneEnums::fromLinphone(mConferenceInfo->getState());
}

LinphoneEnums::ConferenceSchedulerState ConferenceInfoModel::getConferenceSchedulerState() const{
	return LinphoneEnums::fromLinphone(mLastConferenceSchedulerState);
}

//------------------------------------------------------------------------------------------------
// Datetime is in Custom (Locale/UTC/System). Convert into UTC for conference info
void ConferenceInfoModel::setDateTime(const QDateTime& dateTime){
	mConferenceInfo->setDateTime(dateTime.toMSecsSinceEpoch() / 1000);// toMSecsSinceEpoch() is UTC
	setIsEnded(getIsEnded());
	emit dateTimeChanged();
}

void ConferenceInfoModel::setDateTime(const QDate& date, const QTime& time, TimeZoneModel * model){
	setIsScheduled(true);
	setDateTime(QDateTime(date, time, model->getTimeZone()));
}

void ConferenceInfoModel::setDateTimeStr(const QString& date, const QString& time, TimeZoneModel * model){
	setIsScheduled(true);
	QDateTime t = QDateTime::fromString(date + " " +time, "yyyy/MM/dd hh:mm:ss");
	t.setTimeZone(model->getTimeZone());
	setDateTime(t);
}


void ConferenceInfoModel::setDuration(const int& duration){
	mConferenceInfo->setDuration(duration);
	setIsEnded(getIsEnded());
	emit durationChanged();
}

void ConferenceInfoModel::setSubject(const QString& subject){
	mConferenceInfo->setSubject(Utils::appStringToCoreString(subject));
	emit subjectChanged();
}

void ConferenceInfoModel::setOrganizer(const QString& organizerAddress){
	mConferenceInfo->setOrganizer(Utils::interpretUrl(organizerAddress));
	emit organizerChanged();
}

void ConferenceInfoModel::setDescription(const QString& description){
	mConferenceInfo->setDescription(Utils::appStringToCoreString(description));
	emit descriptionChanged();
}

void ConferenceInfoModel::setParticipants(ParticipantListModel * participants){
	mConferenceInfo->setParticipants(participants->getParticipants());
	emit participantsChanged();
}

void ConferenceInfoModel::setIsScheduled(const bool& on){
	if( mIsScheduled != on){
		mIsScheduled = on;
		emit isScheduledChanged();
	}
}

void ConferenceInfoModel::setIsEnded(const bool& end){
	if( mIsEnded != end){
		mIsEnded = end;
		if(mIsEnded)
			mCheckEndTimer.stop();// No need to run the timer.
		else
			mCheckEndTimer.start();
		emit isEndedChanged();
	}
}

void ConferenceInfoModel::setIsSecured(const bool& on){
	if( on != isSecured()){
		if(mConferenceInfo)
			mConferenceInfo->setSecurityLevel(on ? linphone::Conference::SecurityLevel::EndToEnd : linphone::Conference::SecurityLevel::None);
		emit isSecuredChanged();
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

void ConferenceInfoModel::resetConferenceInfo() {
	mConferenceInfo = linphone::Factory::get()->createConferenceInfo();
	mIsScheduled = false;
	initDateTime();
	auto defaultAccount = CoreManager::getInstance()->getCore()->getDefaultAccount();
	if(defaultAccount){
		auto accountAddress = defaultAccount->getContactAddress();
		if(accountAddress){
			auto cleanedClonedAddress = accountAddress->clone();
			cleanedClonedAddress->clean();
			mConferenceInfo->setOrganizer(cleanedClonedAddress);
		}
	}
}

void ConferenceInfoModel::createConference() {
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = false;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	static std::shared_ptr<linphone::Conference> conference;
	mConferenceInfo->setSecurityLevel(linphone::Conference::SecurityLevel::None); // TODO: remove when conferences can be encrypted
	qInfo() << "Conference creation of " << getSubject() << " at " << (int)mConferenceInfo->getSecurityLevel() << " security, organized by " << getOrganizer() << " for " << getDateTimeSystem().toString();
	qInfo() << "Participants:";
	for(auto p : mConferenceInfo->getParticipants())
		qInfo() << "\t" << p->asString().c_str();

	if(isScheduled()) {
		mConferenceScheduler = ConferenceScheduler::create();
		mConferenceScheduler->mSendInvite = mInviteMode;
		connect(mConferenceScheduler.get(), &ConferenceScheduler::invitationsSent, this, &ConferenceInfoModel::onInvitationsSent);
		connect(mConferenceScheduler.get(), &ConferenceScheduler::stateChanged, this, &ConferenceInfoModel::onConferenceSchedulerStateChanged);
		mConferenceScheduler->getConferenceScheduler()->setInfo(mConferenceInfo);
	}else {
		// Since SDK 5.4, unscheduled conference must be created from a group call.
		auto callListModel = CoreManager::getInstance()->getCallsListModel();
		auto settingsModel = CoreManager::getInstance()->getSettingsModel();
		bool videoEnabled = CoreManager::getInstance()->getSettingsModel()->getVideoConferenceEnabled() &&  settingsModel->getVideoConferenceEnabled();

		auto parameters = core->createConferenceParams(nullptr);
		if(!CoreManager::getInstance()->getSettingsModel()->getVideoConferenceEnabled()) {
			parameters->enableVideo(false);
			parameters->setConferenceFactoryAddress(nullptr);// Do a local conference
		}else {
			parameters->enableVideo(videoEnabled);
			conference = core->createConferenceWithParams(parameters);
		}
		if(!conference) emit conferenceCreationFailed();
		else {
			auto callParameters = CoreManager::getInstance()->getCore()->createCallParams(nullptr);
			callParameters->enableVideo(videoEnabled);
			if(!conference->inviteParticipants(mConferenceInfo->getParticipants(), callParameters)) {
				emit conferenceCreated();
			}else{
				emit conferenceCreationFailed();
			}
		}
	}
}

void ConferenceInfoModel::cancelConference(){
	mConferenceScheduler = ConferenceScheduler::create();
	connect(mConferenceScheduler.get(), &ConferenceScheduler::invitationsSent, this, &ConferenceInfoModel::onInvitationsSent);
	connect(mConferenceScheduler.get(), &ConferenceScheduler::stateChanged, this, &ConferenceInfoModel::onConferenceSchedulerStateChanged);
	mConferenceScheduler->getConferenceScheduler()->cancelConference(mConferenceInfo);
}

void ConferenceInfoModel::deleteConferenceInfo(){
	if(mConferenceInfo) {
		CoreManager::getInstance()->getCore()->deleteConferenceInformation(mConferenceInfo);
		emit removed(true);
	}
}

//-------------------------------------------------------------------------------------------------

void ConferenceInfoModel::onConferenceSchedulerStateChanged(linphone::ConferenceScheduler::State state){
	qDebug() << "ConferenceInfoModel::onConferenceSchedulerStateChanged: " << (int) state;
	mLastConferenceSchedulerState = state;
	if( state == linphone::ConferenceScheduler::State::Ready)
		emit conferenceCreated();
	else if( state == linphone::ConferenceScheduler::State::Error)
		emit conferenceCreationFailed();
	emit conferenceInfoChanged();
}
void ConferenceInfoModel::onInvitationsSent(const std::list<std::shared_ptr<linphone::Address>> & failedInvitations) {
	qDebug() << "ConferenceInfoModel::onInvitationsSent";
	emit invitationsSent();
}
