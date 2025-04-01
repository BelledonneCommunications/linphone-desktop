/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>
#include <QtDebug>

#include "config.h"

#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

#include "Paths.hpp"

// =============================================================================

static inline bool dirPathExists(const QString &path) {
	QDir dir(path);
	return dir.exists();
}
/*
static inline bool filePathExists (const QString &path, const bool& isWritable) {
    QFileInfo info(path);
    if (!dirPathExists(info.path()))
        return false;
    if( isWritable && !info.isWritable())
        return false;
    QFile file(path);
    return file.exists();
}
*/
static inline void ensureDirPathExists(const QString &path) {
	QDir dir(path);
	if (!dir.exists() && !dir.mkpath(path)) qFatal("Unable to access at directory: `%s`", path.toStdString().c_str());
}

static inline void ensureFilePathExists(const QString &path) {
	QFileInfo info(path);
	ensureDirPathExists(info.path());

	QFile file(path);
	if (!file.exists() && !file.open(QIODevice::ReadWrite))
		qFatal("Unable to access at path: `%s`", path.toStdString().c_str());
}

static inline QString getReadableDirPath(const QString &dirname) {
	return QDir::toNativeSeparators(dirname);
}

static inline QString getWritableDirPath(const QString &dirname) {
	ensureDirPathExists(dirname);
	return getReadableDirPath(dirname);
}

static inline QString getReadableFilePath(const QString &filename) {
	return QDir::toNativeSeparators(filename);
}

static inline QString getWritableFilePath(const QString &filename) {
	ensureFilePathExists(filename);
	return getReadableFilePath(filename);
}

// -----------------------------------------------------------------------------
// On Windows or Linux, the folders of the application are :
//  bin/linphone
//  lib/
//  lib64/
//  plugins/
//  share/

// But in some cases, it can be :
//  /linphone
//  lib/
//  lib64/
//  share/

// On Mac, we have :
//  Contents/
//    Frameworks/
//    MacOs/linphone
//    Plugins/
//    Resources/
//      share/

static inline QDir getAppPackageDir() {
	QDir dir(QCoreApplication::applicationDirPath());
	if (dir.dirName() == QLatin1String("MacOS")) {
		dir.cdUp();
	} else if (!dir.exists("lib") && !dir.exists("lib64")) { // Check if these folders are in the current path
		dir.cdUp();
		if (!dir.exists("lib") && !dir.exists("lib64") && !dir.exists("plugins"))
			qWarning() << "The application's location is not correct: You have to put your 'bin/' folder next to "
			              "'lib/' or 'plugins/' folder.";
	}
	return dir;
}

static inline QString getAppPackageDataDirPath() {
	QDir dir = getAppPackageDir();
#ifdef __APPLE__
	if (!dir.cd("Resources")) {
		dir.mkdir("Resources");
		dir.cd("Resources");
	}
#endif
	if (!dir.cd("share")) {
		dir.mkdir("share");
		dir.cd("share");
	}
	return dir.absolutePath();
}

static inline QString getAppPackageMsPluginsDirPath() {
	QDir dir = getAppPackageDir();
	dir.cd(MSPLUGINS_DIR);
	return dir.absolutePath();
}

static inline QString getAppPackagePluginsDirPath() {
	return getAppPackageDir().absolutePath() + Constants::PathPlugins;
}

static inline QString getAppAssistantConfigDirPath() {
	return getAppPackageDataDirPath() + Constants::PathAssistantConfig;
}

static inline QString getAppConfigFilePath() {
	return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + Constants::PathConfig;
}

static inline QString getAppCallHistoryFilePath() {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathCallHistoryList;
}

static inline QString getAppFactoryConfigFilePath() {
	return getAppPackageDataDirPath() + Constants::PathFactoryConfig;
}

static inline QString getAppFriendsFilePath() {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathFriendsList;
}

static inline QString getAppRootCaFilePath() {
	QString rootca = getAppPackageDataDirPath() + Constants::PathRootCa;
	if (Paths::filePathExists(rootca)) { // Packaged
		return rootca;
	} else {
		qDebug() << "Root ca path does not exist. Create it";
		QFileInfo rootcaInfo(rootca);
		if (!rootcaInfo.absoluteDir().exists()) {
			QDir dataDir(getAppPackageDataDirPath());
			if (!dataDir.mkpath(Constants::PathRootCa)) {
				lCritical() << "ERROR : COULD NOT CREATE DIRECTORY WITH PATH" << Constants::PathRootCa;
				return "";
			}
		}
		QFile rootCaFile(rootca);
		if (rootCaFile.open(QIODevice::ReadWrite))
			return rootca;
		else {
			lCritical() << "ERROR : COULD NOT CREATE ROOTCA WITH PATH" << rootca;
		}
	}
	return "";
}

