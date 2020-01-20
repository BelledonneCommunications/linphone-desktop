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

#include <mz_os.h>
#include <mz_strm_bzip.h>
#include <mz_strm.h>
#include <mz.h>
#include <QDebug>
#include <QDir>
#include <QTimer>

#include "FileExtractor.hpp"

// =============================================================================

using namespace std;

class FileExtractor::ExtractStream {
public:
  ExtractStream () : mFileStream(nullptr), mBzipStream(nullptr) {}

  ~ExtractStream () {
    if (mBzipStream) {
      mz_stream_bzip_close(mBzipStream);
      mz_stream_bzip_delete(&mBzipStream);
    }

    if (mFileStream) {
      mz_stream_os_close(mFileStream);
      mz_stream_os_delete(&mFileStream);
    }
  }

  void *getInternalStream () const {
    return mBzipStream;
  }

  int load (const char *filePath) {
    Q_ASSERT(!mFileStream);
    Q_ASSERT(!mBzipStream);

    // 1. Open file stream.
    if (!mz_stream_os_create(&mFileStream))
      return MZ_MEM_ERROR;
    Q_CHECK_PTR(mFileStream);

    int error;
    if ((error = mz_stream_os_open(mFileStream, filePath, MZ_OPEN_MODE_READ)) != MZ_OK)
      return error;

    // 2. Open bzip stream.
    if (!mz_stream_bzip_create(&mBzipStream))
      return MZ_MEM_ERROR;
    Q_CHECK_PTR(mBzipStream);
    if ((error = mz_stream_bzip_open(mBzipStream, NULL, MZ_OPEN_MODE_READ)) != MZ_OK)
      return error;

    // 3. Link file stream to bzip stream.
    return mz_stream_set_base(mBzipStream, mFileStream);
  }

private:
  void *mFileStream;
  void *mBzipStream;
};

// -----------------------------------------------------------------------------

FileExtractor::FileExtractor (QObject *parent) : QObject(parent) {}

FileExtractor::~FileExtractor () {}

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
  Q_ASSERT(!mStream);
  mStream.reset(new ExtractStream());
  int error = mStream->load(mFile.toLatin1().constData());
  if (error != MZ_OK) {
    emitExtractFailed(error);
    return;
  }

  // 2. Open output file.
  // TODO: Deal with existing files.
  Q_ASSERT(!mDestinationFile.isOpen());
  mDestinationFile.setFileName(
    QDir::cleanPath(mExtractFolder) + QDir::separator() + (
      mExtractName.isEmpty() ? fileInfo.completeBaseName() : mExtractName
    )
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

bool FileExtractor::remove () {
  return mDestinationFile.exists() && !mDestinationFile.isOpen() && mDestinationFile.remove();
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

QString FileExtractor::getExtractName () const {
  return mExtractName;
}

void FileExtractor::setExtractName (const QString &extractName) {
  if (mExtracting) {
    qWarning() << QStringLiteral("Unable to set extract name, a file is extracting.");
    return;
  }

  if (mExtractName != extractName) {
    mExtractName = extractName;
    emit extractNameChanged(mExtractName);
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
  mStream.reset(nullptr);
  mDestinationFile.close();

  if (mTimer) {
    mTimer->stop();
    mTimer->deleteLater();
    mTimer = nullptr;
  }

  setExtracting(false);
}

void FileExtractor::emitExtractFailed (int error) {
  qWarning() << QStringLiteral("Unable to extract file: `%1` (code: %2).")
    .arg(mFile).arg(error);
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

  void *stream = mStream.data()->getInternalStream();

  int32_t readBytes = mz_stream_bzip_read(stream, buffer, sizeof buffer);
  if (readBytes == 0)
    emitExtractFinished();
  else if (readBytes < 0)
    emitExtractFailed(readBytes);
  else {
    int64_t inputReadBytes;
    mz_stream_bzip_get_prop_int64(stream, MZ_STREAM_PROP_TOTAL_IN, &inputReadBytes);
    setReadBytes(inputReadBytes);
    if (mDestinationFile.write(buffer, readBytes) == -1)
      emitOutputError();
  }
}
