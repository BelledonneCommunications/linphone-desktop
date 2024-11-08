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

#ifndef FILE_DOWNLOADER_H_
#define FILE_DOWNLOADER_H_

#include <QObject>
#include <QThread>
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
	Q_PROPERTY(QString checksum READ getChecksum WRITE setChecksum NOTIFY checksumChanged);

public:
	FileDownloader(QObject *parent = Q_NULLPTR) : QObject(parent) {
		// See: https://bugreports.qt.io/browse/QTBUG-57390
		mTimeout.setInterval(DefaultTimeout);
		QObject::connect(&mTimeout, &QTimer::timeout, this, &FileDownloader::handleTimeout);
	}

	~FileDownloader() {
		if (mNetworkReply) mNetworkReply->abort();
	}

	Q_INVOKABLE void download();
	Q_INVOKABLE bool remove();

	QUrl getUrl() const;
	void setUrl(const QUrl &url);

	QString getDownloadFolder() const;
	void setDownloadFolder(const QString &downloadFolder);

	QString getDestinationFileName() const;

	void setOverwriteFile(const bool &overwrite);
	static QString
	synchronousDownload(const QUrl &url,
	                    const QString &destinationFolder,
	                    const bool &overwriteFile); // Return the filpath. Empty if nof file could be downloaded

	QString getChecksum() const;
	void setChecksum(const QString &code);

signals:
	void urlChanged(const QUrl &url);
	void downloadFolderChanged(const QString &downloadFolder);
	void readBytesChanged(qint64 readBytes);
	void totalBytesChanged(qint64 totalBytes);
	void downloadingChanged(bool downloading);
	void downloadFinished(const QString &filePath);
	void downloadFailed();
	void checksumChanged();

private:
	qint64 getReadBytes() const;
	void setReadBytes(qint64 readBytes);

	qint64 getTotalBytes() const;
	void setTotalBytes(qint64 totalBytes);

	bool getDownloading() const;
	void setDownloading(bool downloading);

	void emitOutputError();

	void cleanDownloadEnd();

	void handleReadyData();
	void handleDownloadFinished();

	void handleError(QNetworkReply::NetworkError code);
	void handleSslErrors(const QList<QSslError> &errors);
	void handleTimeout();
	void handleDownloadProgress(qint64 readBytes, qint64 totalBytes);

	QUrl mUrl;
	QString mDownloadFolder;
	QFile mDestinationFile;
	QString mCheckSum;

	qint64 mReadBytes = 0;
	qint64 mTotalBytes = 0;
	bool mDownloading = false;
	bool mOverwriteFile = false;

	QPointer<QNetworkReply> mNetworkReply;
	QNetworkAccessManager mManager;

	qint64 mTimeoutReadBytes;
	QTimer mTimeout;

	static constexpr int DefaultTimeout = 5000;
};

#endif // FILE_DOWNLOADER_H_
