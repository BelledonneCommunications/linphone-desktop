#include <QtDebug>

#include "CoreManager.hpp"

#include "CoreHandlers.hpp"

using namespace std;

// =============================================================================

void CoreHandlers::onAuthenticationRequested (
  const std::shared_ptr<linphone::Core> &lc,
  const std::shared_ptr<linphone::AuthInfo> &auth_info,
  linphone::AuthMethod method
) {
  qDebug() << "Auth request";
}

void CoreHandlers::onCallStateChanged (
  const shared_ptr<linphone::Core> &lc,
  const shared_ptr<linphone::Call> &call,
  linphone::CallState cstate,
  const string &message
) {
  qDebug() << "call";
}

void CoreHandlers::onMessageReceived (
  const shared_ptr<linphone::Core> &lc,
  const shared_ptr<linphone::ChatRoom> &room,
  const shared_ptr<linphone::ChatMessage> &message
) {
  CoreManager::getInstance()->getSipAddressesModel()->handleReceivedMessage(room, message);
}
