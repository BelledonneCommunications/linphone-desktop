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

#include "ParticipantDeviceModel.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"
#include "utils/Utils.hpp"
#include "components/Components.hpp"

// =============================================================================

ParticipantDeviceModel::ParticipantDeviceModel (std::shared_ptr<linphone::ParticipantDevice> device, const bool& isMe, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mIsMe = isMe;
	mParticipantDevice = device;
	mCall = nullptr;
}
/*
ParticipantDeviceModel::ParticipantDeviceModel (CallModel * call, const bool& isMe, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mIsMe = isMe;
	mCall = call;
	if( call)
		connect(call, &CallModel::statusChanged, this, &ParticipantDeviceModel::videoEnabledChanged);
}*/

std::shared_ptr<ParticipantDeviceModel> ParticipantDeviceModel::create(std::shared_ptr<linphone::ParticipantDevice> device, const bool& isMe, QObject *parent){
	std::shared_ptr<ParticipantDeviceModel> model = std::make_shared<ParticipantDeviceModel>(device, isMe, parent);
	if(model){
		model->mSelf = model;
		if(device)
			device->addListener(model);
		return model;
	}
	return nullptr;
}
/*
std::shared_ptr<ParticipantDeviceModel> ParticipantDeviceModel::create(CallModel * call, const bool& isMe, QObject *parent){
	std::shared_ptr<ParticipantDeviceModel> model = std::make_shared<ParticipantDeviceModel>(call, isMe, parent);
	if(model){
		model->mSelf = model;
		return model;
	}
	return nullptr;
}*/

// -----------------------------------------------------------------------------

QString ParticipantDeviceModel::getName() const{
	return mParticipantDevice ? Utils::coreStringToAppString(mParticipantDevice->getName()) : "NoName";
}

int ParticipantDeviceModel::getSecurityLevel() const{
	if( mParticipantDevice) {
		int security =  (int)mParticipantDevice->getSecurityLevel();
		return security;
	}else
		return 0;
}

time_t ParticipantDeviceModel::getTimeOfJoining() const{
	return mParticipantDevice ? mParticipantDevice->getTimeOfJoining() : 0;
}

QString ParticipantDeviceModel::getAddress() const{
    return mParticipantDevice ? Utils::coreStringToAppString(mParticipantDevice->getAddress()->asStringUriOnly())
		: "";
}

std::shared_ptr<linphone::ParticipantDevice>  ParticipantDeviceModel::getDevice(){
	return mParticipantDevice;
}

bool ParticipantDeviceModel::isVideoEnabled() const{
	if(mParticipantDevice)
		qWarning() << "VideoEnabled: " << (int)mParticipantDevice->getStreamAvailability(linphone::StreamType::Video);
	return mParticipantDevice && mParticipantDevice->getStreamAvailability(linphone::StreamType::Video);
}

bool ParticipantDeviceModel::isMe() const{
	return mIsMe;
}

void ParticipantDeviceModel::onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device){
	if(!device || mParticipantDevice && mParticipantDevice->getAddress()->weakEqual(device))
		emit securityLevelChanged();
}

//--------------------------------------------------------------------
void ParticipantDeviceModel::onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isSpeaking) {
}
void ParticipantDeviceModel::onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isMuted) {
}
void ParticipantDeviceModel::onConferenceJoined(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice) {
}
void ParticipantDeviceModel::onConferenceLeft(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice) {
}
void ParticipantDeviceModel::onStreamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::MediaDirection direction, linphone::StreamType streamType) {
}
void ParticipantDeviceModel::onStreamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool available, linphone::StreamType streamType) {
	emit videoEnabledChanged();
}