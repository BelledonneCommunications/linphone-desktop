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

#include "model/call/CallModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class CallCore : public QObject, public AbstractObject {
	Q_OBJECT

	// Q_PROPERTY(QString peerDisplayName MEMBER mPeerDisplayName)
	Q_PROPERTY(LinphoneEnums::CallStatus status READ getStatus NOTIFY statusChanged)
	Q_PROPERTY(LinphoneEnums::CallDir dir READ getDir NOTIFY dirChanged)
	Q_PROPERTY(LinphoneEnums::CallState state READ getState NOTIFY stateChanged)
	Q_PROPERTY(QString lastErrorMessage READ getLastErrorMessage NOTIFY lastErrorMessageChanged)
	Q_PROPERTY(int duration READ getDuration NOTIFY durationChanged)
	Q_PROPERTY(bool speakerMuted READ getSpeakerMuted WRITE lSetSpeakerMuted NOTIFY speakerMutedChanged)
	Q_PROPERTY(bool microphoneMuted READ getMicrophoneMuted WRITE lSetMicrophoneMuted NOTIFY microphoneMutedChanged)
	Q_PROPERTY(bool cameraEnabled READ getCameraEnabled WRITE lSetCameraEnabled NOTIFY cameraEnabledChanged)
	Q_PROPERTY(bool paused READ getPaused WRITE lSetPaused NOTIFY pausedChanged)
	Q_PROPERTY(QString peerAddress READ getPeerAddress CONSTANT)
	Q_PROPERTY(bool peerSecured READ getPeerSecured WRITE setPeerSecured NOTIFY peerSecuredChanged)
	Q_PROPERTY(
	    bool remoteVideoEnabled READ getRemoteVideoEnabled WRITE setRemoteVideoEnabled NOTIFY remoteVideoEnabledChanged)
	Q_PROPERTY(LinphoneEnums::CallState transferState READ getTransferState NOTIFY transferStateChanged)

public:
	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<CallCore> create(const std::shared_ptr<linphone::Call> &call);
	CallCore(const std::shared_ptr<linphone::Call> &call);
	~CallCore();
	void setSelf(QSharedPointer<CallCore> me);

	QString getPeerAddress() const;

	LinphoneEnums::CallStatus getStatus() const;
	void setStatus(LinphoneEnums::CallStatus status);

	LinphoneEnums::CallDir getDir() const;
	void setDir(LinphoneEnums::CallDir dir);

	LinphoneEnums::CallState getState() const;
	void setState(LinphoneEnums::CallState state, const QString &message);

	QString getLastErrorMessage() const;
	void setLastErrorMessage(const QString &message);

	int getDuration();
	void setDuration(int duration);

	bool getSpeakerMuted() const;
	void setSpeakerMuted(bool isMuted);

	bool getMicrophoneMuted() const;
	void setMicrophoneMuted(bool isMuted);

	bool getCameraEnabled() const;
	void setCameraEnabled(bool enabled);

	bool getPaused() const;
	void setPaused(bool paused);

	bool getPeerSecured() const;
	void setPeerSecured(bool secured);

	bool getRemoteVideoEnabled() const;
	void setRemoteVideoEnabled(bool enabled);

	LinphoneEnums::CallState getTransferState() const;
	void setTransferState(LinphoneEnums::CallState state, const QString &message);

	std::shared_ptr<CallModel> getModel() const;

signals:
	void statusChanged(LinphoneEnums::CallStatus status);
	void stateChanged(LinphoneEnums::CallState state);
	void dirChanged(LinphoneEnums::CallDir dir);
	void lastErrorMessageChanged();
	void peerAddressChanged();
	void durationChanged(int duration);
	void speakerMutedChanged();
	void microphoneMutedChanged();
	void cameraEnabledChanged();
	void pausedChanged();
	void transferStateChanged();
	void peerSecuredChanged();
	void remoteVideoEnabledChanged(bool remoteVideoEnabled);

	// Linphone commands
	void lAccept(bool withVideo); // Accept an incoming call
	void lDecline();              // Decline an incoming call
	void lTerminate();            // Hangup a call
	void lSetSpeakerMuted(bool muted);
	void lSetMicrophoneMuted(bool isMuted);
	void lSetCameraEnabled(bool enabled);
	void lSetPaused(bool paused);
	void lTransferCall(const QString &dest);

	/* TODO
	    Q_INVOKABLE void acceptWithVideo();

	    Q_INVOKABLE void askForTransfer();
	    Q_INVOKABLE void askForAttendedTransfer();
	    Q_INVOKABLE bool transferTo(const QString &sipAddress);
	    Q_INVOKABLE bool transferToAnother(const QString &peerAddress);

	    Q_INVOKABLE bool getRemoteVideoEnabled() const;
	    Q_INVOKABLE void acceptVideoRequest();
	    Q_INVOKABLE void rejectVideoRequest();

	    Q_INVOKABLE void takeSnapshot();
	    Q_INVOKABLE void startRecording();
	    Q_INVOKABLE void stopRecording();

	    Q_INVOKABLE void sendDtmf(const QString &dtmf);
	    Q_INVOKABLE void verifyAuthenticationToken(bool verify);
	    Q_INVOKABLE void updateStreams();
	    Q_INVOKABLE void toggleSpeakerMute();
	*/
private:
	std::shared_ptr<CallModel> mCallModel;
	LinphoneEnums::CallStatus mStatus;
	LinphoneEnums::CallState mState;
	LinphoneEnums::CallState mTransferState;
	LinphoneEnums::CallDir mDir;
	QString mLastErrorMessage;
	QString mPeerAddress;
	bool mPeerSecured;
	int mDuration = 0;
	bool mSpeakerMuted;
	bool mMicrophoneMuted;
	bool mCameraEnabled;
	bool mPaused = false;
	bool mRemoteVideoEnabled = false;
	QSharedPointer<SafeConnection<CallCore, CallModel>> mAccountModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(CallCore *)
#endif
