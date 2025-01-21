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

#ifndef PATHS_H_
#define PATHS_H_

#include <QString>

// =============================================================================

namespace Paths {
bool filePathExists(const QString &path, const bool isWritable = false);

QString getAppLocalDirPath();
QString getAssistantConfigDirPath();
QString getAvatarsDirPath();
QString getVCardsPath();
QString getCallHistoryFilePath();
QString getCapturesDirPath();
QString getCodecsDirPath();
QString getConfigDirPath(bool writable = true);
QString getConfigFilePath(const QString &configPath = QString(), bool writable = true);
QString getDatabaseFilePath();
QString getDownloadDirPath();
QString getFactoryConfigFilePath();
QString getFriendsListFilePath();
QString getLimeDatabasePath();
QString getLogsDirPath();
QString getMessageHistoryFilePath();
QString getPackageDataDirPath();
QString getPackageMsPluginsDirPath();
QString getPackagePluginsAppDirPath();
QString getPackageSoundsResourcesDirPath();
QString getPackageTopDirPath();
QString getPluginsAppDirPath();
QStringList getPluginsAppFolders();
QString getRootCaFilePath();
QString getToolsDirPath();
QString getUserCertificatesDirPath();
QString getZrtpDataFilePath();
QString getZrtpSecretsFilePath();

void migrate();
} // namespace Paths

#endif // PATHS_H_
