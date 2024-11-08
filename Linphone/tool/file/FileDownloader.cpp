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

#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "tool/Utils.hpp"
#include <QDebug>
#include <QTest>

#include "FileDownloader.hpp"

// =============================================================================

static QString getDownloadFilePath(const QString &folder, const QUrl &url, const bool &overwrite) {
	QString defaultFileName = QString(Constants::DownloadDefaultFileName);
	QFileInfo fileInfo(url.path());
	QString fileName = fileInfo.fileName();
	if (fileName.isEmpty()) fileName = defaultFileName;

	fileName.prepend(folder);
	if (overwrite && QFile::exists(fileName)) QFile::remove(fileName);
	if (!QFile::exists(fileName)) return fileName;

	// Already exists, don't overwrite.
	QString baseName = fileInfo.completeBaseName();
	if (baseName.isEmpty()) baseName = defaultFileName;

	QString suffix = fileInfo.suffix();
	if (!suffix.isEmpty()) suffix.prepend(".");

	for (int i = 1; true; ++i) {
		fileName = folder + baseName + "(" + QString::number(i) + ")" + suffix;
		if (!QFile::exists(fileName)) break;
	}
	return fileName;
}

static bool isHttpRedirect(QNetworkReply *reply) {
	Q_CHECK_PTR(reply);
	int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
	return statusCode == 301 || statusCode == 302 || statusCode == 303 || statusCode == 305 || statusCode == 307 ||
	       statusCode == 308;
}

// -----------------------------------------------------------------------------

void FileDownloader::download() {
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
	QObject::connect(data, &QNetworkReply::errorOccurred, this, &FileDownloader::handleError);
	QObject::connect(data, &QNetworkReply::downloadProgress, this, &FileDownloader::handleDownloadProgress);

#if QT_CONFIG(ssl)
	QObject::connect(data, &QNetworkReply::sslErrors, this, &FileDownloader::handleSslErrors);
#endif

	if (mDownloadFolder.isEmpty()) {
		mDownloadFolder = App::getInstance()->getSettings()->getDownloadFolder();
		emit downloadFolderChanged(mDownloadFolder);
	}

	Q_ASSERT(!mDestinationFile.isOpen());
	mDestinationFile.setFileName(
	    getDownloadFilePath(QDir::cleanPath(mDownloadFolder) + QDir::separator(), mUrl, mOverwriteFile));
	if (!mDestinationFile.open(QIODevice::WriteOnly)) emitOutputError();
	else {
		mTimeoutReadBytes = 0;
		mTimeout.start();
	}
}

bool FileDownloader::remove() {
	return mDestinationFile.exists() && !mDestinationFile.isOpen() && mDestinationFile.remove();
}

void FileDownloader::emitOutputError() {
	qWarning() << QStringLiteral("Could not write into `%1` (%2).")
	                  .arg(mDestinationFile.fileName())
	                  .arg(mDestinationFile.errorString());
	mNetworkReply->abort();
}

void FileDownloader::cleanDownloadEnd() {
	mTimeout.stop();
	mNetworkReply->deleteLater();
	setDownloading(false);
}

void FileDownloader::handleReadyData() {
	QByteArray data = mNetworkReply->readAll();
	if (mDestinationFile.write(data) == -1) emitOutputError();
}

void FileDownloader::handleDownloadFinished() {
	if (mNetworkReply->error() != QNetworkReply::NoError) return;

	if (isHttpRedirect(mNetworkReply)) {
		qWarning() << QStringLiteral("Request was redirected.");
		mDestinationFile.remove();
		cleanDownloadEnd();
		emit downloadFailed();
	} else {
		qInfo() << QStringLiteral("Download of %1 finished to %2").arg(mUrl.toString(), mDestinationFile.fileName());
		mDestinationFile.close();
		cleanDownloadEnd();
		QString fileChecksum = Utils::getFileChecksum(mDestinationFile.fileName());
		if (mCheckSum.isEmpty() || fileChecksum == mCheckSum) emit downloadFinished(mDestinationFile.fileName());
		else {
			qCritical() << "File cannot be downloaded : Bad checksum " << fileChecksum;
			mDestinationFile.remove();
			emit downloadFailed();
		}
	}
}

void FileDownloader::handleError(QNetworkReply::NetworkError code) {
	if (code != QNetworkReply::OperationCanceledError)
		qWarning()
		    << QStringLiteral("Download of %1 failed: %2").arg(mUrl.toString()).arg(mNetworkReply->errorString());
	mDestinationFile.remove();

	cleanDownloadEnd();

	emit downloadFailed();
}

