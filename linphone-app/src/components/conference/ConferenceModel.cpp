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

#include "ConferenceModel.hpp"
#include "ConferenceListener.hpp"

#include <QQmlApplicationEngine>
#include <QDesktopServices>
#include <QImageReader>
#include <QMessageBox>

#include "app/App.hpp"
#include "components/participant/ParticipantListModel.hpp"
#include "utils/Utils.hpp"


void ConferenceModel::connectTo(ConferenceListener * listener){
	connect(listener, &ConferenceListener::activeSpeakerParticipantDevice, this, &ConferenceModel::onActiveSpeakerParticipantDevice);
	connect(listener, &ConferenceListener::participantAdded, this, &ConferenceModel::onParticipantAdded);
	connect(listener, &ConferenceListener::participantRemoved, this, &ConferenceModel::onParticipantRemoved);
	connect(listener, &ConferenceListener::participantAdminStatusChanged, this, &ConferenceModel::onParticipantAdminStatusChanged);
	connect(listener, &ConferenceListener::participantDeviceAdded, this, &ConferenceModel::onParticipantDeviceAdded);
	connect(listener, &ConferenceListener::participantDeviceRemoved, this, &ConferenceModel::onParticipantDeviceRemoved);
	connect(listener, &ConferenceListener::participantDeviceStateChanged, this, &ConferenceModel::onParticipantDeviceStateChanged);
	connect(listener, &ConferenceListener::participantDeviceMediaCapabilityChanged, this, &ConferenceModel::onParticipantDeviceMediaCapabilityChanged);
	connect(listener, &ConferenceListener::participantDeviceMediaAvailabilityChanged, this, &ConferenceModel::onParticipantDeviceMediaAvailabilityChanged);
	connect(listener, &ConferenceListener::participantDeviceIsSpeakingChanged, this, &ConferenceModel::onParticipantDeviceIsSpeakingChanged);
	connect(listener, &ConferenceListener::conferenceStateChanged, this, &ConferenceModel::onConferenceStateChanged);
	connect(listener, &ConferenceListener::subjectChanged, this, &ConferenceModel::onSubjectChanged);
}

// =============================================================================

QSharedPointer<ConferenceModel> ConferenceModel::create(std::shared_ptr<linphone::Conference> conference, QObject *parent){
	return QSharedPointer<ConferenceModel>::create(conference, parent);
}

ConferenceModel::ConferenceModel (std::shared_ptr<linphone::Conference> conference, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mConference = conference;
	mParticipantListModel = QSharedPointer<ParticipantListModel>::create(this);
	mConferenceListener = std::make_shared<ConferenceListener>();
	connectTo(mConferenceListener.get());
	mConference->addListener(mConferenceListener);
	connect(this, &ConferenceModel::participantDeviceAdded, this, &ConferenceModel::participantDeviceCountChanged);
	connect(this, &ConferenceModel::participantDeviceRemoved, this, &ConferenceModel::participantDeviceCountChanged);
	connect(mParticipantListModel.get(), &ParticipantListModel::participantsChanged, this, &ConferenceModel::participantDeviceCountChanged);
	onConferenceStateChanged(mConference->getState());// Is it already Created like for local conference?
}

ConferenceModel::~ConferenceModel(){
	mConference->removeListener(mConferenceListener);
}

bool ConferenceModel::updateLocalParticipant(){
	bool changed = false;
	if(mConference && mConference->getCall()){
		// First try to use findParticipant
		auto localParticipant = mConference->findParticipant(mConference->getCall()->getCallLog()->getLocalAddress());
		// Me is not in participants, use Me().
		if( !localParticipant)
			localParticipant = mConference->getMe();
		if( localParticipant && (!mLocalParticipant || mLocalParticipant->getParticipant() != localParticipant) ) {
			mLocalParticipant = QSharedPointer<ParticipantModel>::create(localParticipant);
			qDebug() << "Is Admin: " << localParticipant->isAdmin() << " " << mLocalParticipant->getAdminStatus();
			changed = true;
			emit localParticipantChanged();
		}
	}
	return changed;
}

std::shared_ptr<linphone::Conference> ConferenceModel::getConference()const{
	return mConference;
}

