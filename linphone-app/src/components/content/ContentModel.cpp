/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include "ContentModel.hpp"

#include <QQmlApplicationEngine>
#include <QDesktopServices>
#include <QImageReader>
#include <QMessageBox>
#include <QPainter>

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "app/providers/ThumbnailProvider.hpp"

#include "components/chat-events/ChatMessageModel.hpp"

#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "components/Components.hpp"

// =============================================================================

ContentModel::ContentModel(ChatMessageModel* chatModel) : mAppData(chatModel ? QString::fromStdString(chatModel->getChatMessage()->getAppdata()) : ""){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mChatMessageModel = chatModel;
	mWasDownloaded = false;
	mFileOffset = 0;
}
ContentModel::ContentModel(std::shared_ptr<linphone::Content> content, ChatMessageModel* chatModel) : mAppData(chatModel ? QString::fromStdString(chatModel->getChatMessage()->getAppdata()) : ""){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mChatMessageModel = chatModel;
	mWasDownloaded = false;
	mFileOffset = 0;
	setContent(content);
}
std::shared_ptr<linphone::Content> ContentModel::getContent()const{
	return mContent;
}

ChatMessageModel * ContentModel::getChatMessageModel()const{
	return mChatMessageModel;
}

quint64 ContentModel::getFileSize() const{
	auto s = mContent->getFileSize();
	return (quint64)s;
}

QString ContentModel::getName() const{
	QString name = QString::fromStdString(mContent->getName());
	if( name == "") {	// Try to find the name from file Path
		QString fileName = QString::fromStdString(mContent->getFilePath());
		if(fileName != ""){
			name = QFileInfo(fileName).baseName();
		}
	}
	return name;
}

QString ContentModel::getThumbnail() const{
	return mThumbnail;
}

QString ContentModel::getFilePath() const{
	return Utils::coreStringToAppString(mContent->getFilePath());
}

QString ContentModel::getUtf8Text() const{
	return QString::fromStdString(mContent->getUtf8Text());
}

ConferenceInfoModel * ContentModel::getConferenceInfoModel(){
	if( !mConferenceInfoModel && isIcalendar()){
		auto conferenceInfo = linphone::Factory::get()->createConferenceInfoFromIcalendarContent(mContent);
		if(conferenceInfo)
			mConferenceInfoModel = ConferenceInfoModel::create(conferenceInfo);
	}
	return mConferenceInfoModel.get();
}

void ContentModel::setFileOffset(quint64 fileOffset){
	if( mFileOffset != fileOffset) {
		mFileOffset = fileOffset;
		emit fileOffsetChanged();
	}
}
void ContentModel::setThumbnail(const QString& data){
	if( mThumbnail != data) {
		mThumbnail = data;
		emit thumbnailChanged();
	}
}
void ContentModel::setWasDownloaded(bool wasDownloaded){
	if( mWasDownloaded != wasDownloaded) {
		mWasDownloaded = wasDownloaded;
		emit wasDownloadedChanged();
	}
}

void ContentModel::setContent(std::shared_ptr<linphone::Content> content){
	mContent = content;
	emit nameChanged();
	mConferenceInfoModel = nullptr;
	if(isFile() || isFileEncrypted() || isFileTransfer() ){
		QString path = Utils::coreStringToAppString(mContent->getFilePath());
		if (!path.isEmpty())
			createThumbnail();
	}
}

bool ContentModel::isFile() const{
	return mContent->isFile();
}
bool ContentModel::isFileEncrypted() const{
	return mContent->isFileEncrypted();
}
bool ContentModel::isFileTransfer() const{
	return mContent->isFileTransfer();
}
bool ContentModel::isIcalendar() const{
	return mContent->isIcalendar();
}
bool ContentModel::isMultipart() const{
	return mContent->isMultipart();
}
bool ContentModel::isText() const{
	return mContent->isText();
}
bool ContentModel::isVoiceRecording()const{
	return mContent->isVoiceRecording();
}

int ContentModel::getFileDuration() const {
	return mContent->getFileDuration();
}

