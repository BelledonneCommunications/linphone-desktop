/*
 * Paths.hpp
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
  std::string getConfigFilePath (const QString &configPath = QString(), bool writable = true);
  std::string getFactoryConfigFilePath ();
  std::string getFriendsListFilePath ();
  std::string getDownloadDirPath ();
  std::string getLogsDirPath ();
  std::string getMessageHistoryFilePath ();
  std::string getPackageDataDirPath ();
  std::string getPackageMsPluginsDirPath ();
  std::string getPluginsDirPath ();
  std::string getRootCaFilePath ();
  std::string getThumbnailsDirPath ();
  std::string getUserCertificatesDirPath ();
  std::string getZrtpDataFilePath ();
  std::string getZrtpSecretsFilePath ();

  void migrate ();
}

#endif // PATHS_H_
