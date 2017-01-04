#include <QDir>
#include <QFile>
#include <QStandardPaths>

#include "../utils.hpp"

#include "Paths.hpp"

// =============================================================================

#ifdef _WIN32

#define MAIN_PATH \
  QStandardPaths::writableLocation(QStandardPaths::DataLocation)
#define PATH_CONFIG "linphonerc"

#define LINPHONE_FOLDER "linphone/"

#else

#define MAIN_PATH \
  QStandardPaths::writableLocation(QStandardPaths::HomeLocation)
#define PATH_CONFIG ".linphonerc"

#define LINPHONE_FOLDER ".linphone/"

#endif // ifdef _WIN32

#define PATH_AVATARS LINPHONE_FOLDER "avatars/"
#define PATH_LOGS LINPHONE_FOLDER "logs/"

#define PATH_CALL_HISTORY_LIST ".linphone-call-history.db"
#define PATH_FRIENDS_LIST ".linphone-friends.db"
#define PATH_MESSAGE_HISTORY_LIST ".linphone-history.db"

using namespace std;

// =============================================================================

inline void ensureDirectoryPathExists (const QString &path) {
  QDir dir(path);
  if (!dir.exists() && !dir.mkpath(path))
    qFatal("Unable to access at directory: `%s`", path.toStdString().c_str());
}

inline void ensureFilePathExists (const QString &path) {
  QFileInfo info(path);
  ensureDirectoryPathExists(info.path());

  QFile file(path);
  if (!file.exists() && !file.open(QIODevice::ReadWrite))
    qFatal("Unable to access at path: `%s`", path.toStdString().c_str());
}

inline string getDirectoryPath (const QString &dirname) {
  ensureDirectoryPathExists(dirname);
  return Utils::qStringToLinphoneString(QDir::toNativeSeparators(dirname));
}

inline string getFilePath (const QString &filename) {
  ensureFilePathExists(filename);
  return Utils::qStringToLinphoneString(QDir::toNativeSeparators(filename));
}

// -----------------------------------------------------------------------------

string Paths::getAvatarsDirpath () {
  return getDirectoryPath(MAIN_PATH + "/" PATH_AVATARS);
}

string Paths::getCallHistoryFilepath () {
  return getFilePath(MAIN_PATH + "/" + PATH_CALL_HISTORY_LIST);
}

string Paths::getConfigFilepath () {
  return getFilePath(MAIN_PATH + "/" + PATH_CONFIG);
}

string Paths::getFriendsListFilepath () {
  return getFilePath(MAIN_PATH + "/" + PATH_FRIENDS_LIST);
}

string Paths::getLogsDirpath () {
  return getDirectoryPath(MAIN_PATH + "/" PATH_LOGS);
}

string Paths::getMessageHistoryFilepath () {
  return getFilePath(MAIN_PATH + "/" + PATH_MESSAGE_HISTORY_LIST);
}