static inline QString getAppMessageHistoryFilePath() {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathMessageHistoryList;
}

static inline QString getAppPluginsDirPath() {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathPlugins;
}
// -----------------------------------------------------------------------------

bool Paths::filePathExists(const QString &path, const bool isWritable) {
	QFileInfo info(path);
	if (!dirPathExists(info.path())) return false;
	if (isWritable && !info.isWritable()) return false;
	QFile file(path);
	return file.exists();
}

// -----------------------------------------------------------------------------

QString Paths::getAppLocalDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/");
}

QString Paths::getAssistantConfigDirPath() {
	return "://data/assistant/";
}

QString Paths::getAvatarsDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
	                          Constants::PathAvatars);
}

QString Paths::getVCardsPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
	                          Constants::PathVCards);
}

QString Paths::getCallHistoryFilePath() {
	return getWritableFilePath(getAppCallHistoryFilePath());
}

QString Paths::getCapturesDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +
	                          Constants::PathCaptures);
}

QString Paths::getCodecsDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
	                          Constants::PathCodecs);
}

QString Paths::getConfigDirPath(bool writable) {
	return writable ? getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) +
	                                      QDir::separator())
	                : getReadableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) +
	                                      QDir::separator());
}

QString Paths::getConfigFilePath(const QString &configPath, bool writable) {
	QString path;
	if (!configPath.isEmpty()) {
		QFileInfo file(configPath);
		if (!writable &&
		    (!file.exists() || !file.isFile())) { // This file cannot be found. Check if it exists in standard folder
			QString defaultConfigPath = getConfigDirPath(false);
			file = QFileInfo(defaultConfigPath + QDir::separator() + configPath);
			if (!file.exists() || !file.isFile()) path = "";
			else path = file.absoluteFilePath();
		} else path = file.absoluteFilePath();
	} else path = getAppConfigFilePath();
	return writable ? getWritableFilePath(path) : getReadableFilePath(path);
}

QString Paths::getDatabaseFilePath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)) +
	       Constants::PathDatabase;
}

QString Paths::getFactoryConfigFilePath() {
	return getReadableFilePath(getAppFactoryConfigFilePath());
}

QString Paths::getFriendsListFilePath() {
	return getReadableFilePath(getAppFriendsFilePath());
}

QString Paths::getDownloadDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + QDir::separator());
}

QString Paths::getLimeDatabasePath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)) +
	       Constants::PathLimeDatabase;
}

QString Paths::getLogsDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
	                          Constants::PathLogs);
}

QString Paths::getMessageHistoryFilePath() {
	return getReadableFilePath(
	    getAppMessageHistoryFilePath()); // No need to ensure that the file exists as this DB is deprecated
}

QString Paths::getPackageDataDirPath() {
	return getReadableDirPath(getAppPackageDataDirPath() + Constants::PathData);
}

QString Paths::getPackageMsPluginsDirPath() {
	return getReadableDirPath(getAppPackageMsPluginsDirPath());
}

QString Paths::getPackagePluginsAppDirPath() {
	return getReadableDirPath(getAppPackagePluginsDirPath() + Constants::PathPluginsApp);
}

QString Paths::getPackageSoundsResourcesDirPath() {
	return getReadableDirPath(getAppPackageDataDirPath() + Constants::PathSounds);
}

QString Paths::getPackageTopDirPath() {
	return getReadableDirPath(getAppPackageDataDirPath());
}

QString Paths::getPluginsAppDirPath() {
	return getWritableDirPath(getAppPluginsDirPath() + Constants::PathPluginsApp);
}

QStringList Paths::getPluginsAppFolders() {
	QStringList pluginPaths;
	pluginPaths << Paths::getPluginsAppDirPath();
	pluginPaths << Paths::getPackagePluginsAppDirPath();
	return pluginPaths;
}

QString Paths::getRootCaFilePath() {
	return getReadableFilePath(getAppRootCaFilePath());
}

QString Paths::getToolsDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
	                          Constants::PathTools);
}
QString Paths::getUserCertificatesDirPath() {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
	                          Constants::PathUserCertificates);
}

QString Paths::getZrtpSecretsFilePath() {
	return getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
	                           Constants::PathZrtpSecrets);
}

// -----------------------------------------------------------------------------

void Paths::migrate() {
}
