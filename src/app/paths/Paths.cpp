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

#include <linphone++/linphone.hh>
#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>
#include <QtDebug>

#include "../../utils/Utils.hpp"

#include "config.h"

#include "Paths.hpp"

#define PATH_ASSISTANT_CONFIG "/linphone/assistant/"
#define PATH_AVATARS "/avatars/"
#define PATH_CAPTURES "/Linphone/captures/"
#define PATH_LOGS "/logs/"
#define PATH_PLUGINS "/plugins/"
#define PATH_THUMBNAILS "/thumbnails/"
#define PATH_USER_CERTIFICATES "/usr-crt/"

#define PATH_CALL_HISTORY_LIST "/call-history.db"
#define PATH_CONFIG "/linphonerc"
#define PATH_FACTORY_CONFIG "/linphone/linphonerc-factory"
#define PATH_ROOT_CA "/linphone/rootca.pem"
#define PATH_FRIENDS_LIST "/friends.db"
#define PATH_MESSAGE_HISTORY_LIST "/message-history.db"
#define PATH_ZRTP_SECRETS "/zidcache"

using namespace std;

// =============================================================================

inline bool dirPathExists (const QString &path) {
  QDir dir(path);
  return dir.exists();
}

inline bool filePathExists (const QString &path) {
  QFileInfo info(path);
  if (!::dirPathExists(info.path()))
    return false;

  QFile file(path);
  return file.exists();
}

inline void ensureDirPathExists (const QString &path) {
  QDir dir(path);
  if (!dir.exists() && !dir.mkpath(path))
    qFatal("Unable to access at directory: `%s`", path.toStdString().c_str());
}

inline void ensureFilePathExists (const QString &path) {
  QFileInfo info(path);
  ::ensureDirPathExists(info.path());

  QFile file(path);
  if (!file.exists() && !file.open(QIODevice::ReadWrite))
    qFatal("Unable to access at path: `%s`", path.toStdString().c_str());
}

inline string getReadableDirPath (const QString &dirname) {
  return ::Utils::appStringToCoreString(QDir::toNativeSeparators(dirname));
}

inline string getWritableDirPath (const QString &dirname) {
  ::ensureDirPathExists(dirname);
  return ::getReadableDirPath(dirname);
}

inline string getReadableFilePath (const QString &filename) {
  return ::Utils::appStringToCoreString(QDir::toNativeSeparators(filename));
}

inline string getWritableFilePath (const QString &filename) {
  ::ensureFilePathExists(filename);
  return ::getReadableFilePath(filename);
}

// -----------------------------------------------------------------------------

inline QDir getAppPackageDir () {
  QDir dir(QCoreApplication::applicationDirPath());
  if (dir.dirName() == "MacOS") {
    dir.cdUp();
    dir.cd("Resources");
  } else
    dir.cdUp();
  return dir;
}

inline QString getAppPackageDataDirPath () {
  QDir dir = ::getAppPackageDir();
  dir.cd("share");
  return dir.absolutePath();
}

inline QString getAppPackageMsPluginsDirPath () {
  QDir dir = ::getAppPackageDir();
  dir.cd(MSPLUGINS_DIR);
  return dir.absolutePath();
}

inline QString getAppAssistantConfigDirPath () {
  return ::getAppPackageDataDirPath() + PATH_ASSISTANT_CONFIG;
}

inline QString getAppConfigFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + PATH_CONFIG;
}

inline QString getAppCallHistoryFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_CALL_HISTORY_LIST;
}

inline QString getAppFactoryConfigFilePath () {
  return ::getAppPackageDataDirPath() + PATH_FACTORY_CONFIG;
}

inline QString getAppPluginsDirPath () {
  return ::getAppPackageDataDirPath() + PATH_PLUGINS;
}

inline QString getAppRootCaFilePath () {
  return ::getAppPackageDataDirPath() + PATH_ROOT_CA;
}

inline QString getAppFriendsFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_FRIENDS_LIST;
}

inline QString getAppMessageHistoryFilePath () {
  return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_MESSAGE_HISTORY_LIST;
}

// -----------------------------------------------------------------------------

bool Paths::filePathExists (const string &path) {
  return ::filePathExists(Utils::coreStringToAppString(path));
}

// -----------------------------------------------------------------------------

