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

#include "core/App.hpp"
#include "tool/Utils.hpp"
#include <QQmlApplicationEngine>

DEFINE_ABSTRACT_OBJECT(ParticipantDeviceModel)

ParticipantDeviceModel::ParticipantDeviceModel(const std::shared_ptr<linphone::ParticipantDevice> &device,
                                               QObject *parent)
    : ::Listener<linphone::ParticipantDevice, linphone::ParticipantDeviceListener>(device, parent) {
	mustBeInLinphoneThread(getClassName());
}

ParticipantDeviceModel::~ParticipantDeviceModel() {
}

QString ParticipantDeviceModel::getName() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(mMonitor->getName());
}

QString ParticipantDeviceModel::getDisplayName() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(mMonitor->getAddress()->getDisplayName());
}

int ParticipantDeviceModel::getSecurityLevel() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return (int)mMonitor->getSecurityLevel();
}

time_t ParticipantDeviceModel::getTimeOfJoining() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getTimeOfJoining();
}

QString ParticipantDeviceModel::getAddress() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(mMonitor->getAddress()->asStringUriOnly());
}

bool ParticipantDeviceModel::getPaused() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return !mMonitor->isInConference() || mMonitor->getState() == linphone::ParticipantDevice::State::OnHold;
}

bool ParticipantDeviceModel::getIsSpeaking() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getIsSpeaking();
}

bool ParticipantDeviceModel::getIsMuted() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getIsMuted();
}

LinphoneEnums::ParticipantDeviceState ParticipantDeviceModel::getState() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return LinphoneEnums::fromLinphone(mMonitor->getState());
}

bool ParticipantDeviceModel::isVideoEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->isInConference() && mMonitor->getStreamAvailability(linphone::StreamType::Video) &&
	       (mMonitor->getStreamCapability(linphone::StreamType::Video) == linphone::MediaDirection::SendRecv ||
	        mMonitor->getStreamCapability(linphone::StreamType::Video) == linphone::MediaDirection::SendOnly);
}

//--------------------------------------------------------------------
void ParticipantDeviceModel::onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                                 bool isSpeaking) {
	emit isSpeakingChanged(isSpeaking);
}
void ParticipantDeviceModel::onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                       bool isMuted) {
	emit isMutedChanged(isMuted);
}
void ParticipantDeviceModel::onStateChanged(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
                                            linphone::ParticipantDevice::State state) {
	lDebug() << log().arg(Q_FUNC_INFO) << participantDevice->getAddress()->asStringUriOnly() << (int)state;
	emit stateChanged(LinphoneEnums::fromLinphone(state));
}
void ParticipantDeviceModel::onStreamCapabilityChanged(
    const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
    linphone::MediaDirection direction,
    linphone::StreamType streamType) {
	lDebug() << log().arg(Q_FUNC_INFO) << participantDevice->getAddress()->asStringUriOnly() << (int)direction
	         << (int)streamType;
	emit streamCapabilityChanged(streamType);
}
void ParticipantDeviceModel::onStreamAvailabilityChanged(
    const std::shared_ptr<linphone::ParticipantDevice> &participantDevice,
    bool available,
    linphone::StreamType streamType) {
	lDebug() << log().arg(Q_FUNC_INFO) << participantDevice->getAddress()->asStringUriOnly() << available
	         << (int)streamType;
	emit streamAvailabilityChanged(streamType);
}
