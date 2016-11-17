#include <QDir>
#include <QFile>
#include <QStandardPaths>

#include "Database.hpp"

#ifdef _WIN32
  #define DATABASES_PATH \
    QStandardPaths::writableLocation(QStandardPaths::DataLocation)
#else
  #define DATABASES_PATH \
    QStandardPaths::writableLocation(QStandardPaths::HomeLocation)
#endif

#define DATABASE_PATH_FRIENDS_LIST ".linphone-friends.db"
#define DATABASE_PATH_CALL_HISTORY_LIST ".linphone-call-history.db"
#define DATABASE_PATH_MESSAGE_HISTORY_LIST ".linphone-history.db"

// ===================================================================

inline bool ensureDatabaseFilePathExists (const QString &path) {
  QDir dir(DATABASES_PATH);

  if (!dir.exists() && !dir.mkpath(DATABASES_PATH))
    return false;

  QFile file(path);

  return file.exists() || file.open(QIODevice::ReadWrite);
}

inline std::string getDatabaseFilePath (const QString &filename) {
  QString path(DATABASES_PATH + "/");
  path += filename;
  return ensureDatabaseFilePathExists(path)
    ? QDir::toNativeSeparators(path).toStdString()
    : "";
}

std::string Database::getFriendsListPath () {
  return getDatabaseFilePath(DATABASE_PATH_FRIENDS_LIST);
}

std::string Database::getCallHistoryPath () {
  return getDatabaseFilePath(DATABASE_PATH_CALL_HISTORY_LIST);
}

std::string Database::getMessageHistoryPath () {
  return getDatabaseFilePath(DATABASE_PATH_MESSAGE_HISTORY_LIST);
}
