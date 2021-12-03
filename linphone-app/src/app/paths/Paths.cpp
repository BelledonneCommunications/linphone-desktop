/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include <linphone++/linphone.hh>
#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>
#include <QtDebug>

#include "config.h"

#include "utils/Utils.hpp"
#include "utils/Constants.hpp"

#include "Paths.hpp"

// =============================================================================

using namespace std;

static inline bool dirPathExists (const QString &path) {
	QDir dir(path);
	return dir.exists();
}

static inline bool filePathExists (const QString &path, const bool& isWritable) {
	QFileInfo info(path);
	if (!dirPathExists(info.path()))
		return false;
	if( isWritable && !info.isWritable())
		return false;
	QFile file(path);
	return file.exists();
}

static inline void ensureDirPathExists (const QString &path) {
	QDir dir(path);
	if (!dir.exists() && !dir.mkpath(path))
		qFatal("Unable to access at directory: `%s`", Utils::appStringToCoreString(path).c_str());
}

static inline void ensureFilePathExists (const QString &path) {
	QFileInfo info(path);
	ensureDirPathExists(info.path());
	
	QFile file(path);
	if (!file.exists() && !file.open(QIODevice::ReadWrite))
		qFatal("Unable to access at path: `%s`", Utils::appStringToCoreString(path).c_str());
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

static inline QDir getAppPackageDir () {
	QDir dir(QCoreApplication::applicationDirPath());
	if (dir.dirName() == QLatin1String("MacOS")) {
		dir.cdUp();
	} else if( !dir.exists("lib") && !dir.exists("lib64")){// Check if these folders are in the current path
		dir.cdUp();
		if(!dir.exists("lib") && !dir.exists("lib64") && !dir.exists("plugins"))
			qWarning() <<"The application's location is not correct: You have to put your 'bin/' folder next to 'lib/' or 'plugins/' folder.";
	}
	return dir;
}

static inline QString getAppPackageDataDirPath() {
	QDir dir = getAppPackageDir();
#ifdef __APPLE__
	if (!dir.cd("Resources"))
	{
		dir.mkdir("Resources");
		dir.cd("Resources");
	}
#endif
	if (!dir.cd("share"))
	{
		dir.mkdir("share");
		dir.cd("share");
	}
	return dir.absolutePath();
}

static inline QString getAppPackageMsPluginsDirPath () {
	QDir dir = getAppPackageDir();
	dir.cd(MSPLUGINS_DIR);
	return dir.absolutePath();
}

static inline QString getAppPackagePluginsDirPath () {
	return getAppPackageDir().absolutePath() + Constants::PathPlugins;
}

static inline QString getAppAssistantConfigDirPath () {
	return getAppPackageDataDirPath() + Constants::PathAssistantConfig;
}

static inline QString getAppConfigFilePath () {
	return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + Constants::PathConfig;
}

static inline QString getAppCallHistoryFilePath () {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathCallHistoryList;
}

static inline QString getAppFactoryConfigFilePath () {
	return getAppPackageDataDirPath() + Constants::PathFactoryConfig;
}

static inline QString getAppRootCaFilePath () {
	return getAppPackageDataDirPath() + Constants::PathRootCa;
}

static inline QString getAppFriendsFilePath () {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathFriendsList;
}

static inline QString getAppMessageHistoryFilePath () {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathMessageHistoryList;
}

static inline QString getAppPluginsDirPath () {
	return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)+ Constants::PathPlugins;
}
// -----------------------------------------------------------------------------

bool Paths::filePathExists (const string &path, const bool isWritable) {
	return filePathExists(Utils::coreStringToAppString(path), isWritable);
}


// -----------------------------------------------------------------------------

string Paths::getAppLocalDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +"/");
}

string Paths::getAssistantConfigDirPath () {
	return getReadableDirPath(getAppAssistantConfigDirPath());
}

string Paths::getAvatarsDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathAvatars);
}

string Paths::getCallHistoryFilePath () {
	return getWritableFilePath(getAppCallHistoryFilePath());
}

string Paths::getCapturesDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + Constants::PathCaptures);
}

string Paths::getCodecsDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathCodecs);
}

string Paths::getConfigDirPath (bool writable) {
	return writable ? getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)+QDir::separator()) : getReadableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)+QDir::separator());
}

