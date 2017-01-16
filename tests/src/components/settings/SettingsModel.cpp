#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "SettingsModel.hpp"

using namespace std;

// =============================================================================

const string SettingsModel::UI_SECTION("ui");

SettingsModel::SettingsModel (QObject *parent) : QObject(parent) {
  // TODO: Uncomment when `getConfig` will be available.
  // m_config = CoreManager::getInstance()->getCore()->getConfig();
}

bool SettingsModel::getAutoAnswerStatus () const {
  return true; // TODO: See above.
  return !!m_config->getInt(UI_SECTION, "auto_answer", 0);
}

void SettingsModel::setAutoAnswerStatus (bool status) {
  m_config->setInt(UI_SECTION, "auto_answer", status);
  emit autoAnswerStatusChanged(status);
}

QString SettingsModel::getFileTransferUrl () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getFileTransferServer()
  );
}

void SettingsModel::setFileTransferUrl (const QString &url) {
  CoreManager::getInstance()->getCore()->setFileTransferServer(
    ::Utils::qStringToLinphoneString(url)
  );
}
