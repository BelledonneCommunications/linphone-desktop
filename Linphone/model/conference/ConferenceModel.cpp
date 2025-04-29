/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include <QDebug>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceModel)

std::shared_ptr<ConferenceModel> ConferenceModel::create(const std::shared_ptr<linphone::Conference> &conference) {
	auto model = Utils::makeQObject_ptr<ConferenceModel>(conference);
	model->setSelf(model);
	return model;
}

ConferenceModel::ConferenceModel(const std::shared_ptr<linphone::Conference> &conference, QObject *parent)
    : ::Listener<linphone::Conference, linphone::ConferenceListener>(conference, parent) {
	mustBeInLinphoneThread(getClassName());
	lDebug() << "[ConferenceModel] new " << this << ", SDKModel=" << conference.get();
	connect(this, &ConferenceModel::isScreenSharingEnabledChanged, this,
	        &ConferenceModel::onIsScreenSharingEnabledChanged);
}

ConferenceModel::~ConferenceModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void ConferenceModel::terminate() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->terminate();
}

void ConferenceModel::removeParticipant(const std::shared_ptr<linphone::Participant> &p) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->removeParticipant(p);
}

void ConferenceModel::removeParticipant(const std::shared_ptr<linphone::Address> &address) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	for (auto &p : mMonitor->getParticipantList()) {
		if (address->asStringUriOnly() == p->getAddress()->asStringUriOnly()) {
			mMonitor->removeParticipant(p);
		}
	}
}

void ConferenceModel::addParticipant(const std::shared_ptr<linphone::Address> &address) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->addParticipant(address);
}

int ConferenceModel::getParticipantDeviceCount() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getParticipantDeviceList().size();
}

std::shared_ptr<linphone::ChatRoom> ConferenceModel::getChatRoom() const {
	return mMonitor->getChatRoom();
}

void ConferenceModel::setMicrophoneMuted(bool isMuted) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setMicrophoneMuted(isMuted);
	emit microphoneMutedChanged(isMuted);
}

void ConferenceModel::startRecording() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	// mMonitor->startRecording(mMonitor->getCurrentParams()->getRecordFile());
	// emit recordingChanged(mMonitor->getParams()->isRecording());
}

void ConferenceModel::stopRecording() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->stopRecording();
}

void ConferenceModel::setRecordFile(const std::string &path) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	// auto params = core->createCallParams(mMonitor);
	// params->setRecordFile(path);
	// mMonitor->update(params);
}

void ConferenceModel::setParticipantAdminStatus(const std::shared_ptr<linphone::Participant> participant, bool status) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setParticipantAdminStatus(participant, status);
}

void ConferenceModel::setInputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setInputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit inputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> ConferenceModel::getInputAudioDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getInputAudioDevice();
}

void ConferenceModel::setOutputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setOutputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit outputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> ConferenceModel::getOutputAudioDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getOutputAudioDevice();
}

void ConferenceModel::toggleScreenSharing() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto device = mMonitor->getScreenSharingParticipantDevice();

	if (!device || ToolModel::isLocal(mMonitor, device)) {
		bool enable = !device;
		auto params = CoreModel::getInstance()->getCore()->createCallParams(mMonitor->getCall());
		params->enableScreenSharing(enable);
		if (enable) {
			params->setConferenceVideoLayout(linphone::Conference::Layout::ActiveSpeaker);
			params->enableVideo(true);
			auto videoDirection = params->getVideoDirection();
			params->setVideoDirection(videoDirection == linphone::MediaDirection::RecvOnly ||
			                                  videoDirection == linphone::MediaDirection::SendRecv
			                              ? linphone::MediaDirection::SendRecv
			                              : linphone::MediaDirection::SendOnly);
		}
		if (params->isValid()) {
			lInfo() << log()
			               .arg("Toggling screen sharing %1, direction=%2")
			               .arg(enable)
			               .arg((int)params->getVideoDirection());
			mMonitor->getCall()->update(params);
		} else lCritical() << log().arg("Cannot toggle screen sharing because parameters are invalid");
	}
}

bool ConferenceModel::isLocalScreenSharing() const {
	auto device = mMonitor->getScreenSharingParticipantDevice();
	return device && ToolModel::isLocal(mMonitor, device);
}

bool ConferenceModel::isScreenSharingEnabled() const {
	return mMonitor && mMonitor->getScreenSharingParticipant();
}

void ConferenceModel::onActiveSpeakerParticipantDevice(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	lDebug() << "onActiveSpeakerParticipantDevice: "
	         << (participantDevice ? participantDevice->getAddress()->asString().c_str() : "NULL");

	emit activeSpeakerParticipantDevice(conference, conference->getActiveSpeakerParticipantDevice());
}

