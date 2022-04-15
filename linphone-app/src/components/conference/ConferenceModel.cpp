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
#include "app/paths/Paths.hpp"
#include "app/providers/ThumbnailProvider.hpp"


#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "components/Components.hpp"

void ConferenceModel::connectTo(ConferenceListener * listener){
	connect(listener, &ConferenceListener::participantAdded, this, &ConferenceModel::onParticipantAdded);
	connect(listener, &ConferenceListener::participantRemoved, this, &ConferenceModel::onParticipantRemoved);
	connect(listener, &ConferenceListener::participantDeviceAdded, this, &ConferenceModel::onParticipantDeviceAdded);
	connect(listener, &ConferenceListener::participantDeviceRemoved, this, &ConferenceModel::onParticipantDeviceRemoved);
	connect(listener, &ConferenceListener::participantDeviceLeft, this, &ConferenceModel::onParticipantDeviceLeft);
	connect(listener, &ConferenceListener::participantDeviceJoined, this, &ConferenceModel::onParticipantDeviceJoined);
	connect(listener, &ConferenceListener::participantDeviceMediaAvailabilityChanged, this, &ConferenceModel::onParticipantDeviceMediaAvailabilityChanged);
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
	mConferenceListener = std::make_shared<ConferenceListener>();
	connectTo(mConferenceListener.get());
	mConference->addListener(mConferenceListener);
}

ConferenceModel::~ConferenceModel(){
	mConference->removeListener(mConferenceListener);
}

std::shared_ptr<linphone::Conference> ConferenceModel::getConference()const{
	return mConference;
}

QString ConferenceModel::getSubject() const{
	return QString::fromStdString(mConference->getSubject());
}

QDateTime ConferenceModel::getStartDate() const{
	return QDateTime::fromSecsSinceEpoch(mConference->getStartTime());
}

qint64 ConferenceModel::getElapsedSeconds() const {
	return getStartDate().secsTo(QDateTime::currentDateTime());
}

//-----------------------------------------------------------------------------------------------------------------------
//												LINPHONE LISTENERS
//-----------------------------------------------------------------------------------------------------------------------
void ConferenceModel::onParticipantAdded(const std::shared_ptr<const linphone::Participant> & participant){
	qWarning() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantAdded(participant);
}
void ConferenceModel::onParticipantRemoved(const std::shared_ptr<const linphone::Participant> & participant){
	qWarning() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantRemoved(participant);
}
void ConferenceModel::onParticipantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceAdded(participantDevice);
}
void ConferenceModel::onParticipantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceRemoved(participantDevice);
}
void ConferenceModel::onParticipantDeviceLeft(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceLeft(participantDevice);
}
void ConferenceModel::onParticipantDeviceJoined(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceJoined(participantDevice);
}
void ConferenceModel::onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "ConferenceModel::onParticipantDeviceMediaAvailabilityChanged: "  << (int)participantDevice->getStreamAvailability(linphone::StreamType::Video) << ". Me devices : " << mConference->getMe()->getDevices().size();
	emit participantDeviceMediaAvailabilityChanged(participantDevice);
}
void ConferenceModel::onConferenceStateChanged(linphone::Conference::State newState){
	emit conferenceStateChanged(newState);
}
void ConferenceModel::onSubjectChanged(const std::string& string){
	emit subjectChanged();
}
	
	
//-----------------------------------------------------------------------------------------------------------------------	