// Create a thumbnail from the first content that have a file and store it in Appdata
void ContentModel::createThumbnail (const bool& force) {
	if(force || isFile() || isFileEncrypted() || isFileTransfer()){
		QString id;
		QString path = getFilePath();
		
		auto appdata = ChatMessageModel::AppDataManager(mChatMessageModel ? QString::fromStdString(mChatMessageModel->getChatMessage()->getAppdata()) : "");
		
		if(!appdata.mData.contains(path) 
				|| !QFileInfo(QString::fromStdString(Paths::getThumbnailsDirPath())+appdata.mData[path]).isFile()){
			// File don't exist. Create the thumbnail
			QImage originalImage(path);
			
			if( originalImage.isNull()){// Try to determine format from headers
				QImageReader reader(path);
				reader.setDecideFormatFromContent(true);
				QByteArray format = reader.format();
				if(!format.isEmpty())
					originalImage = QImage(path, format);
			}
			if (!originalImage.isNull()){
				int rotation = 0;
				QExifImageHeader exifImageHeader;
				if (exifImageHeader.loadFromJpeg(path))
					rotation = int(exifImageHeader.value(QExifImageHeader::ImageTag::Orientation).toShort());
// Fill with color to replace transparency with white color instead of black (default).
				QImage image(originalImage.size(), originalImage.format());
				image.fill(QColor(Qt::white).rgb());
				QPainter painter(&image);
				painter.drawImage(0, 0, originalImage);
//--------------------
				QImage thumbnail = image.scaled(
							Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight,
							Qt::KeepAspectRatio, Qt::SmoothTransformation
							);
				
				if (rotation != 0) {
					QTransform transform;
					if (rotation == 3 || rotation == 4)
						transform.rotate(180);
					else if (rotation == 5 || rotation == 6)
						transform.rotate(90);
					else if (rotation == 7 || rotation == 8)
						transform.rotate(-90);
					thumbnail = thumbnail.transformed(transform);
					if (rotation == 2 || rotation == 4 || rotation == 5 || rotation == 7)
						thumbnail = thumbnail.mirrored(true, false);
				}
				QString uuid = QUuid::createUuid().toString();
				id = QStringLiteral("%1.jpg").arg(uuid.mid(1, uuid.length() - 2));
				
				if (!thumbnail.save(QString::fromStdString(Paths::getThumbnailsDirPath()) + id , "jpg", 100)) {
					qWarning() << QStringLiteral("Unable to create thumbnail of: `%1`.").arg(path);
				}else{
					appdata.mData[path] = id;
					mAppData.mData[path] = id;
					if(mChatMessageModel)
						mChatMessageModel->getChatMessage()->setAppdata(appdata.toString().toStdString());
				}
			}
		}
		
		if( path != ""){
			setWasDownloaded( !path.isEmpty() && QFileInfo(path).isFile());
			if(appdata.mData.contains(path) && !appdata.mData[path].isEmpty())
				setThumbnail(QStringLiteral("image://%1/%2").arg(ThumbnailProvider::ProviderId).arg(appdata.mData[path]));
		}
	}
}

void ContentModel::removeThumbnail(){
	for(QMap<QString, QString>::iterator itData = mAppData.mData.begin() ; itData != mAppData.mData.end() ; ++itData){
		QString thumbnailPath = QString::fromStdString(Paths::getThumbnailsDirPath()) +itData.value();
		if( QFileInfo(thumbnailPath).isFile()){
			QFile(thumbnailPath).remove();
		}
	}
	mAppData.mData.clear();
}

void ContentModel::removeDownloadedFile(){
	QString path = getFilePath();
	if( path != ""){
		QFile(path).remove();
	}
}

void ContentModel::downloadFile(){
	switch (mChatMessageModel->getState()) {
		case LinphoneEnums::ChatMessageStateDelivered:
		case LinphoneEnums::ChatMessageStateDeliveredToUser:
		case LinphoneEnums::ChatMessageStateDisplayed:
		case LinphoneEnums::ChatMessageStateFileTransferDone:
			break;
		case LinphoneEnums::ChatMessageStateFileTransferInProgress:
			return;
		default:
			qWarning() << QStringLiteral("Wrong message state when requesting downloading, state=%1.").arg(mChatMessageModel->getState());
	}
	bool soFarSoGood;
	QString filename = getName();//mFileTransfertContent->getName();
	const QString safeFilePath = Utils::getSafeFilePath(
				QStringLiteral("%1%2")
				.arg(CoreManager::getInstance()->getSettingsModel()->getDownloadFolder())
				.arg(filename),
				&soFarSoGood
				);
	
	if (!soFarSoGood) {
		qWarning() << QStringLiteral("Unable to create safe file path for: %1.").arg(filename);
		return;
	}
	mContent->setFilePath(Utils::appStringToCoreString(safeFilePath));
	
	if( !mContent->isFileTransfer()){
		QMessageBox::warning(nullptr, "Download File", "This file was already downloaded and is no more on the server. Your peer have to resend it if you want to get it");
	}else
	{
		if (!mChatMessageModel->getChatMessage()->downloadContent(mContent))
			qWarning() << QStringLiteral("Unable to download file of entry %1.").arg(filename);
	}
}
void ContentModel::cancelDownloadFile(){
	if(mChatMessageModel && mChatMessageModel->getChatMessage()) {
		if(mChatMessageModel->isOutgoing() ){
			mChatMessageModel->deleteEvent();// Uploading is cancelling : Delete event to have clean history.
			emit mChatMessageModel->remove(mChatMessageModel);
		}else
			mChatMessageModel->getChatMessage()->cancelFileTransfer();
	}
}

void ContentModel::openFile (bool showDirectory) {
	if (mChatMessageModel && ((!mWasDownloaded && !mChatMessageModel->isOutgoing()) || mContent->getFilePath() == "")) {
		downloadFile();
	}else{
		QFileInfo info( Utils::coreStringToAppString(mContent->getFilePath()));
		showDirectory = showDirectory || !info.exists();
		if(!QDesktopServices::openUrl(
					QUrl(QStringLiteral("file:///%1").arg(showDirectory ? info.absolutePath() : info.absoluteFilePath()))
					) && !showDirectory){
					QDesktopServices::openUrl(
						QUrl(QStringLiteral("file:///%1").arg(info.absolutePath()))
					);
		}
	}
}

void ContentModel::updateTransferData(){
}