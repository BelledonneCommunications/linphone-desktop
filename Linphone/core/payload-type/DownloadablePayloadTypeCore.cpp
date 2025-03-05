/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "DownloadablePayloadTypeCore.hpp"
#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "tool/file/FileDownloader.hpp"
#include "tool/file/FileExtractor.hpp"

DEFINE_ABSTRACT_OBJECT(DownloadablePayloadTypeCore)

QSharedPointer<DownloadablePayloadTypeCore> DownloadablePayloadTypeCore::create(PayloadTypeCore::Family family,
                                                                                const QString &mimeType,
                                                                                const QString &encoderDescription,
                                                                                const QString &downloadUrl,
                                                                                const QString &installName,
                                                                                const QString &checkSum) {
	auto sharedPointer = QSharedPointer<DownloadablePayloadTypeCore>(
	    new DownloadablePayloadTypeCore(family, mimeType, encoderDescription, downloadUrl, installName, checkSum),
	    &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

DownloadablePayloadTypeCore::DownloadablePayloadTypeCore(PayloadTypeCore::Family family,
                                                         const QString &mimeType,
                                                         const QString &encoderDescription,
                                                         const QString &downloadUrl,
                                                         const QString &installName,
                                                         const QString &checkSum)
    : PayloadTypeCore() {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mDownloadablePayloadTypeModel = Utils::makeQObject_ptr<DownloadablePayloadTypeModel>();

	mFamily = family;
	mMimeType = mimeType;
	mEnabled = false;
	mDownloadable = true;

	mEncoderDescription = encoderDescription;
	mDownloadUrl = downloadUrl;
	mInstallName = installName;
	mCheckSum = checkSum;
}

DownloadablePayloadTypeCore::~DownloadablePayloadTypeCore() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
}

void DownloadablePayloadTypeCore::setSelf(QSharedPointer<DownloadablePayloadTypeCore> me) {
	mDownloadablePayloadTypeModelConnection =
	    SafeConnection<DownloadablePayloadTypeCore, DownloadablePayloadTypeModel>::create(
	        me, mDownloadablePayloadTypeModel);

	mDownloadablePayloadTypeModelConnection->makeConnectToCore(
	    &DownloadablePayloadTypeCore::extractSuccess, [this](QString filePath) {
		    mDownloadablePayloadTypeModelConnection->invokeToModel(
		        [this, filePath]() { mDownloadablePayloadTypeModel->loadLibrary(filePath); });
	    });

	mDownloadablePayloadTypeModelConnection->makeConnectToModel(
	    &DownloadablePayloadTypeModel::loaded, [this](bool success) {
		    mDownloadablePayloadTypeModelConnection->invokeToCore([this, success]() { emit loaded(success); });
	    });
}

void DownloadablePayloadTypeCore::downloadAndExtract(bool isUpdate) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	lInfo() << log().arg("Downloading `%1` codec…").arg(mMimeType);
	auto codecsFolder = Paths::getCodecsDirPath();
	QString versionFilePath = codecsFolder + mMimeType + ".txt";
	QFile versionFile(versionFilePath);

	FileDownloader *fileDownloader = new FileDownloader(this);
	fileDownloader->setUrl(QUrl(mDownloadUrl));
	fileDownloader->setDownloadFolder(codecsFolder);

	FileExtractor *fileExtractor = new FileExtractor(fileDownloader);
	fileExtractor->setExtractFolder(codecsFolder);
	fileExtractor->setExtractName(mInstallName + (isUpdate ? ".in" : ""));

	QObject::connect(fileDownloader, &FileDownloader::downloadFinished,
	                 [this, fileDownloader, fileExtractor, checksum = mCheckSum](const QString &filePath) {
		                 fileExtractor->setFile(filePath);
		                 QString fileChecksum = Utils::getFileChecksum(filePath);
		                 if (checksum.isEmpty() || fileChecksum == checksum) fileExtractor->extract();
		                 else {
			                 lWarning() << log().arg("File cannot be downloaded : Bad checksum : ") << fileChecksum;
			                 fileDownloader->remove();
			                 fileDownloader->deleteLater();
			                 emit downloadError();
		                 }
	                 });

	QObject::connect(fileDownloader, &FileDownloader::downloadFailed, [this, fileDownloader]() {
		fileDownloader->deleteLater();
		emit downloadError();
	});

	QObject::connect(
	    fileExtractor, &FileExtractor::extractFinished,
	    [this, fileDownloader, fileExtractor, versionFilePath, downloadUrl = mDownloadUrl]() {
		    QFile versionFile(versionFilePath);
		    if (!versionFile.open(QIODevice::WriteOnly)) {
			    lWarning() << log().arg("Unable to write codec version in: `%1`.").arg(versionFilePath);
			    emit extractError();
		    } else if (versionFile.write(Utils::appStringToCoreString(downloadUrl).c_str(), downloadUrl.length()) ==
		               -1) {
			    fileExtractor->remove();
			    versionFile.close();
			    versionFile.remove();
			    emit extractError();
		    } else emit extractSuccess(fileExtractor->getExtractFolder() + "/" + fileExtractor->getExtractName());
		    fileDownloader->remove();
		    fileDownloader->deleteLater();
	    });

	QObject::connect(fileExtractor, &FileExtractor::extractFailed, [this, fileDownloader]() {
		fileDownloader->remove();
		fileDownloader->deleteLater();
		emit extractError();
	});

	fileDownloader->download();
}

bool DownloadablePayloadTypeCore::shouldDownloadUpdate() {
	auto codecsFolder = Paths::getCodecsDirPath();
	QString versionFilePath = codecsFolder + mMimeType + ".txt";
	QFile versionFile(versionFilePath);

	if (!versionFile.exists() && !QFileInfo::exists(codecsFolder + mInstallName)) {
		lWarning() << log().arg("Codec `%1` is not installed.").arg(versionFilePath);
		return false;
	}
	if (!versionFile.open(QIODevice::ReadOnly)) {
		lWarning() << log().arg("Codec `%1` : unable to read codec version, attempting download.").arg(versionFilePath);
		return true;
	} else if (!QString::compare(QTextStream(&versionFile).readAll(), mDownloadUrl, Qt::CaseInsensitive)) {
		lInfo() << log().arg("Codec `%1` is installed and up to date.").arg(versionFilePath);
		return false;
	} else {
		return true;
	}
}
