#include <QDir>
#include <QFile>
#include <QStandardPaths>

#include "../utils.hpp"

#include "Database.hpp"

#ifdef _WIN32
#define DATABASES_PATH \
  QStandardPaths::writableLocation(QStandardPaths::DataLocation)
#else
#define DATABASES_PATH \
  QStandardPaths::writableLocation(QStandardPaths::HomeLocation)
#endif // ifdef _WIN32

#define DATABASE_PATH_AVATARS ".linphone/avatars/"
#define DATABASE_PATH_CALL_HISTORY_LIST ".linphone-call-history.db"
#define DATABASE_PATH_FRIENDS_LIST ".linphone-friends.db"
#define DATABASE_PATH_MESSAGE_HISTORY_LIST ".linphone-history.db"

using namespace std;

// =============================================================================

inline bool ensureDatabaseFilePathExists (const QString &path) {
  QDir dir(DATABASES_PATH);

  if (!dir.exists() && !dir.mkpath(DATABASES_PATH))
    return false;

  QFile file(path);

  return file.exists() || file.open(QIODevice::ReadWrite);
}

string Database::getAvatarsPath () {
  QString path(DATABASES_PATH + "/" DATABASE_PATH_AVATARS);
  QDir dir(path);

  if (!dir.exists() && !dir.mkpath(path))
    return "";

  return Utils::qStringToLinphoneString(QDir::toNativeSeparators(path));
}

inline string getDatabaseFilePath (const QString &filename) {
  QString path(DATABASES_PATH + "/");
  path += filename;
  return ensureDatabaseFilePathExists(path) ? Utils::qStringToLinphoneString(
    QDir::toNativeSeparators(path)
  ) : "";
}

string Database::getCallHistoryPath () {
  return getDatabaseFilePath(DATABASE_PATH_CALL_HISTORY_LIST);
}

string Database::getFriendsListPath () {
  return getDatabaseFilePath(DATABASE_PATH_FRIENDS_LIST);
}

string Database::getMessageHistoryPath () {
  return getDatabaseFilePath(DATABASE_PATH_MESSAGE_HISTORY_LIST);
}
