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

#include "ParticipantDeviceCore.hpp"
#include "core/App.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include <QQmlApplicationEngine>

DEFINE_ABSTRACT_OBJECT(ParticipantDeviceCore)

QSharedPointer<ParticipantDeviceCore>
ParticipantDeviceCore::create(std::shared_ptr<linphone::ParticipantDevice> device, const bool &isMe, QObject *parent) {
	auto sharedPointer =
	    QSharedPointer<ParticipantDeviceCore>(new ParticipantDeviceCore(device, isMe, parent), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ParticipantDeviceCore::ParticipantDeviceCore(const std::shared_ptr<linphone::ParticipantDevice> &device,
                                             const bool &isMe,
                                             QObject *parent)
    : QObject(parent) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mustBeInLinphoneThread(getClassName());
	if (device) {
		mName = Utils::coreStringToAppString(device->getName());
		auto deviceAddress = device->getAddress()->clone();
		mUniqueAddress = Utils::coreStringToAppString(deviceAddress->asString());
		mAddress = Utils::coreStringToAppString(deviceAddress->asStringUriOnly());
		// the display name of the device himself may be the uncleaned sip uri
		// Use the participant name instead
		mDisplayName = Utils::coreStringToAppString(device->getParticipant()->getAddress()->getDisplayName());
		if (mDisplayName.isEmpty()) {
			mDisplayName = ToolModel::getDisplayName(deviceAddress);
		}
		mIsMuted = device->getIsMuted();
		mIsSpeaking = device->getIsSpeaking();
		mParticipantDeviceModel = Utils::makeQObject_ptr<ParticipantDeviceModel>(device);
		mParticipantDeviceModel->setSelf(mParticipantDeviceModel);
		mState = LinphoneEnums::fromLinphone(device->getState());
		lDebug() << "Address = " << Utils::coreStringToAppString(deviceAddress->asStringUriOnly());
		mIsLocal = ToolModel::findAccount(deviceAddress) != nullptr; // TODO set local
		mIsVideoEnabled = mParticipantDeviceModel->isVideoEnabled();
		mIsPaused = device->getState() == linphone::ParticipantDevice::State::Left ||
		            device->getState() == linphone::ParticipantDevice::State::OnHold;
	}
	mIsMe = isMe;
}

ParticipantDeviceCore::~ParticipantDeviceCore() {
	if (mParticipantDeviceModel) mParticipantDeviceModel->removeListener();
}

void ParticipantDeviceCore::setSelf(QSharedPointer<ParticipantDeviceCore> me) {
	if (mParticipantDeviceModel) {
		mParticipantDeviceModelConnection =
		    SafeConnection<ParticipantDeviceCore, ParticipantDeviceModel>::create(me, mParticipantDeviceModel);
		mParticipantDeviceModelConnection->makeConnectToModel(
		    &ParticipantDeviceModel::isSpeakingChanged, [this](bool speaking) {
			    mParticipantDeviceModelConnection->invokeToCore([this, speaking] { setIsSpeaking(speaking); });
		    });
		mParticipantDeviceModelConnection->makeConnectToModel(
		    &ParticipantDeviceModel::isMutedChanged, [this](bool muted) {
			    mParticipantDeviceModelConnection->invokeToCore([this, muted] { setIsMuted(muted); });
		    });
		mParticipantDeviceModelConnection->makeConnectToModel(
		    &ParticipantDeviceModel::stateChanged, [this](LinphoneEnums::ParticipantDeviceState state) {
			    onStateChanged(state);
			    mParticipantDeviceModelConnection->invokeToCore(
			        [this, state, isVideoEnabled = mParticipantDeviceModel->isVideoEnabled()] {
				        setState(state);
				        setIsVideoEnabled(isVideoEnabled);
			        });
		    });
		mParticipantDeviceModelConnection->makeConnectToModel(
		    &ParticipantDeviceModel::streamCapabilityChanged, [this](linphone::StreamType) {
			    auto videoEnabled = mParticipantDeviceModel->isVideoEnabled();
			    mParticipantDeviceModelConnection->invokeToCore(
			        [this, videoEnabled] { setIsVideoEnabled(videoEnabled); });
		    });
		mParticipantDeviceModelConnection->makeConnectToModel(
		    &ParticipantDeviceModel::streamAvailabilityChanged, [this](linphone::StreamType) {
			    auto videoEnabled = mParticipantDeviceModel->isVideoEnabled();
			    mParticipantDeviceModelConnection->invokeToCore(
			        [this, videoEnabled] { setIsVideoEnabled(videoEnabled); });
		    });
	}
}

QString ParticipantDeviceCore::getName() const {
	return mName;
}

QString ParticipantDeviceCore::getDisplayName() const {
	return mDisplayName;
}

int ParticipantDeviceCore::getSecurityLevel() const {
	if (mParticipantDeviceModel) {
		int security = (int)mParticipantDeviceModel->getSecurityLevel();
		return security;
	} else return 0;
}

time_t ParticipantDeviceCore::getTimeOfJoining() const {
	return mParticipantDeviceModel ? mParticipantDeviceModel->getTimeOfJoining() : 0;
}

QString ParticipantDeviceCore::getAddress() const {
	return mAddress;
}

QString ParticipantDeviceCore::getUniqueAddress() const {
	return mUniqueAddress;
}

bool ParticipantDeviceCore::getPaused() const {
	return mIsPaused;
}

bool ParticipantDeviceCore::getIsSpeaking() const {
	return mIsSpeaking;
}

bool ParticipantDeviceCore::getIsMuted() const {
	return mIsMuted;
}

LinphoneEnums::ParticipantDeviceState ParticipantDeviceCore::getState() const {
	return mState;
}

bool ParticipantDeviceCore::isVideoEnabled() const {
	return mIsVideoEnabled;
}

void ParticipantDeviceCore::setPaused(bool paused) {
	if (mIsPaused != paused) {
		mIsPaused = paused;
		emit isPausedChanged();
	}
}

void ParticipantDeviceCore::setIsSpeaking(bool speaking) {
	if (mIsSpeaking != speaking) {
		mIsSpeaking = speaking;
		emit isSpeakingChanged();
	}
}

void ParticipantDeviceCore::setIsMuted(bool muted) {
	if (mIsMuted != muted) {
		mIsMuted = muted;
		emit isMutedChanged();
	}
}

void ParticipantDeviceCore::setIsLocal(bool local) {
	if (mIsLocal != local) {
		mIsLocal = local;
		emit isLocalChanged();
	}
}

void ParticipantDeviceCore::setState(LinphoneEnums::ParticipantDeviceState state) {
	if (mState != state) {
		mState = state;
		emit stateChanged();
	}
}

void ParticipantDeviceCore::setIsVideoEnabled(bool enabled) {
	if (mIsVideoEnabled != enabled) {
		mIsVideoEnabled = enabled;
		lDebug() << log().arg(Q_FUNC_INFO) << getAddress() << mIsVideoEnabled;
		emit videoEnabledChanged();
	}
}

bool ParticipantDeviceCore::isMe() const {
	return mIsMe;
}

bool ParticipantDeviceCore::isLocal() const {
	return mIsLocal;
}

std::shared_ptr<ParticipantDeviceModel> ParticipantDeviceCore::getModel() const {
	return mParticipantDeviceModel;
}

//--------------------------------------------------------------------

void ParticipantDeviceCore::onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                                bool isSpeaking) {
	setIsSpeaking(isSpeaking);
}
void ParticipantDeviceCore::onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                      bool isMuted) {
	emit isMutedChanged();
}
void ParticipantDeviceCore::onStateChanged(LinphoneEnums::ParticipantDeviceState state) {
	switch (state) {
		case LinphoneEnums::ParticipantDeviceState::Joining:
			break;
		case LinphoneEnums::ParticipantDeviceState::Present:
			setPaused(false);
			break;
		case LinphoneEnums::ParticipantDeviceState::Leaving:
			break;
		case LinphoneEnums::ParticipantDeviceState::Left:
			break;
		case LinphoneEnums::ParticipantDeviceState::ScheduledForJoining:
			break;
		case LinphoneEnums::ParticipantDeviceState::ScheduledForLeaving:
			break;
		case LinphoneEnums::ParticipantDeviceState::OnHold:
			setPaused(true);
			break;
		case LinphoneEnums::ParticipantDeviceState::Alerting:
			break;
		case LinphoneEnums::ParticipantDeviceState::MutedByFocus:
			break;
		default: {
		}
	}
	setState(state);
}
void ParticipantDeviceCore::onStreamCapabilityChanged(
    const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
    linphone::MediaDirection direction,
    linphone::StreamType streamType) {
}
void ParticipantDeviceCore::onStreamAvailabilityChanged(
    const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
    bool available,
    linphone::StreamType streamType) {
}
