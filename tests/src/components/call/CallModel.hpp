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
  Q_PROPERTY(bool microMuted READ getMicroMuted WRITE setMicroMuted NOTIFY microMutedChanged);
  Q_PROPERTY(bool pausedByUser READ getPausedByUser WRITE setPausedByUser NOTIFY pausedByUserChanged);
  Q_PROPERTY(bool videoOutputEnabled READ getVideoOutputEnabled WRITE setVideoOutputEnabled NOTIFY videoOutputEnabled);

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

  Q_INVOKABLE void accept ();
  Q_INVOKABLE void acceptWithVideo ();
  Q_INVOKABLE void terminate ();
  Q_INVOKABLE void transfer ();

signals:
  void statusChanged (CallStatus status);
  void pausedByUserChanged (bool status);
  void microMutedChanged (bool status);
  void videoOutputEnabled (bool status);

private:
  QString getSipAddress () const;

  CallStatus getStatus () const;
  bool isOutgoing () const {
    return m_linphone_call->getDir() == linphone::CallDirOutgoing;
  }

  bool getMicroMuted () const;
  void setMicroMuted (bool status);

  bool getPausedByUser () const;
  void setPausedByUser (bool status);

  bool getVideoOutputEnabled () const;
  void setVideoOutputEnabled (bool status);

  bool m_micro_muted = false;

  linphone::CallState m_linphone_call_status = linphone::CallStateIdle;

  std::shared_ptr<linphone::Call> m_linphone_call;
};

#endif // CALL_MODEL_H_
