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

#include <mz_strm.h>
#include <QDebug>

#include "FileExtractor.hpp"

// =============================================================================

void FileExtractor::extract () {
  // TODO.
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

void FileExtractor::handleReadyData () {
  // TODO.
}

void FileExtractor::handleExtractFinished () {
  // TODO.

}

void FileExtractor::handleExtractProgress (qint64 readBytes, qint64 totalBytes) {
  // TODO.
  Q_UNUSED(readBytes);
  Q_UNUSED(totalBytes);
}
