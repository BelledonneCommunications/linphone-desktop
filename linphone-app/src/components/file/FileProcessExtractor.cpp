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
#include <QDir>
#include <QTimer>
#include <QProcess>

#include "FileProcessExtractor.hpp"

// =============================================================================

using namespace std;


FileExtractor::FileExtractor (QObject *parent) : QObject(parent) {}

FileExtractor::~FileExtractor () {}

void FileExtractor::extract () {
  if (mExtracting) {
    qWarning() << "Unable to extract file. Already extracting!";
    return;
  }
  setExtracting(true);
  QFileInfo fileInfo(mFile);
  if(!fileInfo.isReadable()){
	emitExtractFailed(-1);
	return;
  }

  mDestinationFile = QDir::cleanPath(mExtractFolder) + QDir::separator() + (mExtractName.isEmpty() ? fileInfo.completeBaseName() : mExtractName);
  if(QFile::exists(mDestinationFile) && !QFile::remove(mDestinationFile)){
    emitOutputError();
    return;
  }

  mTimer = new QTimer(this);
  QObject::connect(mTimer, &QTimer::timeout, this, &FileExtractor::handleExtraction);
  mTimer->start();
}

bool FileExtractor::remove () {
  return QFile::exists(mDestinationFile) && QFile::remove(mDestinationFile);
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

bool FileExtractor::getExtracting () const {
  return mExtracting;
}

void FileExtractor::setExtracting (bool extracting) {
  if (mExtracting != extracting) {
    mExtracting = extracting;
    emit extractingChanged(extracting);
  }
}
qint64 FileExtractor::getReadBytes () const {
  return mReadBytes;
}
qint64 FileExtractor::getTotalBytes () const {
  return mTotalBytes;
}
void FileExtractor::clean () {
  if (mTimer) {
    mTimer->stop();
    mTimer->deleteLater();
    mTimer = nullptr;
  }
  setExtracting(false);
}

void FileExtractor::emitExtractFailed (int error) {
  qWarning() << QStringLiteral("Unable to extract file with bzip2: `%1` (code: %2).")
    .arg(mFile).arg(error);
  clean();
  emit extractFailed();
}

void FileExtractor::emitExtractFinished () {
  clean();
  emit extractFinished();
}

void FileExtractor::emitOutputError () {
  qWarning() << QStringLiteral("Could not write into `%1`.")
    .arg(mDestinationFile);
  clean();
  emit extractFailed();
}

void FileExtractor::handleExtraction () {
  QString tempDestination = mDestinationFile+"."+QFileInfo(mFile).suffix();
  QStringList args;
  args.push_back("-dq");
  args.push_back(tempDestination);
  QFile::copy(mFile, tempDestination);
  int result = QProcess::execute("bzip2", args);
  if(QFile::exists(tempDestination))
       QFile::remove(tempDestination);
  if (result == 0)
    emitExtractFinished();
  else if (result > 0)
    emitExtractFailed(result);
  else
    emitOutputError();
}
