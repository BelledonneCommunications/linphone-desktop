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
#include <QProcess>
#include <QTimer>

#include "FileDownloader.hpp"
#include "FileExtractor.hpp"
#include "core/path/Paths.hpp"
#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

// =============================================================================

using namespace std;

FileExtractor::FileExtractor(QObject *parent) : QObject(parent) {
}

FileExtractor::~FileExtractor() {
}

void FileExtractor::extract() {
	if (mExtracting) {
		qWarning() << "Unable to extract file. Already extracting!";
		return;
	}
	setExtracting(true);
	QFileInfo fileInfo(mFile);
	if (!fileInfo.isReadable()) {
		emitExtractFailed(-1);
		return;
	}

	mDestinationFile = QDir::cleanPath(mExtractFolder) + QDir::separator() +
	                   (mExtractName.isEmpty() ? fileInfo.completeBaseName() : mExtractName);
	if (QFile::exists(mDestinationFile) && !QFile::remove(mDestinationFile)) {
		emitOutputError();
		return;
	}
	if (mTimer == nullptr) {
		mTimer = new QTimer(this);
		QObject::connect(mTimer, &QTimer::timeout, this, &FileExtractor::handleExtraction);
	}
#ifdef WIN32
	// Test the presence of bzip2 in the system
	QProcess process;
	process.closeReadChannel(QProcess::StandardOutput);
	process.closeReadChannel(QProcess::StandardError);
	process.start("bzip2.exe", QStringList("--help"));
	// int result = QProcess::execute("bzip2.exe", QStringList("--help"));
	if (process.error() != QProcess::FailedToStart ||
	    QProcess::execute(Paths::getToolsDirPath() + "\\bzip2.exe", QStringList()) != -2) {
		mTimer->start();
	} else { // Download bzip2
		qWarning() << "bzip2 was not found. Downloading it.";
		QTimer *timer = mTimer;
		FileDownloader *fileDownloader = new FileDownloader();
		int downloadStep = 0;
		fileDownloader->setUrl(QUrl(Constants::LinphoneBZip2_exe));
		fileDownloader->setDownloadFolder(Paths::getToolsDirPath());
		QObject::connect(fileDownloader, &FileDownloader::totalBytesChanged, this, &FileExtractor::setTotalBytes);
		QObject::connect(fileDownloader, &FileDownloader::readBytesChanged, this, &FileExtractor::setReadBytes);

		QObject::connect(fileDownloader, &FileDownloader::downloadFinished,
		                 [fileDownloader, timer, downloadStep, this]() mutable {
			                 if (downloadStep++ == 0) {
				                 fileDownloader->setUrl(QUrl(Constants::LinphoneBZip2_dll));
				                 fileDownloader->download();
			                 } else {
				                 fileDownloader->deleteLater();
				                 QObject::disconnect(fileDownloader, &FileDownloader::totalBytesChanged, this,
				                                     &FileExtractor::setTotalBytes);
				                 QObject::disconnect(fileDownloader, &FileDownloader::readBytesChanged, this,
				                                     &FileExtractor::setReadBytes);
				                 timer->start();
			                 }
		                 });

		QObject::connect(fileDownloader, &FileDownloader::downloadFailed, [fileDownloader, this]() {
			fileDownloader->deleteLater();
			emitExtractorFailed();
		});
		fileDownloader->download();
	}
#else
	mTimer->start();
#endif
}

bool FileExtractor::remove() {
	return QFile::exists(mDestinationFile) && QFile::remove(mDestinationFile);
}

QString FileExtractor::getFile() const {
	return mFile;
}

void FileExtractor::setFile(const QString &file) {
	if (mExtracting) {
		qWarning() << QStringLiteral("Unable to set file, a file is extracting.");
		return;
	}
	if (mFile != file) {
		mFile = file;
		emit fileChanged(mFile);
	}
}

QString FileExtractor::getExtractFolder() const {
	return mExtractFolder;
}

void FileExtractor::setExtractFolder(const QString &extractFolder) {
	if (mExtracting) {
		qWarning() << QStringLiteral("Unable to set extract folder, a file is extracting.");
		return;
	}
	if (mExtractFolder != extractFolder) {
		mExtractFolder = extractFolder;
		emit extractFolderChanged(mExtractFolder);
	}
}

QString FileExtractor::getExtractName() const {
	return mExtractName;
}

void FileExtractor::setExtractName(const QString &extractName) {
	if (mExtracting) {
		qWarning() << QStringLiteral("Unable to set extract name, a file is extracting.");
		return;
	}
	if (mExtractName != extractName) {
		mExtractName = extractName;
		emit extractNameChanged(mExtractName);
	}
}

bool FileExtractor::getExtracting() const {
	return mExtracting;
}

void FileExtractor::setExtracting(bool extracting) {
	if (mExtracting != extracting) {
		mExtracting = extracting;
		emit extractingChanged(extracting);
	}
}

qint64 FileExtractor::getReadBytes() const {
	return mReadBytes;
}

void FileExtractor::setReadBytes(qint64 readBytes) {
	mReadBytes = readBytes;
	emit readBytesChanged(readBytes);
}

qint64 FileExtractor::getTotalBytes() const {
	return mTotalBytes;
}

void FileExtractor::setTotalBytes(qint64 totalBytes) {
	mTotalBytes = totalBytes;
	emit totalBytesChanged(totalBytes);
}
void FileExtractor::clean() {
	if (mTimer) {
		mTimer->stop();
		mTimer->deleteLater();
		mTimer = nullptr;
	}
	setExtracting(false);
}

void FileExtractor::emitExtractorFailed() {
	qWarning() << QStringLiteral("Unable to extract file `%1`. bzip2 is unavailable, please install it.").arg(mFile);
	clean();
	emit extractFailed();
}
void FileExtractor::emitExtractFailed(int error) {
	qWarning() << QStringLiteral("Unable to extract file with bzip2: `%1` (code: %2).").arg(mFile).arg(error);
	clean();
	emit extractFailed();
}

void FileExtractor::emitExtractFinished() {
	clean();
	emit extractFinished();
}

void FileExtractor::emitOutputError() {
	qWarning() << QStringLiteral("Could not write into `%1`.").arg(mDestinationFile);
	clean();
	emit extractFailed();
}

void FileExtractor::handleExtraction() {
	QString tempDestination = mDestinationFile + "." + QFileInfo(mFile).suffix();
	QStringList args;
	args.push_back("-dq");
	args.push_back(tempDestination);
	QFile::copy(mFile, tempDestination);
#ifdef WIN32
	int result = QProcess::execute("bzip2.exe", args);
	if (result == -2) result = QProcess::execute(Paths::getToolsDirPath() + "\\bzip2.exe", args);
#else
	int result = QProcess::execute("bzip2", args);
#endif
	if (QFile::exists(tempDestination)) QFile::remove(tempDestination);
	if (result == 0) {
		setReadBytes(getTotalBytes());
		emitExtractFinished();
	} else if (result > 0) emitExtractFailed(result);
	else if (result == -2) emitExtractorFailed();
	else emitOutputError();
}
