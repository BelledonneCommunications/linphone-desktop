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

#ifndef CALL_MODEL_H_
#define CALL_MODEL_H_

#include "model/listener/Listener.hpp"
#include "model/videoSource/VideoSourceDescriptorModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class CallModel : public ::Listener<linphone::Call, linphone::CallListener>,
                  public linphone::CallListener,
                  public AbstractObject {
	Q_OBJECT
public:
	CallModel(const std::shared_ptr<linphone::Call> &call, QObject *parent = nullptr);
	~CallModel();

	void accept(bool withVideo);
	void decline();
	void terminate();

	void setMicrophoneMuted(bool isMuted);
	void setSpeakerMuted(bool isMuted);
	void setLocalVideoEnabled(bool enabled);
	void startRecording();
	void stopRecording();
	void setRecordFile(const std::string &path);
	void setInputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &id);
	std::shared_ptr<const linphone::AudioDevice> getInputAudioDevice() const;
	void setOutputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &id);
	std::shared_ptr<const linphone::AudioDevice> getOutputAudioDevice() const;
	void setConference(const std::shared_ptr<linphone::Conference> &conference);
	std::shared_ptr<linphone::CallStats> getAudioStats() const;
	std::shared_ptr<linphone::CallStats> getVideoStats() const;
	std::shared_ptr<linphone::CallStats> getTextStats() const;

	void setPaused(bool paused);
	void transferTo(const std::shared_ptr<linphone::Address> &address);
	void transferToAnother(const std::shared_ptr<linphone::Call> &call);
	void terminateAllCalls();

	float getMicrophoneVolume() const;
	std::string getRecordFile() const;
	std::shared_ptr<const linphone::Address> getRemoteAddress();
	bool getAuthenticationTokenVerified() const;
	void checkAuthenticationToken(const QString &token);
	void skipZrtpAuthentication();
	std::string getLocalAtuhenticationToken() const;
	QStringList getRemoteAtuhenticationTokens() const;
	bool getZrtpCaseMismatch() const;

	std::shared_ptr<linphone::Conference> getConference() const;

	LinphoneEnums::ConferenceLayout getConferenceVideoLayout() const;
	void changeConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout); // Make a call request
	void updateConferenceVideoLayout(); // Called from call state changed ater the new layout has been set.

	void setVideoSource(std::shared_ptr<linphone::VideoSourceDescriptor> videoDesc);
	LinphoneEnums::VideoSourceScreenSharingType getVideoSourceType() const;
	int getScreenSharingIndex() const;
	void setVideoSourceDescriptorModel(std::shared_ptr<VideoSourceDescriptorModel> model = nullptr);

	static void activateLocalVideo(std::shared_ptr<linphone::CallParams> &params, bool enable);

	void sendDtmf(const QString &dtmf);

	void updateCallErrorFromReason(linphone::Reason reason);

signals:
	void microphoneMutedChanged(bool isMuted);
	void speakerMutedChanged(bool isMuted);
	void durationChanged(int);
	void qualityUpdated(float quality);
	void microphoneVolumeChanged(float);
	void pausedChanged(bool paused);
	void remoteVideoEnabledChanged(bool remoteVideoEnabled);
	void localVideoEnabledChanged(bool enabled);
	void recordingChanged(const std::shared_ptr<linphone::Call> &call, bool recording);
	void speakerVolumeGainChanged(float volume);
	void microphoneVolumeGainChanged(float volume);
	void inputAudioDeviceChanged(const std::string &id);
	void outputAudioDeviceChanged(const std::string &id);
	void conferenceChanged();
	void conferenceVideoLayoutChanged(LinphoneEnums::ConferenceLayout layout);
	void videoDescriptorChanged();
	void errorMessageChanged(const QString &error);

