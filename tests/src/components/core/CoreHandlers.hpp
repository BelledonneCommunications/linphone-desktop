#ifndef CORE_HANDLERS_H_
#define CORE_HANDLERS_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class CoreHandlers :
  public QObject,
  public linphone::CoreListener {
  Q_OBJECT;

public:
  void onAuthenticationRequested (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::AuthInfo> &auth_info,
    linphone::AuthMethod method
  ) override;

  void onCallStateChanged (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::Call> &call,
    linphone::CallState cstate,
    const std::string &message
  ) override;

  void onMessageReceived (
    const std::shared_ptr<linphone::Core> &core,
    const std::shared_ptr<linphone::ChatRoom> &room,
    const std::shared_ptr<linphone::ChatMessage> &message
  ) override;

signals:
  void receivedMessage (
    const std::shared_ptr<linphone::ChatRoom> &room,
    const std::shared_ptr<linphone::ChatMessage> &message
  );
};

#endif // CORE_HANDLERS_H_
