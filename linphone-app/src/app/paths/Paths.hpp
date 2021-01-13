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

#ifndef PATHS_H_
#define PATHS_H_

#include <QString>

// =============================================================================

namespace Paths {
  bool filePathExists (const std::string &path);


  std::string getAssistantConfigDirPath ();
  std::string getAvatarsDirPath ();
  std::string getCallHistoryFilePath ();
  std::string getCapturesDirPath ();
  std::string getCodecsDirPath ();
  std::string getConfigDirPath (bool writable = true);
  std::string getConfigFilePath (const QString &configPath = QString(), bool writable = true);
  std::string getDownloadDirPath ();
  std::string getFactoryConfigFilePath ();
  std::string getFriendsListFilePath ();
  std::string getLogsDirPath ();
  std::string getMessageHistoryFilePath ();
  std::string getPackageDataDirPath ();
  std::string getPackageMsPluginsDirPath ();
  std::string getPackagePluginsAppDirPath ();
  std::string getPluginsAppDirPath ();
  QStringList getPluginsAppFolders();
  std::string getRootCaFilePath ();
  std::string getThumbnailsDirPath ();
  std::string getToolsDirPath ();
  std::string getUserCertificatesDirPath ();
  std::string getZrtpDataFilePath ();
  std::string getZrtpSecretsFilePath ();

  void migrate ();
}

#endif // PATHS_H_