string Paths::getConfigFilePath (const QString &configPath, bool writable) {
	QString path;
	if( !configPath.isEmpty()){
		QFileInfo file(configPath);
		if( !writable && (!file.exists() || !file.isFile())){// This file cannot be found. Check if it exists in standard folder
			QString defaultConfigPath = Utils::coreStringToAppString(getConfigDirPath(false));
			file = QFileInfo(defaultConfigPath+QDir::separator()+configPath);
			if( !file.exists() || !file.isFile())
				path = "";
			else
				path = file.absoluteFilePath();
		}else
			path = file.absoluteFilePath();
	}else
		path = getAppConfigFilePath();
	return writable ? getWritableFilePath(path) : getReadableFilePath(path);
}

std::string Paths::getDatabaseFilePath (){
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)) + Constants::PathDatabase;
}

string Paths::getFactoryConfigFilePath () {
	return getReadableFilePath(getAppFactoryConfigFilePath());
}

string Paths::getFriendsListFilePath () {
	return getWritableFilePath(getAppFriendsFilePath());
}

string Paths::getDownloadDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + QDir::separator());
}

std::string Paths::getLimeDatabasePath (){
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)) + Constants::PathLimeDatabase;
}

string Paths::getLogsDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathLogs);
}

string Paths::getMessageHistoryFilePath () {
	return getReadableFilePath(getAppMessageHistoryFilePath());// No need to ensure that the file exists as this DB is deprecated
}

string Paths::getPackageDataDirPath () {
	return getReadableDirPath(getAppPackageDataDirPath() + Constants::PathData);
}

string Paths::getPackageMsPluginsDirPath () {
	return getReadableDirPath(getAppPackageMsPluginsDirPath());
}

string Paths::getPackagePluginsAppDirPath () {
	return getReadableDirPath(getAppPackagePluginsDirPath() + Constants::PathPluginsApp);
}

std::string Paths::getPackageSoundsResourcesDirPath (){
	return getReadableDirPath(getAppPackageDataDirPath() + Constants::PathSounds);
}

std::string Paths::getPackageTopDirPath (){
	return getReadableDirPath(getAppPackageDataDirPath());
}

string Paths::getPluginsAppDirPath () {
	return getWritableDirPath(getAppPluginsDirPath() + Constants::PathPluginsApp);
}

QStringList Paths::getPluginsAppFolders() {
	QStringList pluginPaths;
	pluginPaths << Utils::coreStringToAppString(Paths::getPluginsAppDirPath());
	pluginPaths << Utils::coreStringToAppString(Paths::getPackagePluginsAppDirPath());
	return pluginPaths;
}

string Paths::getRootCaFilePath () {
	return getReadableFilePath(getAppRootCaFilePath());
}

string Paths::getThumbnailsDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathThumbnails);
}
string Paths::getToolsDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathTools);
}
string Paths::getUserCertificatesDirPath () {
	return getWritableDirPath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathUserCertificates);
}

string Paths::getZrtpSecretsFilePath () {
	return getWritableFilePath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + Constants::PathZrtpSecrets);
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
void migrateFlatpakVersionFiles(){
#ifdef Q_OS_LINUX
	if(!filePathExists(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +Constants::PathDatabase, true)){
		// Copy all files if linphone.db doesn't exist
		QString flatpakPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation)+"/.var/app/" APPLICATION_ID "/data/" EXECUTABLE_NAME;
		if( QDir().exists(flatpakPath)){
			qInfo() << "Migrating data from Flatpak.";
			Utils::copyDir(flatpakPath, QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation));
		}
	}
#endif
}
void migrateGTKVersionFiles(){
	if( EXECUTABLE_NAME == "linphone"){
		QString newPath = getAppConfigFilePath();
		QString oldBaseDir = QSysInfo::productType() == QLatin1String("windows")
				? QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
				: QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
		QString oldPath = oldBaseDir + "/.linphonerc";
		
		if (!filePathExists(newPath, false) && filePathExists(oldPath, false))
			migrateConfigurationFile(oldPath, newPath);
		
		newPath = getAppCallHistoryFilePath();
		oldPath = oldBaseDir + "/.linphone-call-history.db";
		
		if (!filePathExists(newPath, false) && filePathExists(oldPath, false))
			migrateFile(oldPath, newPath);
		
		newPath = getAppFriendsFilePath();
		oldPath = oldBaseDir + "/.linphone-friends.db";
		
		if (!filePathExists(newPath, false) && filePathExists(oldPath, false))
			migrateFile(oldPath, newPath);
		
		newPath = getAppMessageHistoryFilePath();
		oldPath = oldBaseDir + "/.linphone-history.db";
		
		if (!filePathExists(newPath, false) && filePathExists(oldPath, false))
			migrateFile(oldPath, newPath);
	}
}
void Paths::migrate () {
	migrateFlatpakVersionFiles(); // First, check Flatpak version as it is the earlier version
	migrateGTKVersionFiles();// Then check old version for migration
}
