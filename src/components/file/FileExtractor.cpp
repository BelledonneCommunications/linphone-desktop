/*
 * FileExtractor.cpp
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
 *  Created on: March 8, 2018
 *      Author: Ronan Abhamon
 */

#include <mz_strm_bzip.h>
#include <mz.h>
#include <QDebug>
#include <QDir>

#include "FileExtractor.hpp"

// =============================================================================

using namespace std;

static const char *minizipErrorToString (int error) {
  switch (error) {
    case MZ_OK:
      return "ok";
    case MZ_STREAM_ERROR:
      return "stream error";
    case MZ_DATA_ERROR:
      return "data error";
    case MZ_MEM_ERROR:
      return "memory error";
    case MZ_END_OF_LIST:
      return "end of list";
    case MZ_END_OF_STREAM:
      return "end of stream";
    case MZ_PARAM_ERROR:
      return "param error";
    case MZ_FORMAT_ERROR:
      return "format error";
    case MZ_INTERNAL_ERROR:
      return "internal error";
    case MZ_CRC_ERROR:
      return "crc error";
    case MZ_CRYPT_ERROR:
      return "crypt error";
    case MZ_EXIST_ERROR:
      return "exist error";
    case MZ_PASSWORD_ERROR:
      return "password error";
  }

  Q_ASSERT(false);
  return "";
}

static int openMinizipStream (void **stream, const char *filePath) {
  *stream = nullptr;
  if (!mz_stream_bzip_create(stream))
    return MZ_MEM_ERROR;
  return mz_stream_bzip_open(stream, filePath, MZ_OPEN_MODE_READ);
}

// -----------------------------------------------------------------------------

void FileExtractor::extract () {
  if (mExtracting) {
    qWarning() << "Unable to extract file. Already extracting!";
    return;
  }
  setExtracting(true);

  QFileInfo fileInfo(mFile);

  setReadBytes(0);
  setTotalBytes(fileInfo.size());

  // 1. Open archive stream.
  // TODO: Test extension.
  int error = openMinizipStream(&mStream, mFile.toLatin1().constData());
  if (error != MZ_OK) {
    emitExtractFailed(error);
    return;
  }

  // 2. Open output file.
  // TODO: Deal with existing files.
  Q_ASSERT(!mDestinationFile.isOpen());
  mDestinationFile.setFileName(
    QDir::cleanPath(mExtractFolder) + QDir::separator() + fileInfo.completeBaseName()
  );
  if (!mDestinationFile.open(QIODevice::WriteOnly)) {
    emitOutputError();
    return;
  }

  // 3. Connect!
  mTimer = new QTimer(this);
  QObject::connect(mTimer, &QTimer::timeout, this, &FileExtractor::handleExtraction);
  mTimer->start();
}

QString FileExtractor::getFile () const {
  return mFile;
}

void FileExtractor::setFile (const QString &file) {
  if (mExtracting) {
    qWarning() << QStringLiteral("Unable to set file, a file is extracting.");
    return;
  }

  if (mFile != file) {
    mFile = file;
    emit fileChanged(mFile);
  }
}

QString FileExtractor::getExtractFolder () const {
  return mExtractFolder;
}

void FileExtractor::setExtractFolder (const QString &extractFolder) {
  if (mExtracting) {
    qWarning() << QStringLiteral("Unable to set extract folder, a file is extracting.");
    return;
  }

  if (mExtractFolder != extractFolder) {
    mExtractFolder = extractFolder;
    emit extractFolderChanged(mExtractFolder);
  }
}

qint64 FileExtractor::getReadBytes () const {
  return mReadBytes;
}

void FileExtractor::setReadBytes (qint64 readBytes) {
  if (mReadBytes != readBytes) {
    mReadBytes = readBytes;
    emit readBytesChanged(readBytes);
  }
}

qint64 FileExtractor::getTotalBytes () const {
  return mTotalBytes;
}

void FileExtractor::setTotalBytes (qint64 totalBytes) {
  if (mTotalBytes != totalBytes) {
    mTotalBytes = totalBytes;
    emit totalBytesChanged(totalBytes);
  }
}

bool FileExtractor::getExtracting () const {
  return mExtracting;
}

void FileExtractor::setExtracting (bool extracting) {
  if (mExtracting != extracting) {
    mExtracting = extracting;
    emit extractingChanged(extracting);
  }
}

void FileExtractor::clean () {
  mz_stream_bzip_delete(&mStream);
  mDestinationFile.close();
  mTimer->stop();
  mTimer->deleteLater();
  setExtracting(false);
}

void FileExtractor::emitExtractFailed (int error) {
  qWarning() << QStringLiteral("Unable to open extract file: `%1` (%2).")
    .arg(mFile).arg(minizipErrorToString(error));
  mDestinationFile.remove();
  clean();
  emit extractFailed();
}

void FileExtractor::emitExtractFinished () {
  clean();
  emit extractFinished();
}

void FileExtractor::emitOutputError () {
  qWarning() << QStringLiteral("Could not write into `%1` (%2).")
    .arg(mDestinationFile.fileName()).arg(mDestinationFile.errorString());
  mDestinationFile.remove();
  clean();
  emit extractFailed();
}

void FileExtractor::handleExtraction () {
  char buffer[4096];
  int32_t readBytes = mz_stream_bzip_read(mStream, buffer, sizeof buffer);
  switch (readBytes) {
    case MZ_OK:
      break;
    case MZ_END_OF_STREAM:
      emitExtractFinished();
      return;
    default:
      emitExtractFailed(readBytes);
      return;
  }

  setReadBytes(readBytes);
  if (mDestinationFile.write(buffer, sizeof buffer) == -1)
    emitOutputError();
}
