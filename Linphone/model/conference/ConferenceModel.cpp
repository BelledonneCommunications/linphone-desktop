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

DEFINE_ABSTRACT_OBJECT(ConferenceModel)

ConferenceModel::ConferenceModel(const std::shared_ptr<linphone::Conference> &conference, QObject *parent)
    : ::Listener<linphone::Conference, linphone::ConferenceListener>(conference, parent) {
	mustBeInLinphoneThread(getClassName());
}

ConferenceModel::~ConferenceModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void ConferenceModel::terminate() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->terminate();
}
void ConferenceModel::setPaused(bool paused) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
}

void ConferenceModel::removeParticipant(std::shared_ptr<linphone::Participant> p) {
	mMonitor->removeParticipant(p);
}

void ConferenceModel::removeParticipant(std::shared_ptr<linphone::Address> address) {
	for (auto &p : mMonitor->getParticipantList()) {
		if (address->asStringUriOnly() == p->getAddress()->asStringUriOnly()) {
			mMonitor->removeParticipant(p);
		}
	}
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
	// emit recordingChanged(mMonitor->getParams()->isRecording());
	// TODO : display notification
}

void ConferenceModel::setRecordFile(const std::string &path) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	// auto params = core->createCallParams(mMonitor);
	// params->setRecordFile(path);
	// mMonitor->update(params);
}

// void ConferenceModel::setSpeakerVolumeGain(float gain) {
// 	mMonitor->setSpeakerVolumeGain(gain);
// 	emit speakerVolumeGainChanged(gain);
// }

// float ConferenceModel::getSpeakerVolumeGain() const {
// 	auto gain = mMonitor->getSpeakerVolumeGain();
// 	if (gain < 0) gain = CoreModel::getInstance()->getCore()->getPlaybackGainDb();
// 	return gain;
// }

// void ConferenceModel::setMicrophoneVolumeGain(float gain) {
// 	mMonitor->setMicrophoneVolumeGain(gain);
// 	emit microphoneVolumeGainChanged(gain);
// }

// float ConferenceModel::getMicrophoneVolumeGain() const {
// 	auto gain = mMonitor->getMicrophoneVolumeGain();
// 	return gain;
// }

// float ConferenceModel::getMicrophoneVolume() const {
// 	auto volume = mMonitor->getRecordVolume();
// 	return volume;
// }

void ConferenceModel::setInputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mMonitor->setInputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit inputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> ConferenceModel::getInputAudioDevice() const {
	return mMonitor->getInputAudioDevice();
}

void ConferenceModel::setOutputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mMonitor->setOutputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit outputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> ConferenceModel::getOutputAudioDevice() const {
	return mMonitor->getOutputAudioDevice();
}

void ConferenceModel::onActiveSpeakerParticipantDevice(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	qDebug() << "onActiveSpeakerParticipantDevice: " << participantDevice->getAddress()->asString().c_str();
	emit activeSpeakerParticipantDevice(participantDevice);
}

void ConferenceModel::onParticipantAdded(const std::shared_ptr<linphone::Conference> &conference,
                                         const std::shared_ptr<const linphone::Participant> &participant) {
	qDebug() << "onParticipantAdded: " << participant->getAddress()->asString().c_str();
	emit participantAdded(participant);
}
void ConferenceModel::onParticipantRemoved(const std::shared_ptr<linphone::Conference> &conference,
                                           const std::shared_ptr<const linphone::Participant> &participant) {
	qDebug() << "onParticipantRemoved";
	emit participantRemoved(participant);
}
void ConferenceModel::onParticipantDeviceAdded(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	qDebug() << "onParticipantDeviceAdded";
	qDebug() << "Me devices : " << conference->getMe()->getDevices().size();
	if (conference->getMe()->getDevices().size() > 1)
		for (auto d : conference->getMe()->getDevices())
			qDebug() << "\t--> " << d->getAddress()->asString().c_str();
	emit participantDeviceAdded(participantDevice);
}
void ConferenceModel::onParticipantDeviceRemoved(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	qDebug() << "onParticipantDeviceRemoved: " << participantDevice->getAddress()->asString().c_str() << " isInConf?["
	         << participantDevice->isInConference() << "]";
	qDebug() << "Me devices : " << conference->getMe()->getDevices().size();
	emit participantDeviceRemoved(participantDevice);
}
void ConferenceModel::onParticipantDeviceStateChanged(const std::shared_ptr<linphone::Conference> &conference,
                                                      const std::shared_ptr<const linphone::ParticipantDevice> &device,
                                                      linphone::ParticipantDevice::State state) {
	qDebug() << "onParticipantDeviceStateChanged: " << device->getAddress()->asString().c_str() << " isInConf?["
	         << device->isInConference() << "] " << (int)state;
	emit participantDeviceStateChanged(conference, device, state);
}
void ConferenceModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> &conference,
                                                      const std::shared_ptr<const linphone::Participant> &participant) {
	qDebug() << "onParticipantAdminStatusChanged";
	emit participantAdminStatusChanged(participant);
}
void ConferenceModel::onParticipantDeviceMediaCapabilityChanged(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	qDebug() << "onParticipantDeviceMediaCapabilityChanged: "
	         << (int)participantDevice->getStreamCapability(linphone::StreamType::Video)
	         << ". Device: " << participantDevice->getAddress()->asString().c_str();
	emit participantDeviceMediaCapabilityChanged(participantDevice);
}
void ConferenceModel::onParticipantDeviceMediaAvailabilityChanged(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	qDebug() << "onParticipantDeviceMediaAvailabilityChanged: "
	         << (int)participantDevice->getStreamAvailability(linphone::StreamType::Video)
	         << ". Device: " << participantDevice->getAddress()->asString().c_str();
	emit participantDeviceMediaAvailabilityChanged(participantDevice);
}
void ConferenceModel::onParticipantDeviceIsSpeakingChanged(
    const std::shared_ptr<linphone::Conference> &conference,
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice,
    bool isSpeaking) {
	// qDebug() << "onParticipantDeviceIsSpeakingChanged: "  << participantDevice->getAddress()->asString().c_str() <<
	// ". Speaking:" << isSpeaking;
	emit participantDeviceIsSpeakingChanged(participantDevice, isSpeaking);
}
void ConferenceModel::onStateChanged(const std::shared_ptr<linphone::Conference> &conference,
                                     linphone::Conference::State newState) {
	qDebug() << "onStateChanged:" << (int)newState;
	emit conferenceStateChanged(newState);
}
void ConferenceModel::onSubjectChanged(const std::shared_ptr<linphone::Conference> &conference,
                                       const std::string &subject) {
	qDebug() << "onSubjectChanged";
	emit subjectChanged(subject);
}
void ConferenceModel::onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> &conference,
                                           const std::shared_ptr<const linphone::AudioDevice> &audioDevice) {
	qDebug() << "onAudioDeviceChanged is not yet implemented.";
}