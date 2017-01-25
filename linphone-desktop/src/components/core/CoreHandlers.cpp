#include <QtDebug>

#include "../../app/App.hpp"
#include "CoreManager.hpp"

#include "CoreHandlers.hpp"

using namespace std;

// =============================================================================

void CoreHandlers::onAuthenticationRequested (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::AuthInfo> &,
  linphone::AuthMethod
) {
  qDebug() << "Auth request";
}

void CoreHandlers::onCallStateChanged (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::Call> &call,
  linphone::CallState state,
  const string &
) {
  emit callStateChanged(call, state);
}

void CoreHandlers::onMessageReceived (
  const shared_ptr<linphone::Core> &,
  const shared_ptr<linphone::ChatRoom> &room,
  const shared_ptr<linphone::ChatMessage> &message
) {
  emit messageReceived(message);

  const App *app = App::getInstance();
  if (!app->hasFocus())
    app->getNotifier()->notifyReceivedMessage(10000, room, message);
}
