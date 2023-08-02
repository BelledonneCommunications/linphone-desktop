/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>
#include "../search/SearchListener.hpp"

#include "utils/LinphoneEnums.hpp"

// =============================================================================
class CallListener;
class ConferenceInfoModel;
class ConferenceModel;
class ContactModel;
class ChatRoomModel;

class CallModel : public QObject {
	Q_OBJECT
	
	Q_PROPERTY(QString peerAddress READ getPeerAddress CONSTANT)
	Q_PROPERTY(QString localAddress READ getLocalAddress CONSTANT)
	Q_PROPERTY(QString fullPeerAddress READ getFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString fullLocalAddress READ getFullLocalAddress CONSTANT)
	
	Q_PROPERTY(ContactModel *contactModel READ getContactModel CONSTANT )
	Q_PROPERTY(ChatRoomModel * chatRoomModel READ getChatRoomModel NOTIFY chatRoomModelChanged)
	Q_PROPERTY(ConferenceModel * conferenceModel READ getConferenceModel NOTIFY conferenceModelChanged)
	Q_PROPERTY(ConferenceInfoModel * conferenceInfoModel READ getConferenceInfoModel NOTIFY conferenceInfoModelChanged)
	
	Q_PROPERTY(CallStatus status READ getStatus NOTIFY statusChanged)
	Q_PROPERTY(QString callError READ getCallError NOTIFY callErrorChanged)
	Q_PROPERTY(QString callId MEMBER mCallId WRITE setCallId NOTIFY callIdChanged)
	
	Q_PROPERTY(bool isOutgoing READ isOutgoing CONSTANT)
	
	Q_PROPERTY(bool isInConference READ isInConference NOTIFY isInConferenceChanged)
	Q_PROPERTY(bool isConference READ isConference NOTIFY conferenceInfoModelChanged)
	Q_PROPERTY(bool isOneToOne READ isOneToOne NOTIFY conferenceInfoModelChanged)
	
	
	Q_PROPERTY(int duration READ getDuration CONSTANT) // Constants but called with a timer in qml.
	Q_PROPERTY(float quality READ getQuality CONSTANT)
	Q_PROPERTY(float speakerVu READ getSpeakerVu CONSTANT)
	Q_PROPERTY(float microVu READ getMicroVu CONSTANT)
	
	Q_PROPERTY(bool speakerMuted READ getSpeakerMuted WRITE setSpeakerMuted NOTIFY speakerMutedChanged)
	Q_PROPERTY(bool microMuted READ getMicroMuted WRITE setMicroMuted NOTIFY microMutedChanged)
	
	Q_PROPERTY(float speakerVolumeGain READ getSpeakerVolumeGain WRITE setSpeakerVolumeGain NOTIFY speakerVolumeGainChanged)
	Q_PROPERTY(float microVolumeGain READ getMicroVolumeGain WRITE setMicroVolumeGain NOTIFY microVolumeGainChanged)
	
	Q_PROPERTY(bool pausedByUser READ getPausedByUser WRITE setPausedByUser NOTIFY statusChanged)
	Q_PROPERTY(bool pausedByRemote READ getPausedByRemote WRITE setPausedByRemote NOTIFY pausedByRemoteChanged)
	Q_PROPERTY(bool videoEnabled READ getVideoEnabled WRITE setVideoEnabled NOTIFY statusChanged)
	Q_PROPERTY(bool localVideoEnabled READ getLocalVideoEnabled WRITE setVideoEnabled NOTIFY statusChanged)
	Q_PROPERTY(bool cameraEnabled READ getCameraEnabled WRITE setCameraEnabled NOTIFY statusChanged)
	Q_PROPERTY(bool updating READ getUpdating NOTIFY statusChanged)
	
	Q_PROPERTY(bool recording READ getRecording NOTIFY recordingChanged)
	Q_PROPERTY(bool remoteRecording READ getRemoteRecording NOTIFY remoteRecordingChanged)

	Q_PROPERTY(bool snapshotEnabled READ getSnapshotEnabled NOTIFY snapshotEnabledChanged)	// Grid doesn't enable snapshot
	
	Q_PROPERTY(QVariantList audioStats READ getAudioStats NOTIFY statsUpdated)
	Q_PROPERTY(QVariantList videoStats READ getVideoStats NOTIFY statsUpdated)
	Q_PROPERTY(QVariantList encryptionStats READ getEncryptionStats NOTIFY statsUpdated)
	
	Q_PROPERTY(CallEncryption encryption READ getEncryption WRITE setEncryption NOTIFY encryptionChanged)
	Q_PROPERTY(bool isSecured READ isSecured NOTIFY securityUpdated)
	Q_PROPERTY(QString localSas READ getLocalSas NOTIFY securityUpdated)
	Q_PROPERTY(QString remoteSas READ getRemoteSas NOTIFY securityUpdated)
	Q_PROPERTY(QString securedString READ getSecuredString NOTIFY securityUpdated)
	Q_PROPERTY(CallPQState isPQZrtp MEMBER mIsPQZrtp WRITE isPQZrtp NOTIFY isPQZrtpChanged)
	
