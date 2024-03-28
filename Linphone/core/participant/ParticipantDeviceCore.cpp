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
	mName = Utils::coreStringToAppString(device->getName());
	auto deviceAddress = device->getAddress();
	mUniqueAddress = Utils::coreStringToAppString(deviceAddress->asString());
	mAddress = Utils::coreStringToAppString(deviceAddress->asStringUriOnly());
	mDisplayName = Utils::coreStringToAppString(deviceAddress->getDisplayName());
	if (mDisplayName.isEmpty()) {
		auto name = Utils::getDisplayName(mAddress);
		if (name) mDisplayName = name->getValue().toString();
	}
	mIsMuted = device->getIsMuted();
	mIsMe = isMe;
	mIsSpeaking = device->getIsSpeaking();
	mParticipantDeviceModel = Utils::makeQObject_ptr<ParticipantDeviceModel>(device);
	mParticipantDeviceModel->setSelf(mParticipantDeviceModel);
	mState = LinphoneEnums::fromLinphone(device->getState());
	qDebug() << "Address = " << Utils::coreStringToAppString(deviceAddress->asStringUriOnly());
	mIsLocal = ToolModel::findAccount(deviceAddress) != nullptr; // TODO set local
	// mCall = callModel;
	// if (mCall) connect(mCall, &CallModel::statusChanged, this, &ParticipantDeviceCore::onCallStatusChanged);
	mIsVideoEnabled = mParticipantDeviceModel->isVideoEnabled();
	// if (mCall && mParticipantDeviceModel) updateIsLocal();
}

ParticipantDeviceCore::~ParticipantDeviceCore() {
	mParticipantDeviceModel->removeListener();
}

void ParticipantDeviceCore::setSelf(QSharedPointer<ParticipantDeviceCore> me) {
	mParticipantDeviceModelConnection = QSharedPointer<SafeConnection<ParticipantDeviceCore, ParticipantDeviceModel>>(
	    new SafeConnection<ParticipantDeviceCore, ParticipantDeviceModel>(me, mParticipantDeviceModel),
	    &QObject::deleteLater);
	mParticipantDeviceModelConnection->makeConnectToModel(
	    &ParticipantDeviceModel::isPausedChanged, [this](bool paused) {
		    mParticipantDeviceModelConnection->invokeToCore([this, paused] { setPaused(paused); });
	    });
	mParticipantDeviceModelConnection->makeConnectToModel(
	    &ParticipantDeviceModel::isSpeakingChanged, [this](bool speaking) {
		    mParticipantDeviceModelConnection->invokeToCore([this, speaking] { setIsSpeaking(speaking); });
	    });
	mParticipantDeviceModelConnection->makeConnectToModel(&ParticipantDeviceModel::isMutedChanged, [this](bool muted) {
		mParticipantDeviceModelConnection->invokeToCore([this, muted] { setIsMuted(muted); });
	});
	mParticipantDeviceModelConnection->makeConnectToModel(
	    &ParticipantDeviceModel::stateChanged, [this](LinphoneEnums::ParticipantDeviceState state) {
		    mParticipantDeviceModelConnection->invokeToCore([this, state] { setState(state); });
	    });
	mParticipantDeviceModelConnection->makeConnectToModel(
	    &ParticipantDeviceModel::streamCapabilityChanged, [this](linphone::StreamType) {
		    auto videoEnabled = mParticipantDeviceModel->isVideoEnabled();
		    mParticipantDeviceModelConnection->invokeToCore([this, videoEnabled] { setIsVideoEnabled(videoEnabled); });
	    });
	mParticipantDeviceModelConnection->makeConnectToModel(
	    &ParticipantDeviceModel::streamAvailabilityChanged, [this](linphone::StreamType) {
		    auto videoEnabled = mParticipantDeviceModel->isVideoEnabled();
		    mParticipantDeviceModelConnection->invokeToCore([this, videoEnabled] { setIsVideoEnabled(videoEnabled); });
	    });
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

// void ParticipantDeviceCore::updateIsLocal() {
// 	auto deviceAddress = mParticipantDeviceModel->getAddress();
// 	auto callAddress = mCall->getConferenceSharedModel()->getConference()->getMe()->getAddress();
// 	auto gruuAddress =
// 	    CoreManager::getInstance()->getAccountSettingsModel()->findAccount(callAddress)->getContactAddress();
// 	setIsLocal(deviceAddress->equal(gruuAddress));
// }

// void ParticipantDeviceCore::onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device) {
// 	if (!device || mParticipantDeviceModel && mParticipantDeviceModel->getAddress()->weakEqual(device))
// 		emit securityLevelChanged();
// }

// void ParticipantDeviceCore::onCallStatusChanged() {
// 	if (mCall->getCall()->getState() == linphone::Call::State::StreamsRunning) {
// 		updateVideoEnabled();
// 	}
// }

//--------------------------------------------------------------------
void ParticipantDeviceCore::onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                                bool isSpeaking) {
	setIsSpeaking(isSpeaking);
}
void ParticipantDeviceCore::onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                      bool isMuted) {
	emit isMutedChanged();
}
void ParticipantDeviceCore::onStateChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                           linphone::ParticipantDevice::State state) {
	switch (state) {
		case linphone::ParticipantDevice::State::Joining:
			break;
		case linphone::ParticipantDevice::State::Present:
			setPaused(false);
			break;
		case linphone::ParticipantDevice::State::Leaving:
			break;
		case linphone::ParticipantDevice::State::Left:
			break;
		case linphone::ParticipantDevice::State::ScheduledForJoining:
			break;
		case linphone::ParticipantDevice::State::ScheduledForLeaving:
			break;
		case linphone::ParticipantDevice::State::OnHold:
			setPaused(true);
			break;
		case linphone::ParticipantDevice::State::Alerting:
			break;
		case linphone::ParticipantDevice::State::MutedByFocus:
			break;
		default: {
		}
	}
	setState(LinphoneEnums::fromLinphone(state));
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
