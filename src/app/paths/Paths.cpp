/*
 * Paths.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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

#include <linphone++/linphone.hh>
#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>
#include <QtDebug>

#include "utils/Utils.hpp"

#include "config.h"

#include "Paths.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char cPathAssistantConfig[] = "/linphone/assistant/";
  constexpr char cPathAvatars[] = "/avatars/";
  constexpr char cPathCaptures[] = "/Linphone/captures/";
  constexpr char cPathCodecs[] =  "/codecs/";
  constexpr char cPathLogs[] = "/logs/";
  constexpr char cPathPlugins[] = "/plugins/";
  constexpr char cPathThumbnails[] = "/thumbnails/";
  constexpr char cPathUserCertificates[] = "/usr-crt/";

  constexpr char cPathCallHistoryList[] = "/call-history.db";
  constexpr char cPathConfig[] = "/linphonerc";
  constexpr char cPathFactoryConfig[] = "/linphone/linphonerc-factory";
  constexpr char cPathRootCa[] = "/linphone/rootca.pem";
  constexpr char cPathFriendsList[] = "/friends.db";
  constexpr char cPathMessageHistoryList[] = "/message-history.db";
  constexpr char cPathZrtpSecrets[] = "/zidcache";
}

static inline bool dirPathExists (const QString &path) {
  QDir dir(path);
  return dir.exists();
}

static inline bool filePathExists (const QString &path) {
  QFileInfo info(path);
  if (!dirPathExists(info.path()))
    return false;

  QFile file(path);
  return file.exists();
}

static inline void ensureDirPathExists (const QString &path) {
  QDir dir(path);
  if (!dir.exists() && !dir.mkpath(path))
    qFatal("Unable to access at directory: `%s`", path.toStdString().c_str());
}

static inline void ensureFilePathExists (const QString &path) {
  QFileInfo info(path);
  ensureDirPathExists(info.path());

  QFile file(path);
  if (!file.exists() && !file.open(QIODevice::ReadWrite))
    qFatal("Unable to access at path: `%s`", path.toStdString().c_str());
}

static inline string getReadableDirPath (const QString &dirname) {
  return Utils::appStringToCoreString(QDir::toNativeSeparators(dirname));
}

static inline string getWritableDirPath (const QString &dirname) {
  ensureDirPathExists(dirname);
  return getReadableDirPath(dirname);
}

static inline string getReadableFilePath (const QString &filename) {
  return Utils::appStringToCoreString(QDir::toNativeSeparators(filename));
}

static inline string getWritableFilePath (const QString &filename) {
  ensureFilePathExists(filename);
  return getReadableFilePath(filename);
}

// -----------------------------------------------------------------------------

static inline QDir getAppPackageDir () {
  QDir dir(QCoreApplication::applicationDirPath());
  if (dir.dirName() == "MacOS") {
    dir.cdUp();
    dir.cd("Resources");
  } else
    dir.cdUp();
  return dir;
}

static inline QString getAppPackageDataDirPath () {
  QDir dir = getAppPackageDir();
  dir.cd("share");
  return dir.absolutePath();
}

static inline QString getAppPackageMsPluginsDirPath () {
  QDir dir = getAppPackageDir();
  dir.cd(MSPLUGINS_DIR);
  return dir.absolutePath();
}

static inline QString getAppAssistantConfigDirPath () {
  return getAppPackageDataDirPath() + cPathAssistantConfig;
}

static inline QString getAppConfigFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + cPathConfig;
}

static inline QString getAppCallHistoryFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathCallHistoryList;
}

static inline QString getAppFactoryConfigFilePath () {
  return getAppPackageDataDirPath() + cPathFactoryConfig;
}

static inline QString getAppPluginsDirPath () {
  return getAppPackageDataDirPath() + cPathPlugins;
}

static inline QString getAppRootCaFilePath () {
  return getAppPackageDataDirPath() + cPathRootCa;
}

static inline QString getAppFriendsFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathFriendsList;
}

static inline QString getAppMessageHistoryFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathMessageHistoryList;
}

// -----------------------------------------------------------------------------

bool Paths::filePathExists (const string &path) {
  return filePathExists(Utils::coreStringToAppString(path));
}

// -----------------------------------------------------------------------------

string Paths::getAssistantConfigDirPath () {
  return getReadableDirPath(getAppAssistantConfigDirPath());
}

string Paths::getAvatarsDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathAvatars);
}

string Paths::getCallHistoryFilePath () {
  return getWritableFilePath(getAppCallHistoryFilePath());
}

string Paths::getCapturesDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + cPathCaptures);
}

string Paths::getCodecsDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathCodecs);
}

string Paths::getConfigFilePath (const QString &configPath, bool writable) {
  const QString path = configPath.isEmpty()
    ? getAppConfigFilePath()
    : QFileInfo(configPath).absoluteFilePath();

  return writable ? ::getWritableFilePath(path) : ::getReadableFilePath(path);
}

string Paths::getFactoryConfigFilePath () {
  return getReadableFilePath(getAppFactoryConfigFilePath());
}

string Paths::getFriendsListFilePath () {
  return getWritableFilePath(getAppFriendsFilePath());
}

string Paths::getDownloadDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation));
}

string Paths::getLogsDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathLogs);
}

string Paths::getMessageHistoryFilePath () {
  return getWritableFilePath(getAppMessageHistoryFilePath());
}

string Paths::getPackageDataDirPath () {
  return getReadableDirPath(getAppPackageDataDirPath());
}

string Paths::getPackageMsPluginsDirPath () {
  return getReadableDirPath(getAppPackageMsPluginsDirPath());
}

string Paths::getRootCaFilePath () {
  return getReadableFilePath(getAppRootCaFilePath());
}

string Paths::getThumbnailsDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathThumbnails);
}

string Paths::getUserCertificatesDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathUserCertificates);
}

string Paths::getZrtpSecretsFilePath () {
  return getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + cPathZrtpSecrets);
}

// -----------------------------------------------------------------------------

static void migrateFile (const QString &oldPath, const QString &newPath) {
  QFileInfo info(newPath);
  ensureDirPathExists(info.path());

  if (QFile::copy(oldPath, newPath)) {
    QFile::remove(oldPath);
    qInfo() << "Migrated" << oldPath << "to" << newPath;
  } else {
    qWarning() << "Failed migration of" << oldPath << "to" << newPath;
  }
}

static void migrateConfigurationFile (const QString &oldPath, const QString &newPath) {
  QFileInfo info(newPath);
  ensureDirPathExists(info.path());

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
  QString newPath = getAppConfigFilePath();
  QString oldBaseDir = QSysInfo::productType() == "windows"
    ? QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
    : QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
  QString oldPath = oldBaseDir + "/.linphonerc";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateConfigurationFile(oldPath, newPath);

  newPath = getAppCallHistoryFilePath();
  oldPath = oldBaseDir + "/.linphone-call-history.db";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateFile(oldPath, newPath);

  newPath = getAppFriendsFilePath();
  oldPath = oldBaseDir + "/.linphone-friends.db";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateFile(oldPath, newPath);

  newPath = getAppMessageHistoryFilePath();
  oldPath = oldBaseDir + "/.linphone-history.db";

  if (!filePathExists(newPath) && filePathExists(oldPath))
    migrateFile(oldPath, newPath);
}