	Q_PROPERTY(QString transferAddress READ getTransferAddress WRITE setTransferAddress NOTIFY transferAddressChanged)
	
	Q_PROPERTY(LinphoneEnums::ConferenceLayout conferenceVideoLayout READ getConferenceVideoLayout WRITE changeConferenceVideoLayout NOTIFY conferenceVideoLayoutChanged)
	
	
	
public:
	enum CallStatus {
		CallStatusConnected,
		CallStatusEnded,
		CallStatusIdle,
		CallStatusIncoming,
		CallStatusOutgoing,
		CallStatusPaused
	};
	Q_ENUM(CallStatus);
	
	enum CallEncryption {
		CallEncryptionNone = int(linphone::MediaEncryption::None),
		CallEncryptionDtls = int(linphone::MediaEncryption::DTLS),
		CallEncryptionSrtp = int(linphone::MediaEncryption::SRTP),
		CallEncryptionZrtp = int(linphone::MediaEncryption::ZRTP)
	};
	Q_ENUM(CallEncryption);
	
	enum CallPQState {
		CallPQStateNone = 0,
		CallPQStateOn,
		CallPQStateOff,
	};
	Q_ENUM(CallPQState);
	
	CallModel (std::shared_ptr<linphone::Call> call);
	~CallModel ();
	void removeCall();
	
	std::shared_ptr<linphone::Call> getCall () const {
		return mCall;
	}
	
	QString getPeerAddress () const;
	QString getLocalAddress () const;
	QString getFullPeerAddress () const;
	QString getFullLocalAddress () const;
	std::shared_ptr<linphone::Address> getConferenceAddress () const;
	
	ContactModel *getContactModel() const;
	ChatRoomModel * getChatRoomModel();
	ConferenceModel* getConferenceModel();
	ConferenceInfoModel* getConferenceInfoModel();
	QSharedPointer<ConferenceModel> getConferenceSharedModel();
	
	bool isInConference () const;
	bool isConference () const;
	bool isOneToOne() const;
	
	void setRecordFile (const std::shared_ptr<linphone::CallParams> &callParams);
	static void setRecordFile (const std::shared_ptr<linphone::CallParams> &callParams, const QString &to);
	
	void updateStats (const std::shared_ptr<const linphone::CallStats> &callStats);
	
	void notifyCameraFirstFrameReceived (unsigned int width, unsigned int height);
	
	Q_INVOKABLE void accept ();
	Q_INVOKABLE void acceptWithVideo ();
	Q_INVOKABLE void terminate ();
	
	Q_INVOKABLE void askForTransfer ();
	Q_INVOKABLE void askForAttendedTransfer ();
	Q_INVOKABLE bool transferTo (const QString &sipAddress);
	Q_INVOKABLE bool transferToAnother (const QString &peerAddress);
	
	Q_INVOKABLE bool getRemoteVideoEnabled () const;
	Q_INVOKABLE void acceptVideoRequest ();
	Q_INVOKABLE void rejectVideoRequest ();
	
	Q_INVOKABLE void takeSnapshot ();
	
	Q_INVOKABLE void startRecording ();
	Q_INVOKABLE void stopRecording ();
	
	Q_INVOKABLE void sendDtmf (const QString &dtmf);
	
	Q_INVOKABLE void verifyAuthenticationToken (bool verify);
	
	Q_INVOKABLE void updateStreams ();
	
	Q_INVOKABLE void toggleSpeakerMute();
	
	void setRemoteDisplayName(const std::string& name);
	
	QString getTransferAddress () const;
	void setTransferAddress (const QString &transferAddress);
	static void prepareTransfert(std::shared_ptr<linphone::Call> call, const QString& transfertAddress);
	
	std::shared_ptr<linphone::Address> getRemoteAddress()const;
	
	LinphoneEnums::ConferenceLayout getConferenceVideoLayout() const;
	void changeConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout);	// Make a call request
	void updateConferenceVideoLayout();		// Called from call state changed ater the new layout has been set.
	
	static constexpr int DtmfSoundDelay = 200;
	
	std::shared_ptr<linphone::Call> mCall;
	std::shared_ptr<CallListener> mCallListener;	// This is passed to linpĥone object and must be in shared_ptr
	std::shared_ptr<linphone::ChatRoom> mChatRoom;	// Used chat room for the call.
	std::shared_ptr<linphone::Address> mRemoteAddress;
	std::shared_ptr<linphone::MagicSearch> mMagicSearch;
	
public slots:
	// Set remote display name when a search has been done
	void searchReceived(std::list<std::shared_ptr<linphone::SearchResult>> results);
	void endCall();
	void onRemoteRecording(const std::shared_ptr<linphone::Call> & call, bool recording);
	void onChatRoomInitialized(int state);
	void onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Participant> & participant);
	void onSecurityUpdated();
	
