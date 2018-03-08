/*
 * VideoCodecsModel.cpp
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
 *  Created on: April 3, 2017
 *      Author: Ronan Abhamon
 */

#include <QDirIterator>
#include <QLibrary>

#include "../../app/paths/Paths.hpp"
#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "VideoCodecsModel.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char cH264Description[] = "Provided by CISCO SYSTEM,INC";

  #ifdef Q_OS_LINUX
    constexpr char cLibraryExtension[] = "so";
    #ifdef Q_PROCESSOR_X86_64
      constexpr char cPluginUrlH264[] = "http://ciscobinary.openh264.org/libopenh264-1.7.0-linux64.4.so.bz2";
    #else
      constexpr char cPluginUrlH264[] = "http://ciscobinary.openh264.org/libopenh264-1.7.0-linux32.4.so.bz2";
    #endif // ifdef Q_PROCESSOR_X86_64
  #elif defined(Q_OS_WIN)
    constexpr char cLibraryExtension[] = "dll";
    #ifdef Q_OS_WIN64
      constexpr char cPluginUrlH264[] = "http://ciscobinary.openh264.org/openh264-1.7.0-win64.dll.bz2";
    #elif defined(Q_OS_WIN32)
      constexpr char cPluginUrlH264[] = "http://ciscobinary.openh264.org/openh264-1.7.0-win32.dll.bz2";
    #endif // ifdef Q_OS_WIN64
  #endif // ifdef Q_OS_LINUX
}

VideoCodecsModel::VideoCodecsModel (QObject *parent) : AbstractCodecsModel(parent) {
  load();
}

void VideoCodecsModel::updateCodecs (list<shared_ptr<linphone::PayloadType>> &codecs) {
  CoreManager::getInstance()->getCore()->setVideoPayloadTypes(codecs);
}

void VideoCodecsModel::load () {
  mCodecs.clear();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  // Load downloaded codecs like OpenH264.
  #if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
    QDirIterator it(Utils::coreStringToAppString(Paths::getCodecsDirPath()));
    while (it.hasNext()) {
      QFileInfo info(it.next());
      if (info.suffix() == cLibraryExtension)
        QLibrary(info.filePath()).load();
    }
    core->reloadMsPlugins("");
  #endif

  // Add codecs.
  auto codecs = core->getVideoPayloadTypes();
  for (auto &codec : codecs)
    addCodec(codec);

  // Add downloadable codecs.
  #if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
    if (find_if(codecs.begin(), codecs.end(), [](const shared_ptr<linphone::PayloadType> &codec) {
      return codec->getMimeType() == "H264";
    }) == codecs.end())
      addDownloadableCodec("H264", cPluginUrlH264, cH264Description);
  #endif
}

void VideoCodecsModel::reload () {
  beginResetModel();
  load();
  endResetModel();
}
