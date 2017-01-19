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

  Q_PROPERTY(bool pausedByUser READ getPausedByUser WRITE setPausedByUser NOTIFY pausedByUserChanged);

public:
  enum CallStatus {
    CallStatusConnected,
    CallStatusEnded,
    CallStatusIncoming,
    CallStatusOutgoing,
    CallStatusPaused
  };

  Q_ENUM(CallStatus);

  CallModel (std::shared_ptr<linphone::Call> linphone_call);
  ~CallModel () = default;

  Q_INVOKABLE void acceptAudioCall ();
  Q_INVOKABLE void terminateCall ();

signals:
  void statusChanged (CallStatus status);
  void pausedByUserChanged (bool status);

private:
  QString getSipAddress () const;

  CallStatus getStatus () const;

  bool isOutgoing () const {
    return m_linphone_call->getDir() == linphone::CallDirOutgoing;
  }

  bool getPausedByUser () const;
  void setPausedByUser (bool status);

  std::shared_ptr<linphone::Call> m_linphone_call;
};

#endif // CALL_MODEL_H_
