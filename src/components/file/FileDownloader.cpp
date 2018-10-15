/*
 * FileDownloader.cpp
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
 *  Created on: February 6, 2018
 *      Author: Danmei Chen
 */

#include "app/paths/Paths.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

#include "FileDownloader.hpp"

// =============================================================================

namespace {
  constexpr char cDefaultFileName[] = "download";
}

static QString getDownloadFilePath (const QString &folder, const QUrl &url) {
  QFileInfo fileInfo(url.path());
  QString fileName = fileInfo.fileName();
  if (fileName.isEmpty())
    fileName = cDefaultFileName;

  fileName.prepend(folder);
  if (!QFile::exists(fileName))
    return fileName;

  // Already exists, don't overwrite.
  QString baseName = fileInfo.completeBaseName();
  if (baseName.isEmpty())
    baseName = cDefaultFileName;

  QString suffix = fileInfo.suffix();
  if (!suffix.isEmpty())
    suffix.prepend(".");

  for (int i = 1; true; ++i) {
    fileName = folder + baseName + "(" + QString::number(i) + ")" + suffix;
    if (!QFile::exists(fileName))
      break;
  }
  return fileName;
}

static bool isHttpRedirect (QNetworkReply *reply) {
  Q_CHECK_PTR(reply);
  int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  return statusCode == 301 || statusCode == 302 || statusCode == 303
    || statusCode == 305 || statusCode == 307 || statusCode == 308;
}

// -----------------------------------------------------------------------------

void FileDownloader::download () {
  if (mDownloading) {
    qWarning() << "Unable to download file. Already downloading!";
    return;
  }
  setDownloading(true);

  QNetworkRequest request(mUrl);
  mNetworkReply = mManager.get(request);

  QNetworkReply *data = mNetworkReply.data();

  QObject::connect(data, &QNetworkReply::readyRead, this, &FileDownloader::handleReadyData);
  QObject::connect(data, &QNetworkReply::finished, this, &FileDownloader::handleDownloadFinished);
  QObject::connect(data, QNonConstOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error), this, &FileDownloader::handleError);
  QObject::connect(data, &QNetworkReply::downloadProgress, this, &FileDownloader::handleDownloadProgress);

  #if QT_CONFIG(ssl)
    QObject::connect(data, &QNetworkReply::sslErrors, this, &FileDownloader::handleSslErrors);
  #endif

  if (mDownloadFolder.isEmpty()) {
    mDownloadFolder = CoreManager::getInstance()->getSettingsModel()->getDownloadFolder();
    emit downloadFolderChanged(mDownloadFolder);
  }

  Q_ASSERT(!mDestinationFile.isOpen());
  mDestinationFile.setFileName(getDownloadFilePath(QDir::cleanPath(mDownloadFolder) + QDir::separator(), mUrl));
  if (!mDestinationFile.open(QIODevice::WriteOnly))
    emitOutputError();
  else {
    mTimeoutReadBytes = 0;
    mTimeout.start();
  }
}

bool FileDownloader::remove () {
  return mDestinationFile.exists() && !mDestinationFile.isOpen() && mDestinationFile.remove();
}

void FileDownloader::emitOutputError () {
  qWarning() << QStringLiteral("Could not write into `%1` (%2).")
    .arg(mDestinationFile.fileName()).arg(mDestinationFile.errorString());
  mNetworkReply->abort();
}

void FileDownloader::cleanDownloadEnd () {
  mTimeout.stop();
  mNetworkReply->deleteLater();
  setDownloading(false);
}

void FileDownloader::handleReadyData () {
  QByteArray data = mNetworkReply->readAll();
  if (mDestinationFile.write(data) == -1)
    emitOutputError();
}

void FileDownloader::handleDownloadFinished() {
  if (mNetworkReply->error() != QNetworkReply::NoError)
    return;

  // TODO: Deal with redirection.
  if (isHttpRedirect(mNetworkReply)) {
    qWarning() << QStringLiteral("Request was redirected.");
    mDestinationFile.remove();
    emit downloadFailed();
  } else {
    qInfo() << QStringLiteral("Download of %1 finished.").arg(mUrl.toString());
    mDestinationFile.close();
    emit downloadFinished(mDestinationFile.fileName());
  }

  cleanDownloadEnd();
}

void FileDownloader::handleError (QNetworkReply::NetworkError code) {
  if (code != QNetworkReply::OperationCanceledError)
    qWarning() << QStringLiteral("Download of %1 failed: %2")
      .arg(mUrl.toString()).arg(mNetworkReply->errorString());
  mDestinationFile.remove();

  cleanDownloadEnd();

  emit downloadFailed();
}

void FileDownloader::handleSslErrors (const QList<QSslError> &sslErrors) {
  #if QT_CONFIG(ssl)
    for (const QSslError &error : sslErrors)
      qWarning() << QStringLiteral("SSL error: %1").arg(error.errorString());
  #else
    Q_UNUSED(sslErrors);
  #endif
}

void FileDownloader::handleTimeout () {
  if (mReadBytes == mTimeoutReadBytes) {
    qWarning() << QStringLiteral("Download of %1 failed: timeout.").arg(mUrl.toString());
    mNetworkReply->abort();
  } else
    mTimeoutReadBytes = mReadBytes;
}

void FileDownloader::handleDownloadProgress (qint64 readBytes, qint64 totalBytes) {
  setReadBytes(readBytes);
  setTotalBytes(totalBytes);
}

// -----------------------------------------------------------------------------

QUrl FileDownloader::getUrl () const {
  return mUrl;
}

void FileDownloader::setUrl (const QUrl &url) {
  if (mDownloading) {
    qWarning() << QStringLiteral("Unable to set url, a file is downloading.");
    return;
  }

  if (mUrl != url) {
    mUrl = url;
    emit urlChanged(mUrl);
  }
}

QString FileDownloader::getDownloadFolder () const {
  return mDownloadFolder;
}

void FileDownloader::setDownloadFolder (const QString &downloadFolder) {
  if (mDownloading) {
    qWarning() << QStringLiteral("Unable to set download folder, a file is downloading.");
    return;
  }

  if (mDownloadFolder != downloadFolder) {
    mDownloadFolder = downloadFolder;
    emit downloadFolderChanged(mDownloadFolder);
  }
}

qint64 FileDownloader::getReadBytes () const {
  return mReadBytes;
}

void FileDownloader::setReadBytes (qint64 readBytes) {
  if (mReadBytes != readBytes) {
    mReadBytes = readBytes;
    emit readBytesChanged(readBytes);
  }
}

qint64 FileDownloader::getTotalBytes () const {
  return mTotalBytes;
}

void FileDownloader::setTotalBytes (qint64 totalBytes) {
  if (mTotalBytes != totalBytes) {
    mTotalBytes = totalBytes;
    emit totalBytesChanged(totalBytes);
  }
}

bool FileDownloader::getDownloading () const {
  return mDownloading;
}

void FileDownloader::setDownloading (bool downloading) {
  if (mDownloading != downloading) {
    mDownloading = downloading;
    emit downloadingChanged(downloading);
  }
}