signals:
	void meAdminChanged();
	void callErrorChanged (const QString &callError);
	void callIdChanged();
	void isInConferenceChanged (bool status);
	void conferenceModelChanged();
	void conferenceInfoModelChanged();
	void chatRoomModelChanged();
	void speakerMutedChanged (bool status);
	void microMutedChanged (bool status);
	void cameraEnabledChanged();
	void recordingChanged (bool status);
	void remoteRecordingChanged(bool status);
	void snapshotEnabledChanged();
	void statsUpdated ();
	void statusChanged (CallStatus status);
	void videoRequested ();
	void securityUpdated ();
	void encryptionChanged();
	void isPQZrtpChanged();
	void speakerVolumeGainChanged (float volume);
	void microVolumeGainChanged (float volume);
	void pausedByRemoteChanged();
	
	void cameraFirstFrameReceived (unsigned int width, unsigned int height);
	
	void fullPeerAddressChanged();
	void transferAddressChanged (const QString &transferAddress);
	
	void conferenceVideoLayoutChanged();
	
	
public:
	void handleCallEncryptionChanged (const std::shared_ptr<linphone::Call> &call);
	void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	
	void accept (bool withVideo);
	
	void stopAutoAnswerTimer () const;
	
	CallStatus getStatus () const;
	
	bool isOutgoing () const {
		return mCall && mCall->getDir() == linphone::Call::Dir::Outgoing;
	}
	
	void updateIsInConference ();
	
	void acceptWithAutoAnswerDelay ();
	
	QString getCallError () const;
	void setCallErrorFromReason (linphone::Reason reason);
	
	void setCallId(const QString& callId);
	
	int getDuration () const;
	float getQuality () const;
	float getMicroVu () const;
	float getSpeakerVu () const;
	
	bool getSpeakerMuted () const;
	void setSpeakerMuted (bool status);
	
	bool getMicroMuted () const;
	void setMicroMuted (bool status);

	bool getCameraEnabled () const;
	void setCameraEnabled (bool status);
	
	bool getPausedByUser () const;
	void setPausedByUser (bool status);
	
	bool getPausedByRemote () const;
	void setPausedByRemote (bool status);
	
	bool getLocalVideoEnabled () const;
	
	bool getVideoEnabled () const;
	void setVideoEnabled (bool status);
	
	bool getUpdating () const;
	
	bool getRecording () const;
	bool getRemoteRecording() const;
	bool getSnapshotEnabled() const;
	
	CallEncryption getEncryption () const;
	bool setEncryption(const CallModel::CallEncryption& encryption);// true if changed
	void updateEncryption();
	bool isSecured () const;
	
	QString getLocalSas () const;
	QString getRemoteSas () const;
	
	QString getSecuredString (const std::shared_ptr<const linphone::CallStats> &callStats = nullptr) const;
	
	QVariantList getAudioStats () const;
	QVariantList getVideoStats () const;
	QVariantList getEncryptionStats () const;
	void updateStats (const std::shared_ptr<const linphone::CallStats> &callStats, QVariantList &statsList);
	void updateEncrypionStats (const std::shared_ptr<const linphone::CallStats> &callStats, QVariantList &statsList);
	void isPQZrtp(const CallPQState& isPQ);
	
	QString iceStateToString (linphone::IceState state) const;
	
	float getSpeakerVolumeGain () const;
	void setSpeakerVolumeGain (float volume);
	
	float getMicroVolumeGain () const;
	void setMicroVolumeGain (float volume);
	
	QString generateSavedFilename () const;
	
// Format : Date_Time_From_To
	static QString generateSavedFilename (const QString &from, const QString &to);
	static QStringList splitSavedFilename(const QString& filename);// If doesn't match to generateSavedFilename, return filename
	static QDateTime getDateTimeSavedFilename(const QString& filename);
	static QString getFromSavedFilename(const QString& filename);
	static QString getToSavedFilename(const QString& filename);
private:
	void connectTo(CallListener * listener);

	bool mIsInConference = false;
	CallPQState mIsPQZrtp = CallPQStateNone;
	CallEncryption mEncryption = CallEncryptionNone;
	
	bool mEndByUser = false;
	bool mPausedByRemote = false;
	bool mPausedByUser = false;
	bool mRecording = false;
	LinphoneEnums::ConferenceLayout mConferenceVideoLayout;
	
	bool mWasConnected = false;
	
	bool mNotifyCameraFirstFrameReceived = true;
	
	QString mCallError;
	QString mCallId;
	
	QVariantList mAudioStats;
	QVariantList mVideoStats;
	QVariantList mEncryptionStats;
	std::shared_ptr<SearchListener> mSearch;
	QString mTransferAddress;
	QSharedPointer<ConferenceModel> mConferenceModel;
	QSharedPointer<ConferenceInfoModel> mConferenceInfoModel;
};

#endif // CALL_MODEL_H_
