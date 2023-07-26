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
#include "ParticipantDeviceListener.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"
#include "utils/Utils.hpp"
#include "components/Components.hpp"

void ParticipantDeviceModel::connectTo(ParticipantDeviceListener * listener){
	connect(listener, &ParticipantDeviceListener::isSpeakingChanged, this, &ParticipantDeviceModel::onIsSpeakingChanged);
	connect(listener, &ParticipantDeviceListener::isMuted, this, &ParticipantDeviceModel::onIsMuted);
	connect(listener, &ParticipantDeviceListener::stateChanged, this, &ParticipantDeviceModel::onStateChanged);
	connect(listener, &ParticipantDeviceListener::streamCapabilityChanged, this, &ParticipantDeviceModel::onStreamCapabilityChanged);
	connect(listener, &ParticipantDeviceListener::streamAvailabilityChanged, this, &ParticipantDeviceModel::onStreamAvailabilityChanged);
}

// =============================================================================

ParticipantDeviceModel::ParticipantDeviceModel (CallModel * callModel, std::shared_ptr<linphone::ParticipantDevice> device, const bool& isMe, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mIsMe = isMe;
	mParticipantDevice = device;
	if( device) {
		mParticipantDeviceListener = std::make_shared<ParticipantDeviceListener>();
		connectTo(mParticipantDeviceListener.get());
		device->addListener(mParticipantDeviceListener);
		mState = device->getState();
	}
	mCall = callModel;
	if(mCall)
		connect(mCall, &CallModel::statusChanged, this, &ParticipantDeviceModel::onCallStatusChanged);
	mIsVideoEnabled = false;
	if(mCall && mParticipantDevice)
		updateIsLocal();
	updateVideoEnabled();
}

ParticipantDeviceModel::~ParticipantDeviceModel(){
	if( mParticipantDevice)
		mParticipantDevice->removeListener(mParticipantDeviceListener);
}

QSharedPointer<ParticipantDeviceModel> ParticipantDeviceModel::create(CallModel * callModel, std::shared_ptr<linphone::ParticipantDevice> device, const bool& isMe, QObject *parent){
	QSharedPointer<ParticipantDeviceModel> model = QSharedPointer<ParticipantDeviceModel>::create(callModel, device, isMe, parent);
	if(model){
		model->mSelf = model;
		return model;
	}
	return nullptr;
}

// -----------------------------------------------------------------------------

QString ParticipantDeviceModel::getName() const{
	return mParticipantDevice ? Utils::coreStringToAppString(mParticipantDevice->getName()) : "NoName";
}

QString ParticipantDeviceModel::getDisplayName() const{
	return mParticipantDevice ? Utils::getDisplayName(mParticipantDevice->getAddress()) : "";
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

bool ParticipantDeviceModel::getPaused() const{
	return mIsPaused;
}

bool ParticipantDeviceModel::getIsSpeaking() const{
	return mIsSpeaking;
}

bool ParticipantDeviceModel::getIsMuted() const{
	return mParticipantDevice ? mParticipantDevice->getIsMuted() : false;
}

LinphoneEnums::ParticipantDeviceState ParticipantDeviceModel::getState() const{
	return LinphoneEnums::fromLinphone(mState);
}

std::shared_ptr<linphone::ParticipantDevice> ParticipantDeviceModel::getDevice(){
	return mParticipantDevice;
}

bool ParticipantDeviceModel::isVideoEnabled() const{
	return mIsVideoEnabled;
}

void ParticipantDeviceModel::setPaused(bool paused){
	if(mIsPaused != paused){
		mIsPaused = paused;
		emit isPausedChanged();
	}
}

void ParticipantDeviceModel::setIsSpeaking(bool speaking){
	if(mIsSpeaking != speaking){
		mIsSpeaking = speaking;
		emit isSpeakingChanged();
	}
}

void ParticipantDeviceModel::setIsLocal(bool local){
	if(mIsLocal != local){
		mIsLocal = local;
		emit isLocalChanged();
	}
}

void ParticipantDeviceModel::setState(LinphoneEnums::ParticipantDeviceState state){
	auto newState = LinphoneEnums::toLinphone(state);
	if(mState != newState){
		mState = newState;
		emit stateChanged();
	}
}

void ParticipantDeviceModel::updateVideoEnabled(){
	bool enabled = (mParticipantDevice && mParticipantDevice->isInConference() && mParticipantDevice->getStreamAvailability(linphone::StreamType::Video) && 
		(	mParticipantDevice->getStreamCapability(linphone::StreamType::Video) == linphone::MediaDirection::SendRecv
			|| mParticipantDevice->getStreamCapability(linphone::StreamType::Video) == linphone::MediaDirection::SendOnly
		)
	 || (isMe() && isLocal())) && !mIsPaused;
	 if( mIsVideoEnabled != enabled && mCall && mCall->getCall()->getState() ==  linphone::Call::State::StreamsRunning) {
		qDebug() << "VideoEnabled: " << enabled << ", old=" << mIsVideoEnabled << (mParticipantDevice ? mParticipantDevice->getAddress()->asString().c_str() : "") << ", me=" << isMe() << ", isLocal=" << isLocal() << ", CallState=" << (mCall ? (int)mCall->getCall()->getState() : -1);
		mIsVideoEnabled = enabled;
		emit videoEnabledChanged();
	}
}

bool ParticipantDeviceModel::isMe() const{
	return mIsMe;
}

bool ParticipantDeviceModel::isLocal()const{
	return mIsLocal;
}

void ParticipantDeviceModel::updateIsLocal(){
	auto deviceAddress = mParticipantDevice->getAddress();
	auto callAddress = mCall->getConferenceSharedModel()->getConference()->getMe()->getAddress();
	auto gruuAddress = CoreManager::getInstance()->getAccountSettingsModel()->findAccount(callAddress)->getContactAddress();
	setIsLocal(deviceAddress->equal(gruuAddress));
}

void ParticipantDeviceModel::onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device){
	if(!device || mParticipantDevice && mParticipantDevice->getAddress()->weakEqual(device))
		emit securityLevelChanged();
}

void ParticipantDeviceModel::onCallStatusChanged(){
	if( mCall->getCall()->getState() ==  linphone::Call::State::StreamsRunning){
		updateVideoEnabled();
	}
}

//--------------------------------------------------------------------
void ParticipantDeviceModel::onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isSpeaking) {
	setIsSpeaking(isSpeaking);
}
void ParticipantDeviceModel::onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isMuted) {
	emit isMutedChanged();
}
void ParticipantDeviceModel::onStateChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::ParticipantDevice::State state){
	switch(state){
		case linphone::ParticipantDevice::State::Joining: break;
		case linphone::ParticipantDevice::State::Present: setPaused(false);break;
		case linphone::ParticipantDevice::State::Leaving: break;
		case linphone::ParticipantDevice::State::Left: break;
		case linphone::ParticipantDevice::State::ScheduledForJoining: break;
		case linphone::ParticipantDevice::State::ScheduledForLeaving: break;
		case linphone::ParticipantDevice::State::OnHold: setPaused(true);break;
		case linphone::ParticipantDevice::State::Alerting: break;
		case linphone::ParticipantDevice::State::MutedByFocus: break;
	default:{}
	}
	setState(LinphoneEnums::fromLinphone(state));
	updateVideoEnabled();
}
void ParticipantDeviceModel::onStreamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::MediaDirection direction, linphone::StreamType streamType) {
	updateVideoEnabled();
}
void ParticipantDeviceModel::onStreamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool available, linphone::StreamType streamType) {
	updateVideoEnabled();
}