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

// =============================================================================
std::shared_ptr<ConferenceModel> ConferenceModel::create(std::shared_ptr<linphone::Conference> conference, QObject *parent){
	std::shared_ptr<ConferenceModel> model = std::make_shared<ConferenceModel>(conference, parent);
	if(model){
		model->mSelf = model;
		conference->addListener(model);
		return model;
	}
	return nullptr;
}

ConferenceModel::ConferenceModel (std::shared_ptr<linphone::Conference> conference, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mConference = conference;
}

ConferenceModel::~ConferenceModel(){
	//mChatRoomModel->getChatRoom()->removeListener(mChatRoomModel);
}

std::shared_ptr<linphone::Conference> ConferenceModel::getConference()const{
	return mConference;
}

//-----------------------------------------------------------------------------------------------------------------------
//												LINPHONE LISTENERS
//-----------------------------------------------------------------------------------------------------------------------
void ConferenceModel::onParticipantAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qWarning() << "onParticipantAdded is not yet implemented.";
}
void ConferenceModel::onParticipantRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
	qWarning() << "onParticipantRemoved is not yet implemented.";
}
void ConferenceModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	emit participantDeviceAdded(participantDevice);
}
void ConferenceModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	emit participantDeviceRemoved(participantDevice);
}
void ConferenceModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant){
}
void ConferenceModel::onParticipantDeviceLeft(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	emit participantDeviceLeft(participantDevice);
}
void ConferenceModel::onParticipantDeviceJoined(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	emit participantDeviceJoined(participantDevice);
}
void ConferenceModel::onParticipantDeviceMediaChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device){
	qWarning() << "onParticipantDeviceMediaChanged is not yet implemented.";
}
void ConferenceModel::onStateChanged(const std::shared_ptr<linphone::Conference> & conference, linphone::Conference::State newState){
	qWarning() << "onStateChanged is not yet implemented.";
}
void ConferenceModel::onSubjectChanged(const std::shared_ptr<linphone::Conference> & conference, const std::string & subject){
	qWarning() << "onSubjectChanged is not yet implemented.";
}
void ConferenceModel::onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::AudioDevice> & audioDevice){
	qWarning() << "onAudioDeviceChanged is not yet implemented.";
}
	
	
//-----------------------------------------------------------------------------------------------------------------------	