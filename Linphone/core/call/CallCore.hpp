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

#ifndef CALL_CORE_H_
#define CALL_CORE_H_

#include "core/conference/ConferenceCore.hpp"
#include "core/conference/ConferenceGui.hpp"
#include "core/videoSource/VideoSourceDescriptorGui.hpp"
#include "model/call/CallModel.hpp"
#include "model/search/MagicSearchModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

struct ZrtpStats {
	Q_GADGET

	Q_PROPERTY(QString cipherAlgo MEMBER mCipherAlgorithm)
	Q_PROPERTY(QString keyAgreementAlgo MEMBER mKeyAgreementAlgorithm)
	Q_PROPERTY(QString hashAlgo MEMBER mHashAlgorithm)
	Q_PROPERTY(QString authenticationAlgo MEMBER mAuthenticationAlgorithm)
	Q_PROPERTY(QString sasAlgo MEMBER mSasAlgorithm)
	Q_PROPERTY(bool isPostQuantum MEMBER mIsPostQuantum)
public:
	bool mIsPostQuantum = false;
	QString mCipherAlgorithm;
	QString mKeyAgreementAlgorithm;
	QString mHashAlgorithm;
	QString mAuthenticationAlgorithm;
	QString mSasAlgorithm;

	ZrtpStats operator=(ZrtpStats s);
	bool operator==(ZrtpStats s);
	bool operator!=(ZrtpStats s);
};

struct AudioStats {
	Q_GADGET
	Q_PROPERTY(QString codec MEMBER mCodec)
	Q_PROPERTY(QString bandwidth MEMBER mBandwidth)
	Q_PROPERTY(QString lossRate MEMBER mLossRate)
	Q_PROPERTY(QString jitterBufferSize MEMBER mJitterBufferSize)

public:
	QString mCodec;
	QString mBandwidth;
	QString mLossRate;
	QString mJitterBufferSize;

	AudioStats operator=(AudioStats s);

	bool operator==(AudioStats s);
	bool operator!=(AudioStats s);
};

struct VideoStats {
	Q_GADGET
	Q_PROPERTY(QString codec MEMBER mCodec)
	Q_PROPERTY(QString bandwidth MEMBER mBandwidth)
	Q_PROPERTY(QString resolution MEMBER mResolution)
	Q_PROPERTY(QString fps MEMBER mFps)
	Q_PROPERTY(QString lossRate MEMBER mLossRate)

public:
	QString mCodec;
	QString mBandwidth;
	QString mResolution;
	QString mFps;
	QString mLossRate;

	VideoStats operator=(VideoStats s);
	bool operator==(VideoStats s);
	bool operator!=(VideoStats s);
};

class CallCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	Q_PROPERTY(LinphoneEnums::CallStatus status READ getStatus NOTIFY statusChanged)
	Q_PROPERTY(LinphoneEnums::CallDir dir READ getDir NOTIFY dirChanged)
	Q_PROPERTY(LinphoneEnums::CallState state READ getState NOTIFY stateChanged)
	Q_PROPERTY(QString lastErrorMessage READ getLastErrorMessage NOTIFY lastErrorMessageChanged)
	Q_PROPERTY(int duration READ getDuration NOTIFY durationChanged)
	Q_PROPERTY(int quality READ getCurrentQuality NOTIFY qualityChanged)
	Q_PROPERTY(bool speakerMuted READ getSpeakerMuted WRITE lSetSpeakerMuted NOTIFY speakerMutedChanged)
	Q_PROPERTY(bool microphoneMuted READ getMicrophoneMuted WRITE lSetMicrophoneMuted NOTIFY microphoneMutedChanged)
	Q_PROPERTY(bool paused READ getPaused WRITE lSetPaused NOTIFY pausedChanged)
	Q_PROPERTY(QString remoteName MEMBER mRemoteName NOTIFY remoteNameChanged)
	Q_PROPERTY(QString remoteAddress READ getRemoteAddress CONSTANT)
	Q_PROPERTY(QString localAddress READ getLocalAddress CONSTANT)
	Q_PROPERTY(bool tokenVerified READ getTokenVerified WRITE setTokenVerified NOTIFY securityUpdated)
	Q_PROPERTY(bool isMismatch READ isMismatch WRITE setIsMismatch NOTIFY securityUpdated)
	Q_PROPERTY(LinphoneEnums::MediaEncryption encryption READ getEncryption NOTIFY securityUpdated)
	Q_PROPERTY(QString encryptionString READ getEncryptionString NOTIFY securityUpdated)
	Q_PROPERTY(QString localToken READ getLocalToken WRITE setLocalToken MEMBER mLocalToken NOTIFY localTokenChanged)
	Q_PROPERTY(QStringList remoteTokens WRITE setRemoteTokens MEMBER mRemoteTokens NOTIFY remoteTokensChanged)
	Q_PROPERTY(
	    bool remoteVideoEnabled READ getRemoteVideoEnabled WRITE setRemoteVideoEnabled NOTIFY remoteVideoEnabledChanged)
	Q_PROPERTY(
	    bool localVideoEnabled READ getLocalVideoEnabled WRITE lSetLocalVideoEnabled NOTIFY localVideoEnabledChanged)
	Q_PROPERTY(bool recording READ getRecording WRITE setRecording NOTIFY recordingChanged)
	Q_PROPERTY(bool remoteRecording READ getRemoteRecording WRITE setRemoteRecording NOTIFY remoteRecordingChanged)
	Q_PROPERTY(bool recordable READ getRecordable WRITE setRecordable NOTIFY recordableChanged)
	Q_PROPERTY(float microVolume READ getMicrophoneVolume WRITE setMicrophoneVolume NOTIFY microphoneVolumeChanged)
	Q_PROPERTY(LinphoneEnums::CallState transferState READ getTransferState NOTIFY transferStateChanged)
	Q_PROPERTY(ConferenceGui *conference READ getConferenceGui NOTIFY conferenceChanged)
	Q_PROPERTY(bool isConference READ isConference NOTIFY isConferenceChanged)
	Q_PROPERTY(LinphoneEnums::ConferenceLayout conferenceVideoLayout READ getConferenceVideoLayout WRITE
	               lSetConferenceVideoLayout NOTIFY conferenceVideoLayoutChanged)

	Q_PROPERTY(VideoSourceDescriptorGui *videoSourceDescriptor READ getVideoSourceDescriptorGui WRITE
	               lSetVideoSourceDescriptor NOTIFY videoSourceDescriptorChanged)
	Q_PROPERTY(ZrtpStats zrtpStats READ getZrtpStats WRITE setZrtpStats NOTIFY zrtpStatsChanged)
	Q_PROPERTY(AudioStats audioStats READ getAudioStats WRITE setAudioStats NOTIFY audioStatsChanged)
	Q_PROPERTY(VideoStats videoStats READ getVideoStats WRITE setVideoStats NOTIFY videoStatsChanged)

	DECLARE_GUI_GETSET(bool, isStarted, IsStarted)

	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<CallCore> create(const std::shared_ptr<linphone::Call> &call);
	CallCore(const std::shared_ptr<linphone::Call> &call);
	~CallCore();
	void setSelf(QSharedPointer<CallCore> me);

	QString getRemoteAddress() const;
	QString getLocalAddress() const;

	LinphoneEnums::CallStatus getStatus() const;
	void setStatus(LinphoneEnums::CallStatus status);

	LinphoneEnums::CallDir getDir() const;
	void setDir(LinphoneEnums::CallDir dir);

	LinphoneEnums::CallState getState() const;
	void setState(LinphoneEnums::CallState state);

	QString getLastErrorMessage() const;
	void setLastErrorMessage(const QString &message);

	int getDuration() const;
	void setDuration(int duration);

	float getCurrentQuality() const;
	void setCurrentQuality(float quality);

	bool getSpeakerMuted() const;
	void setSpeakerMuted(bool isMuted);

	bool getMicrophoneMuted() const;
	void setMicrophoneMuted(bool isMuted);

	bool getPaused() const;
	void setPaused(bool paused);

	bool getTokenVerified() const;
	void setTokenVerified(bool verified);

	bool isMismatch() const;
	void setIsMismatch(bool mismatch);

	ConferenceGui *getConferenceGui() const;
	QSharedPointer<ConferenceCore> getConferenceCore() const;
	void setConference(const QSharedPointer<ConferenceCore> &conference);
	void setIsConference(bool isConf);

	bool isConference() const;

	QString getLocalToken();
	void setLocalToken(const QString &token);
	QStringList getRemoteTokens();
	void setRemoteTokens(const QStringList &Tokens);

	LinphoneEnums::MediaEncryption getEncryption() const;
	QString getEncryptionString() const;
	void setEncryption(LinphoneEnums::MediaEncryption encryption);

	bool getRemoteVideoEnabled() const;
	void setRemoteVideoEnabled(bool enabled);

	bool getLocalVideoEnabled() const;
	void setLocalVideoEnabled(bool enabled);

	bool getRecording() const;
	void setRecording(bool recording);

	bool getRemoteRecording() const;
	void setRemoteRecording(bool recording);

	bool getRecordable() const;
	void setRecordable(bool recordable);

	float getMicrophoneVolume() const;
	void setMicrophoneVolume(float vol);

	QString getInputDeviceName() const;
	void setInputDeviceName(const QString &id);

	LinphoneEnums::CallState getTransferState() const;
	void setTransferState(LinphoneEnums::CallState state);

	LinphoneEnums::ConferenceLayout getConferenceVideoLayout() const;
	void setConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout);

	VideoSourceDescriptorGui *getVideoSourceDescriptorGui() const;
	void setVideoSourceDescriptor(QSharedPointer<VideoSourceDescriptorCore> core);

	std::shared_ptr<CallModel> getModel() const;

	ZrtpStats getZrtpStats() const;
	void setZrtpStats(ZrtpStats stats);

	AudioStats getAudioStats() const;
	void setAudioStats(AudioStats stats);

	VideoStats getVideoStats() const;
	void setVideoStats(VideoStats stats);

	void findRemoteFriend(QSharedPointer<CallCore> me);

