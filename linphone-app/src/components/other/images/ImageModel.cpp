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
#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/QExifImageHeader.hpp"

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

QImage ImageModel::createThumbnail(const QString& path){
	QImage thumbnail;
	if(QFileInfo(path).isFile()){
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
			double factor = image.width() / (double)image.height();
			if(factor < 0.2 || factor > 5){
				qInfo() << QStringLiteral("Cannot create thumbnails because size factor (%1) is too low/much of: `%2`.").arg(factor).arg(path);
			}else {
				thumbnail = image.scaled(
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
			}
		}
	}
	return thumbnail;
}