private:
	QTimer mDurationTimer;
	QTimer mMicroVolumeTimer;
	std::shared_ptr<linphone::Conference> mConference;
	LinphoneEnums::ConferenceLayout mConferenceVideoLayout;
	static constexpr int gDtmfSoundDelay = 200;

	DECLARE_ABSTRACT_OBJECT

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onDtmfReceived(const std::shared_ptr<linphone::Call> &call, int dtmf) override;
	virtual void onGoclearAckSent(const std::shared_ptr<linphone::Call> &call) override;
	virtual void onEncryptionChanged(const std::shared_ptr<linphone::Call> &call,
	                                 bool on,
	                                 const std::string &authenticationToken) override;
	virtual void onSendMasterKeyChanged(const std::shared_ptr<linphone::Call> &call,
	                                    const std::string &sendMasterKey) override;
	virtual void onReceiveMasterKeyChanged(const std::shared_ptr<linphone::Call> &call,
	                                       const std::string &receiveMasterKey) override;
	virtual void onInfoMessageReceived(const std::shared_ptr<linphone::Call> &call,
	                                   const std::shared_ptr<const linphone::InfoMessage> &message) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::Call> &call,
	                            linphone::Call::State state,
	                            const std::string &message) override;
	virtual void onStatusChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::Status status);
	virtual void onDirChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::Dir dir);
	virtual void onStatsUpdated(const std::shared_ptr<linphone::Call> &call,
	                            const std::shared_ptr<const linphone::CallStats> &stats) override;
	virtual void onTransferStateChanged(const std::shared_ptr<linphone::Call> &call,
	                                    linphone::Call::State state) override;
	virtual void onAckProcessing(const std::shared_ptr<linphone::Call> &call,
	                             const std::shared_ptr<linphone::Headers> &ack,
	                             bool isReceived) override;
	virtual void onTmmbrReceived(const std::shared_ptr<linphone::Call> &call, int streamIndex, int tmmbr) override;
	virtual void onSnapshotTaken(const std::shared_ptr<linphone::Call> &call, const std::string &filePath) override;
	virtual void onNextVideoFrameDecoded(const std::shared_ptr<linphone::Call> &call) override;
	virtual void onCameraNotWorking(const std::shared_ptr<linphone::Call> &call,
	                                const std::string &cameraName) override;
	virtual void onVideoDisplayErrorOccurred(const std::shared_ptr<linphone::Call> &call, int errorCode) override;
	virtual void onAudioDeviceChanged(const std::shared_ptr<linphone::Call> &call,
	                                  const std::shared_ptr<linphone::AudioDevice> &audioDevice) override;
	virtual void onRemoteRecording(const std::shared_ptr<linphone::Call> &call, bool recording) override;
	virtual void onAuthenticationTokenVerified(const std::shared_ptr<linphone::Call> &call, bool verified) override;

signals:
	void dtmfReceived(const std::shared_ptr<linphone::Call> &call, int dtmf);
	void goclearAckSent(const std::shared_ptr<linphone::Call> &call);
	void
	encryptionChanged(const std::shared_ptr<linphone::Call> &call, bool on, const std::string &authenticationToken);
	void sendMasterKeyChanged(const std::shared_ptr<linphone::Call> &call, const std::string &sendMasterKey);
	void receiveMasterKeyChanged(const std::shared_ptr<linphone::Call> &call, const std::string &receiveMasterKey);
	void infoMessageReceived(const std::shared_ptr<linphone::Call> &call,
	                         const std::shared_ptr<const linphone::InfoMessage> &message);
	void
	stateChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::State state, const std::string &message);
	void statusChanged(linphone::Call::Status status);
	void dirChanged(linphone::Call::Dir dir);
	void statsUpdated(const std::shared_ptr<linphone::Call> &call,
	                  const std::shared_ptr<const linphone::CallStats> &stats);
	void transferStateChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	void ackProcessing(const std::shared_ptr<linphone::Call> &call,
	                   const std::shared_ptr<linphone::Headers> &ack,
	                   bool isReceived);
	void tmmbrReceived(const std::shared_ptr<linphone::Call> &call, int streamIndex, int tmmbr);
	void snapshotTaken(const std::shared_ptr<linphone::Call> &call, const std::string &filePath);
	void nextVideoFrameDecoded(const std::shared_ptr<linphone::Call> &call);
	void cameraNotWorking(const std::shared_ptr<linphone::Call> &call, const std::string &cameraName);
	void videoDisplayErrorOccurred(const std::shared_ptr<linphone::Call> &call, int errorCode);
	void audioDeviceChanged(const std::shared_ptr<linphone::Call> &call,
	                        const std::shared_ptr<linphone::AudioDevice> &audioDevice);
	void remoteRecording(const std::shared_ptr<linphone::Call> &call, bool recording);
	void authenticationTokenVerified(const std::shared_ptr<linphone::Call> &call, bool verified);
};

#endif