string Paths::getAssistantConfigDirPath () {
  return ::getReadableDirPath(::getAppAssistantConfigDirPath());
}

string Paths::getAvatarsDirPath () {
  return ::getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_AVATARS);
}

string Paths::getCallHistoryFilePath () {
  return ::getWritableFilePath(::getAppCallHistoryFilePath());
}

string Paths::getCapturesDirPath () {
  return ::getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + PATH_CAPTURES);
}

string Paths::getConfigFilePath (const QString &configPath, bool writable) {
  const QString path = configPath.isEmpty()
    ? ::getAppConfigFilePath()
    : QFileInfo(configPath).absoluteFilePath();

  return writable ? ::getWritableFilePath(path) : ::getReadableFilePath(path);
}

string Paths::getFactoryConfigFilePath () {
  return ::getReadableFilePath(::getAppFactoryConfigFilePath());
}

string Paths::getFriendsListFilePath () {
  return ::getWritableFilePath(::getAppFriendsFilePath());
}

string Paths::getDownloadDirPath () {
  return ::getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation));
}

string Paths::getLogsDirPath () {
  return ::getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_LOGS);
}

string Paths::getMessageHistoryFilePath () {
  return ::getWritableFilePath(::getAppMessageHistoryFilePath());
}

string Paths::getPackageDataDirPath () {
  return ::getReadableDirPath(::getAppPackageDataDirPath());
}

string Paths::getPackageMsPluginsDirPath () {
  return ::getReadableDirPath(::getAppPackageMsPluginsDirPath());
}

string Paths::getPluginsDirPath () {
  return ::getReadableDirPath(::getAppPluginsDirPath());
}

string Paths::getRootCaFilePath () {
  return ::getReadableFilePath(::getAppRootCaFilePath());
}

string Paths::getThumbnailsDirPath () {
  return ::getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_THUMBNAILS);
}

string Paths::getUserCertificatesDirPath () {
  return ::getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_USER_CERTIFICATES);
}

string Paths::getZrtpSecretsFilePath () {
  return ::getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + PATH_ZRTP_SECRETS);
}

// -----------------------------------------------------------------------------

static void migrateFile (const QString &oldPath, const QString &newPath) {
  QFileInfo info(newPath);
  ::ensureDirPathExists(info.path());

  if (QFile::copy(oldPath, newPath)) {
    QFile::remove(oldPath);
    qInfo() << "Migrated" << oldPath << "to" << newPath;
  } else {
    qWarning() << "Failed migration of" << oldPath << "to" << newPath;
  }
}

static void migrateConfigurationFile (const QString &oldPath, const QString &newPath) {
  QFileInfo info(newPath);
  ::ensureDirPathExists(info.path());

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

static void setRlsUri (const QString &configPath) {
  shared_ptr<linphone::Config> config = linphone::Config::newWithFactory(::Utils::appStringToCoreString(configPath), "");
  if (config->getString("sip", "rls_uri", "").empty()) {
    config->setString("sip", "rls_uri", "sips:rls@sip.linphone.org");
    config->sync();
  }
}

void Paths::migrate () {
  QString newPath = ::getAppConfigFilePath();
  QString oldBaseDir = QSysInfo::productType() == "windows"
    ? QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
    : QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
  QString oldPath = oldBaseDir + "/.linphonerc";

  if (!::filePathExists(newPath) && ::filePathExists(oldPath)) {
    ::migrateConfigurationFile(oldPath, newPath);
    /* Define RLS uri so that presence switches from peer-to-peer mode to list mode. */
    ::setRlsUri(newPath);
  }

  newPath = ::getAppCallHistoryFilePath();
  oldPath = oldBaseDir + "/.linphone-call-history.db";

  if (!::filePathExists(newPath) && ::filePathExists(oldPath))
    ::migrateFile(oldPath, newPath);

  newPath = ::getAppFriendsFilePath();
  oldPath = oldBaseDir + "/.linphone-friends.db";

  if (!::filePathExists(newPath) && ::filePathExists(oldPath))
    ::migrateFile(oldPath, newPath);

  newPath = ::getAppMessageHistoryFilePath();
  oldPath = oldBaseDir + "/.linphone-history.db";

  if (!::filePathExists(newPath) && ::filePathExists(oldPath))
    ::migrateFile(oldPath, newPath);
}