void ConferenceModel::onParticipantAdded(const std::shared_ptr<linphone::Conference> &conference,
                                         const std::shared_ptr<linphone::Participant> &participant) {
	lDebug() << "onParticipant Added" << participant->getAddress()->asStringUriOnly();
	emit participantAdded(participant);
	emit participantDeviceCountChanged(conference, getParticipantDeviceCount());
}
void ConferenceModel::onParticipantRemoved(const std::shared_ptr<linphone::Conference> &conference,
                                           const std::shared_ptr<const linphone::Participant> &participant) {
	lDebug() << "onParticipant Removed" << participant->getAddress()->asStringUriOnly();
	emit participantRemoved(participant);
	emit participantDeviceCountChanged(conference, getParticipantDeviceCount());
}
void ConferenceModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::Conference> &conference,
                                               const std::shared_ptr<linphone::ParticipantDevice> &participantDevice) {
	lDebug() << "onParticipantDeviceAdded";
	lDebug() << "Me devices : " << conference->getMe()->getDevices().size();
	if (conference->getMe()->getDevices().size() > 1)
		for (auto d : conference->getMe()->getDevices())
			lDebug() << "\t--> " << d->getAddress()->asString().c_str();
	emit participantDeviceAdded(participantDevice);
	emit participantDeviceCountChanged(conference, getParticipantDeviceCount());
}
void ConferenceModel::onParticipantDeviceRemoved(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	lDebug() << "onParticipantDeviceRemoved: " << participantDevice->getAddress()->asString().c_str() << " isInConf?["
	         << participantDevice->isInConference() << "]";
	lDebug() << "Me devices : " << conference->getMe()->getDevices().size();
	if (participantDevice->screenSharingEnabled()) emit isScreenSharingEnabledChanged(false);
	emit participantDeviceRemoved(conference, participantDevice);
	emit participantDeviceCountChanged(conference, getParticipantDeviceCount());
}
void ConferenceModel::onParticipantDeviceStateChanged(const std::shared_ptr<linphone::Conference> &conference,
                                                      const std::shared_ptr<const linphone::ParticipantDevice> &device,
                                                      linphone::ParticipantDevice::State state) {
	lDebug() << "onParticipantDeviceStateChanged: " << device->getAddress()->asString().c_str() << " isInConf?["
	         << device->isInConference() << "] " << (int)state;
	emit participantDeviceStateChanged(conference, device, state);
}
void ConferenceModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> &conference,
                                                      const std::shared_ptr<const linphone::Participant> &participant) {
	lDebug() << "onParticipantAdminStatusChanged";
	emit participantAdminStatusChanged(participant);
}
void ConferenceModel::onParticipantDeviceMediaCapabilityChanged(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	lDebug() << "onParticipantDeviceMediaCapabilityChanged: "
	         << (int)participantDevice->getStreamCapability(linphone::StreamType::Video)
	         << ". Device: " << participantDevice->getAddress()->asString().c_str();
	emit participantDeviceMediaCapabilityChanged(participantDevice);
}
void ConferenceModel::onParticipantDeviceMediaAvailabilityChanged(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	lDebug() << "onParticipantDeviceMediaAvailabilityChanged: "
	         << (int)participantDevice->getStreamAvailability(linphone::StreamType::Video)
	         << ". Device: " << participantDevice->getAddress()->asString().c_str();
	emit participantDeviceMediaAvailabilityChanged(participantDevice);
}
void ConferenceModel::onParticipantDeviceIsSpeakingChanged(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice,
    bool isSpeaking) {
	// lDebug()<< "onParticipantDeviceIsSpeakingChanged: "  << participantDevice->getAddress()->asString().c_str() <<
	// ". Speaking:" << isSpeaking;
	emit participantDeviceIsSpeakingChanged(participantDevice, isSpeaking);
}

void ConferenceModel::onParticipantDeviceScreenSharingChanged(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &device,
    bool enabled) {
	qDebug() << "onParticipantDeviceScreenSharingChanged: " << device->getAddress()->asString().c_str()
	         << ". Enabled:" << enabled;
	emit participantDeviceScreenSharingChanged(device, enabled);
	if (ToolModel::isLocal(mMonitor, device)) {
		emit isLocalScreenSharingChanged(enabled);
	}
	emit isScreenSharingEnabledChanged(enabled);
}

void ConferenceModel::onStateChanged(const std::shared_ptr<linphone::Conference> &conference,
                                     linphone::Conference::State newState) {
	lDebug() << "onStateChanged:" << (int)newState;
	if (newState == linphone::Conference::State::Created) {
		emit participantDeviceCountChanged(conference, mMonitor->getParticipantDeviceList().size());
		if (mMonitor->getScreenSharingParticipant()) emit isScreenSharingEnabledChanged(true);
	}
	// updateLocalParticipant();
	emit conferenceStateChanged(conference, newState);
}
void ConferenceModel::onSubjectChanged(const std::shared_ptr<linphone::Conference> &conference,
                                       const std::string &subject) {
	lDebug() << "onSubjectChanged";
	emit subjectChanged(subject);
}
void ConferenceModel::onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> &conference,
                                           const std::shared_ptr<const linphone::AudioDevice> &audioDevice) {
	lDebug() << "onAudioDeviceChanged is not yet implemented.";
}

void ConferenceModel::onIsScreenSharingEnabledChanged() {
	auto call = mMonitor->getCall();
	std::shared_ptr<linphone::CallParams> params = CoreModel::getInstance()->getCore()->createCallParams(call);
	lDebug() << log().arg("Old Layout=%1").arg((int)params->getConferenceVideoLayout());
	if (params->getConferenceVideoLayout() == linphone::Conference::Layout::Grid && params->videoEnabled()) {
		params->setConferenceVideoLayout(linphone::Conference::Layout::ActiveSpeaker);
	}
	call->update(params);
}
