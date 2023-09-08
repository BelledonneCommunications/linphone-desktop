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
#include "ImageModel.hpp"

#include <QQmlApplicationEngine>
#include <QImageReader>
#include <QPainter>
#include <QMediaPlayer>
#include <QSvgRenderer>
#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/QExifImageHeader.hpp"
#include "VideoFrameGrabber.hpp"

#include <QVideoSurfaceFormat>

// =============================================================================

ImageModel::ImageModel (const QString& id, const QString& path, const QString& description, QObject * parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mId = id;
	//setPath(path);
	mPath = path;
	setDescription(description) ;
}

// -----------------------------------------------------------------------------

QString ImageModel::getId() const{
	return mId;
}

QString ImageModel::getPath() const{
	return mPath;
}
QString ImageModel::getDescription() const{
	return mDescription;
}


void ImageModel::setPath(const QString& data){
	if(data != mPath){
		mPath = data;
		emit pathChanged();
		QString old = mId;
		mId="";// Force change
		emit idChanged();
		mId=old;
		emit idChanged();
	}
}

void ImageModel::setDescription(const QString& data){
	if(data != mDescription){
		mDescription = data;
		emit descriptionChanged();
	}
}

void ImageModel::setUrl(const QUrl& url){
	setPath(url.toString(QUrl::RemoveScheme));
}

QImage ImageModel::createThumbnail(const QString& path, QImage originalImage){
	QImage thumbnail;
	if (!originalImage.isNull()){
		int rotation = 0;
		QExifImageHeader exifImageHeader;
		if (exifImageHeader.loadFromJpeg(path))
			rotation = int(exifImageHeader.value(QExifImageHeader::ImageTag::Orientation).toShort());
		double factor = originalImage.width() / (double)originalImage.height();
		Qt::AspectRatioMode aspectRatio = Qt::KeepAspectRatio;
		if(factor < 0.2 || factor > 5)
			aspectRatio = Qt::KeepAspectRatioByExpanding;
		QImageReader reader(path);
		if(reader.format() == "svg"){
			QSvgRenderer svgRenderer(path);
			if(svgRenderer.isValid()){
				thumbnail = QImage(Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight, originalImage.format());
				thumbnail.fill(QColor(Qt::transparent));
				QPainter painter(&thumbnail);
				svgRenderer.setAspectRatioMode(aspectRatio);
				svgRenderer.render(&painter);
			}
		}
		if(thumbnail.isNull()){
			QImage image(originalImage.size(), originalImage.format());
			// Fill with color to replace transparency with white color instead of black (default).
			image.fill(QColor(Qt::white).rgb());
			QPainter painter(&image);
			painter.drawImage(0, 0, originalImage);
			//--------------------
			thumbnail = image.scaled(
						Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight,
						aspectRatio , Qt::SmoothTransformation
						);
			if(aspectRatio == Qt::KeepAspectRatioByExpanding)// Cut
				thumbnail = thumbnail.copy(0,0,Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight);
		}
		
		
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
	}
	return thumbnail;
}

void ImageModel::retrieveImageAsync(QString path, VideoFrameGrabberListener* requester){
	QImage thumbnail;
	if(QFileInfo(path).isFile()){
		bool removeExportedFile = CoreManager::getInstance()->getSettingsModel()->getVfsEncrypted();
		if(removeExportedFile) {
			std::shared_ptr<linphone::Content> content = linphone::Factory::get()->createContentFromFile(Utils::appStringToCoreString(path));
			path = Utils::coreStringToAppString(content->exportPlainFile());
		}
		QImage originalImage(path);
		if( originalImage.isNull()){// Try to determine format from headers
			QImageReader reader(path);
			reader.setDecideFormatFromContent(true);
			QByteArray format = reader.format();
			if(!format.isEmpty()){
				originalImage = QImage(path, format);
			}else if(Utils::isVideo(path)){
				VideoFrameGrabber *grabber = new VideoFrameGrabber(removeExportedFile);
				removeExportedFile = false;
				connect(grabber, &VideoFrameGrabber::grabFinished, requester, &VideoFrameGrabberListener::imageGrabbed);
				grabber->requestFrame(path);
			}
		}
		if(removeExportedFile)
			QFile(path).remove();
		if(!originalImage.isNull()){
			emit requester->imageGrabbed(originalImage);
		}
	}
}
