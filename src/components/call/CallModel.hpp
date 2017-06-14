/*
 * CallModel.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef CALL_MODEL_H_
#define CALL_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class CallModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QString sipAddress READ getSipAddress CONSTANT);
  Q_PROPERTY(CallStatus status READ getStatus NOTIFY statusChanged);
  Q_PROPERTY(QString callError READ getCallError NOTIFY callErrorChanged);

  Q_PROPERTY(bool isOutgoing READ isOutgoing CONSTANT);

  Q_PROPERTY(bool isInConference READ isInConference NOTIFY isInConferenceChanged);

  Q_PROPERTY(int duration READ getDuration CONSTANT); // Constants but called with a timer in qml.
  Q_PROPERTY(float quality READ getQuality CONSTANT);
  Q_PROPERTY(float microVu READ getMicroVu CONSTANT);
  Q_PROPERTY(float speakerVu READ getSpeakerVu CONSTANT);

  Q_PROPERTY(bool microMuted READ getMicroMuted WRITE setMicroMuted NOTIFY microMutedChanged);

  Q_PROPERTY(bool pausedByUser READ getPausedByUser WRITE setPausedByUser NOTIFY statusChanged);
  Q_PROPERTY(bool videoEnabled READ getVideoEnabled WRITE setVideoEnabled NOTIFY statusChanged);
  Q_PROPERTY(bool updating READ getUpdating NOTIFY statusChanged)

  Q_PROPERTY(bool recording READ getRecording NOTIFY recordingChanged);

  Q_PROPERTY(QVariantList audioStats READ getAudioStats NOTIFY statsUpdated);
  Q_PROPERTY(QVariantList videoStats READ getVideoStats NOTIFY statsUpdated);

  Q_PROPERTY(CallEncryption encryption READ getEncryption NOTIFY securityUpdated);
  Q_PROPERTY(bool isSecured READ isSecured NOTIFY securityUpdated);
  Q_PROPERTY(QString localSas READ getLocalSas NOTIFY securityUpdated);
  Q_PROPERTY(QString remoteSas READ getRemoteSas NOTIFY securityUpdated);
  Q_PROPERTY(QString securedString READ getSecuredString NOTIFY securityUpdated);

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
    CallEncryptionNone = linphone::MediaEncryptionNone,
    CallEncryptionDtls = linphone::MediaEncryptionDTLS,
    CallEncryptionSrtp = linphone::MediaEncryptionSRTP,
    CallEncryptionZrtp = linphone::MediaEncryptionZRTP
  };

  Q_ENUM(CallEncryption);

  CallModel (std::shared_ptr<linphone::Call> linphoneCall);
  ~CallModel ();

  std::shared_ptr<linphone::Call> getCall () const {
    return mCall;
  }

  QString getSipAddress () const;

  bool isInConference () const {
    return mIsInConference;
  }

  static void setRecordFile (std::shared_ptr<linphone::CallParams> &callParams);
  void updateStats (const std::shared_ptr<const linphone::CallStats> &callStats);

  void notifyCameraFirstFrameReceived (unsigned int width, unsigned int height);

  Q_INVOKABLE void accept ();
  Q_INVOKABLE void acceptWithVideo ();
  Q_INVOKABLE void terminate ();

  Q_INVOKABLE void askForTransfer ();
  Q_INVOKABLE bool transferTo (const QString &sipAddress);

  Q_INVOKABLE void acceptVideoRequest ();
  Q_INVOKABLE void rejectVideoRequest ();

  Q_INVOKABLE void takeSnapshot ();

  Q_INVOKABLE void startRecording ();
  Q_INVOKABLE void stopRecording ();

  Q_INVOKABLE void sendDtmf (const QString &dtmf);

  Q_INVOKABLE void verifyAuthenticationToken (bool verify);

signals:
  void callErrorChanged (const QString &callError);
  void isInConferenceChanged (bool status);
  void microMutedChanged (bool status);
  void recordingChanged (bool status);
  void statsUpdated ();
  void statusChanged (CallStatus status);
  void videoRequested ();
  void securityUpdated ();

  void cameraFirstFrameReceived (unsigned int width, unsigned int height);

private:
  void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::CallState state);

  void stopAutoAnswerTimer () const;

  CallStatus getStatus () const;

  bool isOutgoing () const {
    return mCall->getDir() == linphone::CallDirOutgoing;
  }

  void updateIsInConference ();

  void acceptWithAutoAnswerDelay ();

  QString getCallError () const;
  void setCallErrorFromReason (linphone::Reason reason);

  int getDuration () const;
  float getQuality () const;
  float getMicroVu () const;
  float getSpeakerVu () const;

  bool getMicroMuted () const;
  void setMicroMuted (bool status);

  bool getPausedByUser () const;
  void setPausedByUser (bool status);

  bool getVideoEnabled () const;
  void setVideoEnabled (bool status);

  bool getUpdating () const;

  bool getRecording () const;

  CallEncryption getEncryption () const;
  bool isSecured () const;

  QString getLocalSas () const;
  QString getRemoteSas () const;

  QString getSecuredString () const;

  QVariantList getAudioStats () const;
  QVariantList getVideoStats () const;
  void updateStats (const std::shared_ptr<const linphone::CallStats> &callStats, QVariantList &statsList);

  QString iceStateToString (linphone::IceState state) const;

  bool mIsInConference = false;

  bool mPausedByRemote = false;
  bool mPausedByUser = false;
  bool mRecording = false;

  bool mNotifyCameraFirstFrameReceived = true;

  QString mCallError;

  QVariantList mAudioStats;
  QVariantList mVideoStats;

  std::shared_ptr<linphone::Call> mCall;
};

#endif // CALL_MODEL_H_
