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
#define PATH_FRIENDS_LIST "/friends.db"
#define PATH_MESSAGE_HISTORY_LIST "/message-history.db"
#define PATH_ZRTP_SECRETS "/zidcache"
#define PATH_ZRTP_DATA "/zrtp-lime.db"

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

static QString getAppPackageDataDirpath () {
  QDir dir(QCoreApplication::applicationDirPath());
  if (dir.dirName() == "MacOS") {
    dir.cdUp();
    dir.cd("Resources");
  } else {
    dir.cdUp();
  }
  dir.cd("share/linphone");
  return dir.absolutePath();
}

static QString getAppPackageMsPluginsDirpath () {
  QDir dir(QCoreApplication::applicationDirPath());
  if (dir.dirName() == "MacOS") {
    dir.cdUp();
    dir.cd("Resources");
  } else {
    dir.cdUp();
  }
  dir.cd(MSPLUGINS_DIR);
  return dir.absolutePath();
}

static QString getAppConfigFilepath () {
  if (QSysInfo::productType() == "macos")
    return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_CONFIG;

  return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + PATH_CONFIG;
}

static QString getAppCallHistoryFilepath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_CALL_HISTORY_LIST;
}

static QString getAppFactoryConfigFilepath () {
  return getAppPackageDataDirpath() + PATH_FACTORY_CONFIG;
}

static QString getAppFriendsFilepath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_FRIENDS_LIST;
}

static QString getAppMessageHistoryFilepath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_MESSAGE_HISTORY_LIST;
}

// -----------------------------------------------------------------------------

string Paths::getAvatarsDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_AVATARS);
}

string Paths::getCallHistoryFilepath () {
  return getWritableFilePath(getAppCallHistoryFilepath());
}

string Paths::getConfigFilepath (const QString &config_path) {
  if (!config_path.isEmpty())
    return getWritableFilePath(QFileInfo(config_path).absoluteFilePath());

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

string Paths::getThumbnailsDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_THUMBNAILS);
}

string Paths::getCapturesDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_CAPTURES);
}

string Paths::getZrtpSecretsFilepath () {
  return getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + PATH_ZRTP_SECRETS);
}

string Paths::getZrtpDataFilepath () {
  return getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_ZRTP_DATA);
}

string Paths::getUserCertificatesDirpath () {
  return getWritableDirectoryPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_USER_CERTIFICATES);
}

// -----------------------------------------------------------------------------

static void migrateFile (const QString &old_path, const QString &new_path) {
  QFileInfo info(new_path);
  ensureDirectoryPathExists(info.path());

  if (QFile::copy(old_path, new_path)) {
    QFile::remove(old_path);
    qInfo() << "Migrated" << old_path << "to" << new_path;
  } else {
    qWarning() << "Failed migration of" << old_path << "to" << new_path;
  }
}

static void migrateConfigurationFile (const QString &old_path, const QString &new_path) {
  QFileInfo info(new_path);
  ensureDirectoryPathExists(info.path());

  if (QFile::copy(old_path, new_path)) {
    QFile old_file(old_path);
    if (old_file.open(QIODevice::WriteOnly)) {
      QTextStream stream(&old_file);
      stream << "This file has been migrated to " << new_path;
    }

    QFile::setPermissions(old_path, QFileDevice::ReadOwner);
    qInfo() << "Migrated" << old_path << "to" << new_path;
  } else {
    qWarning() << "Failed migration of" << old_path << "to" << new_path;
  }
}

void Paths::migrate () {
  QString new_path = getAppConfigFilepath();
  QString old_base_dir = QSysInfo::productType() == "windows"
    ? QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
    : QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
  QString old_path = old_base_dir + "/.linphonerc";

  if (!filePathExists(new_path) && filePathExists(old_path))
    migrateConfigurationFile(old_path, new_path);

  new_path = getAppCallHistoryFilepath();
  old_path = old_base_dir + "/.linphone-call-history.db";

  if (!filePathExists(new_path) && filePathExists(old_path))
    migrateFile(old_path, new_path);

  new_path = getAppFriendsFilepath();
  old_path = old_base_dir + "/.linphone-friends.db";

  if (!filePathExists(new_path) && filePathExists(old_path))
    migrateFile(old_path, new_path);

  new_path = getAppMessageHistoryFilepath();
  old_path = old_base_dir + "/.linphone-history.db";

  if (!filePathExists(new_path) && filePathExists(old_path))
    migrateFile(old_path, new_path);
}
