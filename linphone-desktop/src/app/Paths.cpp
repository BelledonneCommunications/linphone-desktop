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

#include <QDir>
#include <QFile>
#include <QStandardPaths>

#include "../utils.hpp"

#include "Paths.hpp"

// =============================================================================

#ifdef _WIN32

#define MAIN_PATH \
  (QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/")
#define PATH_CONFIG "linphonerc"

#define LINPHONE_FOLDER "linphone/"

#else

#define MAIN_PATH \
  (QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/")
#define PATH_CONFIG ".linphonerc"

#define LINPHONE_FOLDER ".linphone/"

#endif // ifdef _WIN32

#define PATH_AVATARS (LINPHONE_FOLDER "avatars/")
#define PATH_CAPTURES (LINPHONE_FOLDER "captures/")
#define PATH_LOGS (LINPHONE_FOLDER "logs/")
#define PATH_THUMBNAILS (LINPHONE_FOLDER "thumbnails/")

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
  return getDirectoryPath(MAIN_PATH + PATH_AVATARS);
}

string Paths::getCallHistoryFilepath () {
  return getFilePath(MAIN_PATH + PATH_CALL_HISTORY_LIST);
}

string Paths::getConfigFilepath (const QString &configPath) {
  if (!configPath.isEmpty()) {
    return getFilePath(QFileInfo(configPath).absoluteFilePath());
  }
  return getFilePath(MAIN_PATH + PATH_CONFIG);
}

string Paths::getFriendsListFilepath () {
  return getFilePath(MAIN_PATH + PATH_FRIENDS_LIST);
}

string Paths::getLogsDirpath () {
  return getDirectoryPath(MAIN_PATH + PATH_LOGS);
}

string Paths::getMessageHistoryFilepath () {
  return getFilePath(MAIN_PATH + PATH_MESSAGE_HISTORY_LIST);
}

string Paths::getThumbnailsDirPath () {
  return getDirectoryPath(MAIN_PATH + PATH_THUMBNAILS);
}

string Paths::getCapturesDirPath () {
  return getDirectoryPath(MAIN_PATH + PATH_CAPTURES);
}