QString ConferenceModel::getSubject() const{
	return Utils::coreStringToAppString(mConference->getSubject());
}

QDateTime ConferenceModel::getStartDate() const{
	return QDateTime::fromSecsSinceEpoch(mConference->getStartTime());
}

qint64 ConferenceModel::getElapsedSeconds() const {
	return mConference->getDuration();
}

ParticipantModel* ConferenceModel::getLocalParticipant() const{
	if( mLocalParticipant) {
		qDebug() << "LocalParticipant admin : " << mLocalParticipant->getAdminStatus() << " " << (mLocalParticipant->getParticipant() ? mLocalParticipant->getParticipant()->isAdmin() : -1);
	}else
		qDebug() << "No LocalParticipant";
	return mLocalParticipant.get();
}

ParticipantListModel* ConferenceModel::getParticipantListModel() const{
	return mParticipantListModel.get();
}

std::list<std::shared_ptr<linphone::Participant>> ConferenceModel::getParticipantList()const{
	auto participantList = mConference->getParticipantList();
	auto me = mConference->getMe();
	if( me )
		participantList.push_front(me);
	return participantList;
}

int ConferenceModel::getParticipantDeviceCount() const{
	return mConference->getParticipantDeviceList().size();
}

void ConferenceModel::setIsReady(bool state){
	if( mIsReady != state){
		mIsReady = state;
		emit isReadyChanged();
	}
}
//-----------------------------------------------------------------------------------------------------------------------
//												LINPHONE LISTENERS
//-----------------------------------------------------------------------------------------------------------------------
void ConferenceModel::onActiveSpeakerParticipantDevice(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	emit activeSpeakerParticipantDevice(participantDevice);
}
void ConferenceModel::onParticipantAdded(const std::shared_ptr<const linphone::Participant> & participant){
	qDebug() << "Added call, participant count: " << getParticipantList().size() << ". Me devices : " << mConference->getMe()->getDevices().size();
	updateLocalParticipant();
	emit participantAdded(participant);
}
void ConferenceModel::onParticipantRemoved(const std::shared_ptr<const linphone::Participant> & participant){
	qDebug() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantRemoved(participant);
}
void ConferenceModel::onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Participant> & participant){
	qDebug() << "onParticipantAdminStatusChanged: " << participant->getAddress()->asString().c_str();
	if(mLocalParticipant && participant == mLocalParticipant->getParticipant())
		emit mLocalParticipant->adminStatusChanged();
	emit participantAdminStatusChanged(participant);
}

void ConferenceModel::onParticipantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "Me devices : " << mConference->getMe()->getDevices().size();
	updateLocalParticipant();
	emit participantDeviceAdded(participantDevice);
}
void ConferenceModel::onParticipantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceRemoved(participantDevice);
}

void ConferenceModel::onParticipantDeviceStateChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device, linphone::ParticipantDevice::State state){
	qDebug() << "Me devices : " << mConference->getMe()->getDevices().size();
	updateLocalParticipant();
	emit participantDeviceStateChanged(device, state);
}

void ConferenceModel::onParticipantDeviceMediaCapabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "ConferenceModel::onParticipantDeviceMediaCapabilityChanged: "  << (int)participantDevice->getStreamCapability(linphone::StreamType::Video) << ". Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceMediaCapabilityChanged(participantDevice);
}
void ConferenceModel::onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qDebug() << "ConferenceModel::onParticipantDeviceMediaAvailabilityChanged: "  << (int)participantDevice->getStreamAvailability(linphone::StreamType::Video) << ". Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceMediaAvailabilityChanged(participantDevice);
}
void ConferenceModel::onParticipantDeviceIsSpeakingChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice, bool isSpeaking){
	emit participantDeviceIsSpeakingChanged(participantDevice, isSpeaking);
}
void ConferenceModel::onConferenceStateChanged(linphone::Conference::State newState){
	if(newState == linphone::Conference::State::Created){
		setIsReady(true);
		emit participantDeviceCountChanged();
	}
	updateLocalParticipant();
	emit conferenceStateChanged(newState);
}
void ConferenceModel::onSubjectChanged(const std::string& string){
	emit subjectChanged();
}
	
	
//-----------------------------------------------------------------------------------------------------------------------	
