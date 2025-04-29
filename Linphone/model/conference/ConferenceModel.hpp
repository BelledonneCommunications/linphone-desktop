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

#ifndef CONFERENCE_MODEL_H_
#define CONFERENCE_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class ConferenceModel : public ::Listener<linphone::Conference, linphone::ConferenceListener>,
                        public linphone::ConferenceListener,
                        public AbstractObject {
	Q_OBJECT
public:
	ConferenceModel(const std::shared_ptr<linphone::Conference> &conference, QObject *parent = nullptr);
	~ConferenceModel();
	static std::shared_ptr<ConferenceModel> create(const std::shared_ptr<linphone::Conference> &conference);

	void terminate();

	void setMicrophoneMuted(bool isMuted);
	void startRecording();
	void stopRecording();
	void setRecordFile(const std::string &path);
	void setParticipantAdminStatus(const std::shared_ptr<linphone::Participant> participant, bool status);
	void setInputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &id);
	std::shared_ptr<const linphone::AudioDevice> getInputAudioDevice() const;
	void setOutputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &id);
	std::shared_ptr<const linphone::AudioDevice> getOutputAudioDevice() const;

	void toggleScreenSharing();
	bool isLocalScreenSharing() const;
	bool isScreenSharingEnabled() const;

	void removeParticipant(const std::shared_ptr<linphone::Participant> &p);
	void removeParticipant(const std::shared_ptr<linphone::Address> &address);
	void addParticipant(const std::shared_ptr<linphone::Address> &address);

	std::shared_ptr<linphone::ChatRoom> getChatRoom() const;

	int getParticipantDeviceCount() const;

	void onIsScreenSharingEnabledChanged();

signals:
	void microphoneMutedChanged(bool isMuted);
	void speakerMutedChanged(bool isMuted);
	void durationChanged(int);
	void microphoneVolumeChanged(float);
	void remoteVideoEnabledChanged(bool remoteVideoEnabled);
	void localVideoEnabledChanged(bool enabled);
	void recordingChanged(bool recording);
	void speakerVolumeGainChanged(float volume);
	void microphoneVolumeGainChanged(float volume);
	void inputAudioDeviceChanged(const std::string &id);
	void outputAudioDeviceChanged(const std::string &id);
	void isLocalScreenSharingChanged(bool enabled);
	void isScreenSharingEnabledChanged(bool enabled);
	void participantDeviceCountChanged(const std::shared_ptr<linphone::Conference> &conference, int count);

private:
	// LINPHONE LISTENERS
	virtual void onActiveSpeakerParticipantDevice(
	    const std::shared_ptr<linphone::Conference> &conference,
	    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) override;
	virtual void onParticipantAdded(const std::shared_ptr<linphone::Conference> &conference,
	                                const std::shared_ptr<linphone::Participant> &participant) override;
	virtual void onParticipantRemoved(const std::shared_ptr<linphone::Conference> &conference,
	                                  const std::shared_ptr<const linphone::Participant> &participant) override;
	virtual void
	onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> &conference,
	                                const std::shared_ptr<const linphone::Participant> &participant) override;
	virtual void
	onParticipantDeviceAdded(const std::shared_ptr<linphone::Conference> &conference,
	                         const std::shared_ptr<linphone::ParticipantDevice> &participantDevice) override;
	virtual void
	onParticipantDeviceRemoved(const std::shared_ptr<linphone::Conference> &conference,
	                           const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) override;
	virtual void onParticipantDeviceStateChanged(const std::shared_ptr<linphone::Conference> &conference,
	                                             const std::shared_ptr<const linphone::ParticipantDevice> &device,
	                                             linphone::ParticipantDevice::State state) override;
	virtual void onParticipantDeviceMediaCapabilityChanged(
	    const std::shared_ptr<linphone::Conference> &conference,
	    const std::shared_ptr<const linphone::ParticipantDevice> &device) override;
	virtual void onParticipantDeviceMediaAvailabilityChanged(
	    const std::shared_ptr<linphone::Conference> &conference,
	    const std::shared_ptr<const linphone::ParticipantDevice> &device) override;
	virtual void
	onParticipantDeviceIsSpeakingChanged(const std::shared_ptr<linphone::Conference> &conference,
	                                     const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice,
	                                     bool isSpeaking) override;
	virtual void
	onParticipantDeviceScreenSharingChanged(const std::shared_ptr<linphone::Conference> &conference,
	                                        const std::shared_ptr<const linphone::ParticipantDevice> &device,
	                                        bool enabled) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::Conference> &conference,
	                            linphone::Conference::State newState) override;
	virtual void onSubjectChanged(const std::shared_ptr<linphone::Conference> &conference,
	                              const std::string &subject) override;
	virtual void onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> &conference,
	                                  const std::shared_ptr<const linphone::AudioDevice> &audioDevice) override;

signals:
	void activeSpeakerParticipantDevice(const std::shared_ptr<linphone::Conference> &conference,
	                                    const std::shared_ptr<linphone::ParticipantDevice> &participantDevice);
	void participantAdded(const std::shared_ptr<linphone::Participant> &participant);
	void participantRemoved(const std::shared_ptr<const linphone::Participant> &participant);
	void participantAdminStatusChanged(const std::shared_ptr<const linphone::Participant> &participant);
	void participantDeviceAdded(const std::shared_ptr<linphone::ParticipantDevice> &participantDevice);
	void participantDeviceRemoved(const std::shared_ptr<linphone::Conference> &conference,
	                              const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void participantDeviceStateChanged(const std::shared_ptr<linphone::Conference> &conference,
	                                   const std::shared_ptr<const linphone::ParticipantDevice> &device,
	                                   linphone::ParticipantDevice::State state);
	void participantDeviceMediaCapabilityChanged(
	    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void participantDeviceMediaAvailabilityChanged(
	    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice);
	void participantDeviceIsSpeakingChanged(const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice,
	                                        bool isSpeaking);
	void participantDeviceScreenSharingChanged(const std::shared_ptr<const linphone::ParticipantDevice> &device,
	                                           bool enabled);
	void conferenceStateChanged(const std::shared_ptr<linphone::Conference> &conference,
	                            linphone::Conference::State newState);
	void subjectChanged(const std::string &subject);

private:
	QTimer mDurationTimer;
	QTimer mMicroVolumeTimer;
	DECLARE_ABSTRACT_OBJECT

	// LINPHONE
	//--------------------------------------------------------------------------------
};

#endif
