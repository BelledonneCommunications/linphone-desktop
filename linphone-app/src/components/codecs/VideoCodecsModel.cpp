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

#include <QDebug>
#include <QDirIterator>
#include <QLibrary>

#include "app/paths/Paths.hpp"
#include "components/core/CoreManager.hpp"
#include "components/file/FileDownloader.hpp"
#include "components/file/FileExtractor.hpp"
#include "utils/Utils.hpp"

#include "VideoCodecsModel.hpp"
#include <linphone/linphonecore.h>

// =============================================================================

using namespace std;

namespace {
  #if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
    constexpr char H264Description[] = "Provided by CISCO SYSTEM,INC";
  #endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)

  #ifdef Q_OS_LINUX
    constexpr char LibraryExtension[] = "so";
    constexpr char H264InstallName[] = "libopenh264.so";
    #ifdef Q_PROCESSOR_X86_64
      constexpr char PluginUrlH264[] = "http://ciscobinary.openh264.org/libopenh264-2.1.0-linux64.5.so.bz2";
    #else
      constexpr char PluginUrlH264[] = "http://ciscobinary.openh264.org/libopenh264-2.1-0-linux32.5.so.bz2";
    #endif // ifdef Q_PROCESSOR_X86_64
  #elif defined(Q_OS_WIN)
    constexpr char LibraryExtension[] = "dll";
    constexpr char H264InstallName[] = "openh264.dll";
    #ifdef Q_OS_WIN64
      constexpr char PluginUrlH264[] = "http://ciscobinary.openh264.org/openh264-2.1.0-win64.dll.bz2";
    #else
      constexpr char PluginUrlH264[] = "http://ciscobinary.openh264.org/openh264-2.1.0-win32.dll.bz2";
    #endif // ifdef Q_OS_WIN64
  #endif // ifdef Q_OS_LINUX
}

VideoCodecsModel::VideoCodecsModel (QObject *parent) : AbstractCodecsModel(parent) {
  load();
}

#if defined(Q_OS_LINUX) || defined(Q_OS_WIN)

static bool downloadUpdatableCodec (
  QObject *parent,
  const QString &codecsFolder,
  const QString &mime,
  const QString &downloadUrl,
  const QString &installName
) {
  QString versionFilePath = codecsFolder + mime + ".txt";
  QFile versionFile(versionFilePath);

  if (!versionFile.exists() && !QFileInfo::exists(codecsFolder + installName))
    return false; // Must be downloaded one time before.

  if (!versionFile.open(QIODevice::ReadOnly))
    qWarning() << QStringLiteral("Unable to read codec version from: `%1`.").arg(versionFilePath);
  else if (!QString::compare(QTextStream(&versionFile).readAll(), downloadUrl, Qt::CaseInsensitive))
    return false;

  qInfo() << QStringLiteral("Updating `%1` codec...").arg(mime);

  FileDownloader *fileDownloader = new FileDownloader(parent);
  fileDownloader->setUrl(QUrl(downloadUrl));
  fileDownloader->setDownloadFolder(codecsFolder);

  FileExtractor *fileExtractor = new FileExtractor(fileDownloader);
  fileExtractor->setExtractFolder(codecsFolder);
  fileExtractor->setExtractName(installName + ".in");

  QObject::connect(fileDownloader, &FileDownloader::downloadFinished, [fileExtractor](const QString &filePath) {
    fileExtractor->setFile(filePath);
    fileExtractor->extract();
  });

  QObject::connect(fileDownloader, &FileDownloader::downloadFailed, [fileDownloader]() {
    fileDownloader->deleteLater();
  });

  QObject::connect(fileExtractor, &FileExtractor::extractFinished, [fileDownloader, fileExtractor, versionFilePath, downloadUrl]() {
    QFile versionFile(versionFilePath);
    if (!versionFile.open(QIODevice::WriteOnly)) {
      qWarning() << QStringLiteral("Unable to write codec version in: `%1`.").arg(versionFilePath);
      return;
    }
    if (versionFile.write(Utils::appStringToCoreString(downloadUrl).c_str(), downloadUrl.length()) == -1) {
      fileExtractor->remove();
      versionFile.close();
      versionFile.remove();
    }

    fileDownloader->remove();
    fileDownloader->deleteLater();
  });

  QObject::connect(fileExtractor, &FileExtractor::extractFailed, [fileDownloader]() {
    fileDownloader->remove();
    fileDownloader->deleteLater();
  });

  fileDownloader->download();

  return true;
}

#endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)

void VideoCodecsModel::updateCodecs () {
  #if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
    static const QString codecSuffix = QStringLiteral(".%1").arg(LibraryExtension);

    QDirIterator it(getCodecsFolder());
    while (it.hasNext()) {
      QFileInfo info(it.next());
      if (info.suffix() == QLatin1String("in")) {
        QString codecName = info.completeBaseName();
        if (codecName.endsWith(codecSuffix)) {
          QString codecPath = info.dir().path() + QDir::separator() + codecName;
          QFile::remove(codecPath);
          QFile::rename(info.filePath(), codecPath);
        }
      }
    }
  #endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
}

void VideoCodecsModel::downloadUpdatableCodecs (QObject *parent) {
  #if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
    downloadUpdatableCodec(parent, getCodecsFolder(), "H264", PluginUrlH264, H264InstallName);
  #else
    Q_UNUSED(parent);
  #endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
}

void VideoCodecsModel::updateCodecs (list<shared_ptr<linphone::PayloadType>> &codecs) {
  CoreManager::getInstance()->getCore()->setVideoPayloadTypes(codecs);
}

void VideoCodecsModel::load () {
  mCodecs.clear();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  // Load downloaded codecs like OpenH264.
  #if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
    QDirIterator it(getCodecsFolder());
    while (it.hasNext()) {
      QFileInfo info(it.next());
      const QString filename(info.fileName());
      if ( QLibrary::isLibrary(filename) ) {
        qInfo() << QStringLiteral("Loading `%1` symbols...").arg(filename);
        if (!QLibrary(info.filePath()).load()) //lib.load())
          qWarning() << QStringLiteral("Failed to load `%1` symbols.").arg(filename);
      }
    }
    core->reloadMsPlugins("");
  #endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)

  // Add codecs.
  auto codecs = core->getVideoPayloadTypes();
  for (auto &codec : codecs)
    addCodec(codec);

  // Add downloadable codecs.
  // TODO: Add an API to check if the ms h264 plugin is available.
  #if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
    if (find_if(codecs.begin(), codecs.end(), [](const shared_ptr<linphone::PayloadType> &codec) {
      return codec->getMimeType() == "H264";
    }) == codecs.end())
      addDownloadableCodec("H264", H264Description, PluginUrlH264, H264InstallName);
  #endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
}

void VideoCodecsModel::reload () {
  beginResetModel();
  load();
  endResetModel();
}