void FileDownloader::handleSslErrors(const QList<QSslError> &sslErrors) {
#if QT_CONFIG(ssl)
	for (const QSslError &error : sslErrors)
		qWarning() << QStringLiteral("SSL error: %1").arg(error.errorString());
#else
	Q_UNUSED(sslErrors);
#endif
}

void FileDownloader::handleTimeout() {
	if (mReadBytes == mTimeoutReadBytes) {
		qWarning() << QStringLiteral("Download of %1 failed: timeout.").arg(mUrl.toString());
		mNetworkReply->abort();
	} else mTimeoutReadBytes = mReadBytes;
}

void FileDownloader::handleDownloadProgress(qint64 readBytes, qint64 totalBytes) {
	setReadBytes(readBytes);
	setTotalBytes(totalBytes);
}

// -----------------------------------------------------------------------------

QUrl FileDownloader::getUrl() const {
	return mUrl;
}

void FileDownloader::setUrl(const QUrl &url) {
	if (mDownloading) {
		qWarning() << QStringLiteral("Unable to set url, a file is downloading.");
		return;
	}

	if (mUrl != url) {
		mUrl = url;
		if (!QSslSocket::supportsSsl() && mUrl.scheme() == "https") {
			qWarning() << "Https has been requested but SSL is not supported. Fallback to http. Install manually "
			              "OpenSSL libraries in your PATH.";
			mUrl.setScheme("http");
		}
		emit urlChanged(mUrl);
	}
}

QString FileDownloader::getDownloadFolder() const {
	return mDownloadFolder;
}

void FileDownloader::setDownloadFolder(const QString &downloadFolder) {
	if (mDownloading) {
		qWarning() << QStringLiteral("Unable to set download folder, a file is downloading.");
		return;
	}

	if (mDownloadFolder != downloadFolder) {
		mDownloadFolder = downloadFolder;
		emit downloadFolderChanged(mDownloadFolder);
	}
}

QString FileDownloader::getDestinationFileName() const {
	return mDestinationFile.fileName();
}

void FileDownloader::setOverwriteFile(const bool &overwrite) {
	mOverwriteFile = overwrite;
}

QString
FileDownloader::synchronousDownload(const QUrl &url, const QString &destinationFolder, const bool &overwriteFile) {
	QString filePath;
	FileDownloader downloader;
	if (url.isRelative()) qWarning() << "FileDownloader: The specified URL is not valid";
	else {
		bool isOver = false;
		bool *pIsOver = &isOver;
		downloader.setUrl(url);
		downloader.setOverwriteFile(overwriteFile);
		downloader.setDownloadFolder(destinationFolder);
		connect(&downloader, &FileDownloader::downloadFinished, [pIsOver]() mutable { *pIsOver = true; });
		connect(&downloader, &FileDownloader::downloadFailed, [pIsOver]() mutable { *pIsOver = true; });
		downloader.download();
		if (QTest::qWaitFor([&]() { return isOver; }, DefaultTimeout)) {
			filePath = downloader.getDestinationFileName();
			if (!QFile::exists(filePath)) {
				filePath = "";
				qWarning() << "FileDownloader: Cannot download the specified file";
			}
		}
	}
	return filePath;
}

QString FileDownloader::getChecksum() const {
	return mCheckSum;
}

void FileDownloader::setChecksum(const QString &code) {
	if (mCheckSum != code) {
		mCheckSum = code;
		emit checksumChanged();
	}
}

qint64 FileDownloader::getReadBytes() const {
	return mReadBytes;
}

void FileDownloader::setReadBytes(qint64 readBytes) {
	if (mReadBytes != readBytes) {
		mReadBytes = readBytes;
		emit readBytesChanged(readBytes);
	}
}

qint64 FileDownloader::getTotalBytes() const {
	return mTotalBytes;
}

void FileDownloader::setTotalBytes(qint64 totalBytes) {
	if (mTotalBytes != totalBytes) {
		mTotalBytes = totalBytes;
		emit totalBytesChanged(totalBytes);
	}
}

bool FileDownloader::getDownloading() const {
	return mDownloading;
}

void FileDownloader::setDownloading(bool downloading) {
	if (mDownloading != downloading) {
		mDownloading = downloading;
		emit downloadingChanged(downloading);
	}
}
