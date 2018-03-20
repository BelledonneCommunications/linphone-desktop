/*
 * FileDownloader.hpp
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
#ifndef FILE_DOWNLOADER_H_ 
#define FILE_DOWNLOADER_H_
#include <QObject>
#include <QtNetwork>

// =============================================================================

class QSslError;

class FileDownloader : public QObject {
  Q_OBJECT;

  // TODO: Add an error property to use in UI.

  Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged);
  Q_PROPERTY(QString downloadFolder READ getDownloadFolder WRITE setDownloadFolder NOTIFY downloadFolderChanged);
  Q_PROPERTY(qint64 readBytes READ getReadBytes NOTIFY readBytesChanged);
  Q_PROPERTY(qint64 totalBytes READ getTotalBytes NOTIFY totalBytesChanged);
  Q_PROPERTY(bool downloading READ getDownloading NOTIFY downloadingChanged);

public:
  Q_INVOKABLE void download ();
  Q_INVOKABLE bool remove();
  Q_INVOKABLE void setUrl (const QUrl &url);
  Q_INVOKABLE void setDownloadFolder (const QString &downloadFolder);
  Q_INVOKABLE void writeVersion (const QString &newFileName);

signals:
  void urlChanged (const QUrl &url);
  void downloadFolderChanged (const QString &downloadFolder);
  void readBytesChanged (qint64 readBytes);
  void totalBytesChanged (qint64 totalBytes);
  void downloadingChanged (bool downloading);
  void downloadFinished (const QString &filePath);
  void downloadFailed();

private:
  QUrl getUrl () const;

  QString getDownloadFolder () const;

  qint64 getReadBytes () const;
  void setReadBytes (qint64 readBytes);

  qint64 getTotalBytes () const;
  void setTotalBytes (qint64 totalBytes);

  bool getDownloading () const;
  void setDownloading (bool downloading);

  void emitOutputError ();

  void handleReadyData ();
  void handleDownloadFinished ();

  void handleSslErrors (const QList<QSslError> &errors);
  void handleDownloadProgress (qint64 readBytes, qint64 totalBytes);

  QUrl mUrl;
  QString mDownloadFolder;
  QFile mDestinationFile;

  qint64 mReadBytes = 0;
  qint64 mTotalBytes = 0;
  bool mDownloading = false;

  QPointer<QNetworkReply> mNetworkReply;
  QNetworkAccessManager mManager;
};
#endif // FILE_DOWNLOADER_H_