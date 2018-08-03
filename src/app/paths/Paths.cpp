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

#include "config.h"

#include "utils/Utils.hpp"

#include "Paths.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char PathAssistantConfig[] = "/" EXECUTABLE_NAME "/assistant/";
  constexpr char PathAvatars[] = "/avatars/";
  constexpr char PathCaptures[] = "/" EXECUTABLE_NAME "/captures/";
  constexpr char PathCodecs[] =  "/codecs/";
  constexpr char PathLogs[] = "/logs/";
  constexpr char PathPlugins[] = "/plugins/";
  constexpr char PathThumbnails[] = "/thumbnails/";
  constexpr char PathUserCertificates[] = "/usr-crt/";

  constexpr char PathCallHistoryList[] = "/call-history.db";
  constexpr char PathConfig[] = "/linphonerc";
  constexpr char PathFactoryConfig[] = "/" EXECUTABLE_NAME "/linphonerc-factory";
  constexpr char PathRootCa[] = "/" EXECUTABLE_NAME "/rootca.pem";
  constexpr char PathFriendsList[] = "/friends.db";
  constexpr char PathMessageHistoryList[] = "/message-history.db";
  constexpr char PathZrtpSecrets[] = "/zidcache";
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
  if (dir.dirName() == QLatin1String("MacOS")) {
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
  return getAppPackageDataDirPath() + PathAssistantConfig;
}

static inline QString getAppConfigFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + PathConfig;
}

static inline QString getAppCallHistoryFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathCallHistoryList;
}

static inline QString getAppFactoryConfigFilePath () {
  return getAppPackageDataDirPath() + PathFactoryConfig;
}

static inline QString getAppRootCaFilePath () {
  return getAppPackageDataDirPath() + PathRootCa;
}

static inline QString getAppFriendsFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathFriendsList;
}

static inline QString getAppMessageHistoryFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathMessageHistoryList;
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
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathAvatars);
}

string Paths::getCallHistoryFilePath () {
  return getWritableFilePath(getAppCallHistoryFilePath());
}

string Paths::getCapturesDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + PathCaptures);
}

string Paths::getCodecsDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathCodecs);
}

string Paths::getConfigFilePath (const QString &configPath, bool writable) {
  const QString path = configPath.isEmpty()
    ? getAppConfigFilePath()
    : QFileInfo(configPath).absoluteFilePath();

  return writable ? getWritableFilePath(path) : getReadableFilePath(path);
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
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathLogs);
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
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathThumbnails);
}

string Paths::getUserCertificatesDirPath () {
  return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathUserCertificates);
}

string Paths::getZrtpSecretsFilePath () {
  return getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PathZrtpSecrets);
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
  QString oldBaseDir = QSysInfo::productType() == QLatin1String("windows")
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
