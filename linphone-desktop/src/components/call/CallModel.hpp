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

  Q_PROPERTY(bool isOutgoing READ isOutgoing CONSTANT);
  Q_PROPERTY(int duration READ getDuration CONSTANT); // Constant but called with a timer in qml.
  Q_PROPERTY(float quality READ getQuality CONSTANT); // Same idea.
  Q_PROPERTY(bool microMuted READ getMicroMuted WRITE setMicroMuted NOTIFY microMutedChanged);

  Q_PROPERTY(bool pausedByUser READ getPausedByUser WRITE setPausedByUser NOTIFY statusChanged);
  Q_PROPERTY(bool videoEnabled READ getVideoEnabled WRITE setVideoEnabled NOTIFY statusChanged);
  Q_PROPERTY(bool updating READ getUpdating NOTIFY statusChanged)

  Q_PROPERTY(bool recording READ getRecording NOTIFY recordingChanged);

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

  CallModel (std::shared_ptr<linphone::Call> linphone_call);
  ~CallModel () = default;

  std::shared_ptr<linphone::Call> getLinphoneCall () const {
    return m_linphone_call;
  }

  static void setRecordFile (shared_ptr<linphone::CallParams> &call_params);

  Q_INVOKABLE void accept ();
  Q_INVOKABLE void acceptWithVideo ();
  Q_INVOKABLE void terminate ();
  Q_INVOKABLE void transfer ();

  Q_INVOKABLE void acceptVideoRequest ();
  Q_INVOKABLE void rejectVideoRequest ();

  Q_INVOKABLE void takeSnapshot ();

  Q_INVOKABLE void startRecording ();
  Q_INVOKABLE void stopRecording ();

signals:
  void statusChanged (CallStatus status);
  void microMutedChanged (bool status);
  void videoRequested ();
  void recordingChanged (bool status);

private:
  void stopAutoAnswerTimer () const;

  QString getSipAddress () const;

  CallStatus getStatus () const;
  bool isOutgoing () const {
    return m_linphone_call->getDir() == linphone::CallDirOutgoing;
  }

  int getDuration () const;
  float getQuality () const;

  bool getMicroMuted () const;
  void setMicroMuted (bool status);

  bool getPausedByUser () const;
  void setPausedByUser (bool status);

  bool getVideoEnabled () const;
  void setVideoEnabled (bool status);

  bool getUpdating () const;

  bool getRecording () const;

  bool m_paused_by_remote = false;
  bool m_paused_by_user = false;
  bool m_recording = false;

  std::shared_ptr<linphone::Call> m_linphone_call;
};

#endif // CALL_MODEL_H_
