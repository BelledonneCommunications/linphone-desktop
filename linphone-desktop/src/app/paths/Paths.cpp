/*
 * Paths.cpp
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

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QtDebug>

#include "../../utils.hpp"

#include "Paths.hpp"
#include "config.h"

#define PATH_AVATARS "/avatars/"
#define PATH_CAPTURES "/captures/"
#define PATH_LOGS "/logs/"
#define PATH_THUMBNAILS "/thumbnails/"
#define PATH_USER_CERTIFICATES "/usr-crt/"

#define PATH_CALL_HISTORY_LIST "/call-history.db"
#define PATH_CONFIG "/linphonerc"
#define PATH_FACTORY_CONFIG "/linphonerc-factory"
#define PATH_ROOT_CA "/rootca.pem"
#define PATH_FRIENDS_LIST "/friends.db"
#define PATH_MESSAGE_HISTORY_LIST "/message-history.db"
#define PATH_ZRTP_SECRETS "/zidcache"

using namespace std;

// =============================================================================

inline bool directoryPathExists (const QString &path) {
  QDir dir(path);
  return dir.exists();
}

inline bool filePathExists (const QString &path) {
  QFileInfo info(path);
  if (!directoryPathExists(info.path()))
    return false;

  QFile file(path);
  return file.exists();
}

inline bool filePathExists (const string &path) {
  return filePathExists(Utils::linphoneStringToQString(path));
}

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

inline string getReadableDirectoryPath (const QString &dirname) {
  return Utils::qStringToLinphoneString(QDir::toNativeSeparators(dirname));
}

inline string getWritableDirectoryPath (const QString &dirname) {
  ensureDirectoryPathExists(dirname);
  return getReadableDirectoryPath(dirname);
}

inline string getReadableFilePath (const QString &filename) {
  return Utils::qStringToLinphoneString(QDir::toNativeSeparators(filename));
}

inline string getWritableFilePath (const QString &filename) {
  ensureFilePathExists(filename);
  return getReadableFilePath(filename);
}

// -----------------------------------------------------------------------------

inline QString getAppPackageDataDirpath () {
  QDir dir(QCoreApplication::applicationDirPath());
  if (dir.dirName() == "MacOS") {
    dir.cdUp();
    dir.cd("Resources");
  } else
    dir.cdUp();

  dir.cd("share/linphone");
  return dir.absolutePath();
}

inline QString getAppPackageMsPluginsDirpath () {
  QDir dir(QCoreApplication::applicationDirPath());
  if (dir.dirName() == "MacOS") {
    dir.cdUp();
    dir.cd("Resources");
  } else
    dir.cdUp();

  dir.cd(MSPLUGINS_DIR);
  return dir.absolutePath();
}

inline QString getAppConfigFilepath () {
  if (QSysInfo::productType() == "macos")
    return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_CONFIG;

  return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + PATH_CONFIG;
}

inline QString getAppCallHistoryFilepath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_CALL_HISTORY_LIST;
}

inline QString getAppFactoryConfigFilepath () {
  return getAppPackageDataDirpath() + PATH_FACTORY_CONFIG;
}

inline QString getAppRootCaFilepath () {
  return getAppPackageDataDirpath() + PATH_ROOT_CA;
}

inline QString getAppFriendsFilepath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_FRIENDS_LIST;
}

inline QString getAppMessageHistoryFilepath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_MESSAGE_HISTORY_LIST;
}

// -----------------------------------------------------------------------------

string Paths::getAvatarsDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_AVATARS);
}

string Paths::getCallHistoryFilepath () {
  return getWritableFilePath(getAppCallHistoryFilepath());
}

string Paths::getCapturesDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_CAPTURES);
}

string Paths::getConfigFilepath (const QString &configPath) {
  if (!configPath.isEmpty())
    return getWritableFilePath(QFileInfo(configPath).absoluteFilePath());

  return getWritableFilePath(getAppConfigFilepath());
}

string Paths::getFactoryConfigFilepath () {
  return getReadableFilePath(getAppFactoryConfigFilepath());
}

string Paths::getFriendsListFilepath () {
  return getWritableFilePath(getAppFriendsFilepath());
}

string Paths::getLogsDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_LOGS);
}

string Paths::getMessageHistoryFilepath () {
  return getWritableFilePath(getAppMessageHistoryFilepath());
}

string Paths::getPackageDataDirpath () {
  return getReadableDirectoryPath(getAppPackageDataDirpath());
}

string Paths::getPackageMsPluginsDirpath () {
  return getReadableDirectoryPath(getAppPackageMsPluginsDirpath());
}

string Paths::getRootCaFilepath () {
  return getReadableFilePath(getAppRootCaFilepath());
}

string Paths::getThumbnailsDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_THUMBNAILS);
}

string Paths::getUserCertificatesDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_USER_CERTIFICATES);
}

string Paths::getZrtpSecretsFilepath () {
  return getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_ZRTP_SECRETS);
}

// -----------------------------------------------------------------------------

static void migrateFile (const QString &oldPath, const QString &newPath) {
  QFileInfo info(newPath);
  ensureDirectoryPathExists(info.path());

  if (QFile::copy(oldPath, newPath)) {
    QFile::remove(oldPath);
    qInfo() << "Migrated" << oldPath << "to" << newPath;
  } else {
    qWarning() << "Failed migration of" << oldPath << "to" << newPath;
  }
}

static void migrateConfigurationFile (const QString &oldPath, const QString &newPath) {
  QFileInfo info(newPath);
  ensureDirectoryPathExists(info.path());

  if (QFile::copy(oldPath, newPath)) {
    QFile oldFile(oldPath);
    if (oldFile.open(QIODevice::WriteOnly)) {
      QTextStream stream(&oldFile);
      stream << "This file has been migrated to " << newPath;
    }

    QFile::setPermissions(oldPath, QFileDevice::ReadOwner);
    qInfo() << "Migrated" << oldPath << "to" << newPath;
  } else {
    qWarning() << "Failed migration of" << oldPath << "to" << newPath;
  }
}

void Paths::migrate () {
  QString newPath = getAppConfigFilepath();
  QString oldBaseDir = QSysInfo::productType() == "windows"
    ? QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
    : QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
  QString oldPath = oldBaseDir + "/.linphonerc";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateConfigurationFile(oldPath, newPath);

  newPath = getAppCallHistoryFilepath();
  oldPath = oldBaseDir + "/.linphone-call-history.db";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateFile(oldPath, newPath);

  newPath = getAppFriendsFilepath();
  oldPath = oldBaseDir + "/.linphone-friends.db";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateFile(oldPath, newPath);

  newPath = getAppMessageHistoryFilepath();
  oldPath = oldBaseDir + "/.linphone-history.db";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateFile(oldPath, newPath);
}