signals:
	void statusChanged(LinphoneEnums::CallStatus status);
	void stateChanged(LinphoneEnums::CallState state);
	void dirChanged(LinphoneEnums::CallDir dir);
	void lastErrorMessageChanged();
	void durationChanged(int duration);
	void qualityChanged(float quality);
	void speakerMutedChanged();
	void microphoneMutedChanged();
	void pausedChanged();
	void transferStateChanged();
	void securityUpdated();
	void tokenVerified();
	void localTokenChanged();
	void remoteTokensChanged();
	void remoteVideoEnabledChanged(bool remoteVideoEnabled);
	void localVideoEnabledChanged();
	void recordingChanged();
	void remoteRecordingChanged();
	void recordableChanged();
	void microphoneVolumeChanged();
	void conferenceChanged();
	void isConferenceChanged();
	void conferenceVideoLayoutChanged();
	void videoSourceDescriptorChanged();
	void zrtpStatsChanged();
	void audioStatsChanged();
	void videoStatsChanged();
	void remoteNameChanged();

	// Linphone commands
	void lAccept(bool withVideo); // Accept an incoming call
	void lDecline();              // Decline an incoming call
	void lTerminate();            // Hangup a call
	void lTerminateAllCalls();    // Hangup all calls
	void lSetSpeakerMuted(bool muted);
	void lSetMicrophoneMuted(bool isMuted);
	void lSetLocalVideoEnabled(bool enabled);
	void lSetVideoEnabled(bool enabled);
	void lSetPaused(bool paused);
	void lTransferCall(QString address);
	void lTransferCallToAnother(QString uri);
	void lStartRecording();
	void lStopRecording();
	void lCheckAuthenticationTokenSelected(const QString &token);
	void lSkipZrtpAuthentication();
	void lSetInputAudioDevice(QString id);
	void lSetOutputAudioDevice(QString id);
	void lSetConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout);
	void lSetVideoSourceDescriptor(VideoSourceDescriptorGui *gui);
	void lSendDtmf(QString dtmf);

	/* TODO
	    Q_INVOKABLE void acceptWithVideo();

	    Q_INVOKABLE void askForTransfer();
	    Q_INVOKABLE void askForAttendedTransfer();
	    Q_INVOKABLE bool transferTo(const QString &sipAddress);
	    Q_INVOKABLE bool transferToAnother(const QString &remoteAddress);

	    Q_INVOKABLE bool getRemoteVideoEnabled() const;
	    Q_INVOKABLE void acceptVideoRequest();
	    Q_INVOKABLE void rejectVideoRequest();

	    Q_INVOKABLE void takeSnapshot();

	    Q_INVOKABLE void verifyAuthenticationToken(bool verify);
	    Q_INVOKABLE void updateStreams();
	*/
private:
	std::shared_ptr<CallModel> mCallModel;
	QSharedPointer<ConferenceCore> mConference;
	QSharedPointer<VideoSourceDescriptorCore> mVideoSourceDescriptor;
	LinphoneEnums::CallStatus mStatus;
	LinphoneEnums::CallState mState;
	LinphoneEnums::CallState mTransferState;
	LinphoneEnums::CallDir mDir;
	LinphoneEnums::ConferenceLayout mConferenceVideoLayout;
	LinphoneEnums::MediaEncryption mEncryption;

	QString mLastErrorMessage;
	QString mRemoteName;
	QString mRemoteUsername;
	QString mRemoteAddress;
	QString mLocalAddress;
	bool mTokenVerified = false;
	bool mIsSecured = false;
	bool mIsMismatch = false;
	int mDuration = 0;
	float mQuality = 0;
	bool mSpeakerMuted = false;
	bool mMicrophoneMuted = false;
	bool mLocalVideoEnabled = false;
	bool mVideoEnabled = false;
	bool mPaused = false;
	bool mRemoteVideoEnabled = false;
	bool mRecording = false;
	bool mRemoteRecording = false;
	bool mRecordable = false;
	bool mIsConference = false;
	QString mLocalToken;
	QStringList mRemoteTokens;
	float mMicrophoneVolume;
	QSharedPointer<SafeConnection<CallCore, CallModel>> mCallModelConnection;
	ZrtpStats mZrtpStats;
	AudioStats mAudioStats;
	VideoStats mVideoStats;
	std::shared_ptr<MagicSearchModel> mRemoteMagicSearchModel;
	bool mShouldFindRemoteFriend;
	QSharedPointer<SafeConnection<CallCore, MagicSearchModel>> mRemoteMagicSearchModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(CallCore *)
#endif
