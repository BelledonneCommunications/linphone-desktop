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
#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/QExifImageHeader.hpp"

#include <QVideoSurfaceFormat>

VideoFrameGrabber::VideoFrameGrabber( QObject *parent)
    : QAbstractVideoSurface(parent){
}

QList<QVideoFrame::PixelFormat> VideoFrameGrabber::supportedPixelFormats(QAbstractVideoBuffer::HandleType handleType) const {
    Q_UNUSED(handleType);
    return QList<QVideoFrame::PixelFormat>()
        << QVideoFrame::Format_ARGB32
        << QVideoFrame::Format_ARGB32_Premultiplied
        << QVideoFrame::Format_RGB32
        << QVideoFrame::Format_RGB24
        << QVideoFrame::Format_RGB565
        << QVideoFrame::Format_RGB555
        << QVideoFrame::Format_ARGB8565_Premultiplied
        << QVideoFrame::Format_BGRA32
        << QVideoFrame::Format_BGRA32_Premultiplied
        << QVideoFrame::Format_BGR32
        << QVideoFrame::Format_BGR24
        << QVideoFrame::Format_BGR565
        << QVideoFrame::Format_BGR555
        << QVideoFrame::Format_BGRA5658_Premultiplied
        << QVideoFrame::Format_AYUV444
        << QVideoFrame::Format_AYUV444_Premultiplied
        << QVideoFrame::Format_YUV444
        << QVideoFrame::Format_YUV420P
        << QVideoFrame::Format_YV12
        << QVideoFrame::Format_UYVY
        << QVideoFrame::Format_YUYV
        << QVideoFrame::Format_NV12
        << QVideoFrame::Format_NV21
        << QVideoFrame::Format_IMC1
        << QVideoFrame::Format_IMC2
        << QVideoFrame::Format_IMC3
        << QVideoFrame::Format_IMC4
        << QVideoFrame::Format_Y8
        << QVideoFrame::Format_Y16
        << QVideoFrame::Format_Jpeg
        << QVideoFrame::Format_CameraRaw
        << QVideoFrame::Format_AdobeDng;
}

bool VideoFrameGrabber::isFormatSupported(const QVideoSurfaceFormat &format) const {
    const QImage::Format imageFormat = QVideoFrame::imageFormatFromPixelFormat(format.pixelFormat());
    const QSize size = format.frameSize();

    return imageFormat != QImage::Format_Invalid
            && !size.isEmpty()
            && format.handleType() == QAbstractVideoBuffer::NoHandle;
}

bool VideoFrameGrabber::start(const QVideoSurfaceFormat &format){
	return QAbstractVideoSurface::start(format);
}

void VideoFrameGrabber::stop() {
    QAbstractVideoSurface::stop();
}

bool VideoFrameGrabber::present(const QVideoFrame &frame){
    if (frame.isValid()) {
        emit frameAvailable(frame.image());
        return true;
    }else
		return false;
}


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
			else if(Utils::isVideo(path)){
				QObject context;
				int mediaStep = 0;
				QMediaPlayer player(&context);
				VideoFrameGrabber grabber(&context);
// Media connections
				QObject::connect(&player, QOverload<QMediaPlayer::Error>::of(&QMediaPlayer::error), &context, [&context, &mediaStep, path](QMediaPlayer::Error error) mutable{
					mediaStep = -1;
				});
				QObject::connect(&player, &QMediaPlayer::mediaStatusChanged, &context, [&context, &player, &mediaStep](QMediaPlayer::MediaStatus status) mutable{
					switch(status){
					case QMediaPlayer::LoadedMedia : if(mediaStep == 0){
							if( player.isVideoAvailable() )
								mediaStep = 1;
							else
								mediaStep = -1;
						}
						break;
					case QMediaPlayer::UnknownMediaStatus:
					case QMediaPlayer::InvalidMedia:
					case QMediaPlayer::EndOfMedia:
						mediaStep = -1;
						break;
					default:{}
					}
				});
				QObject::connect(&grabber, &VideoFrameGrabber::frameAvailable, &context, [&context,&originalImage, &player](QImage frame) mutable{
					originalImage = frame.copy();
					player.stop();
				}, Qt::DirectConnection);
// Processing
				player.setVideoOutput(&grabber);
				player.setMedia(QUrl::fromLocalFile(path));
				do{
					qApp->processEvents();
					if(mediaStep == 1){
						mediaStep = 2;
						player.setPosition(player.duration() / 2);
						player.play();
					}
				}while(mediaStep >= 0 );
			}
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
			Qt::AspectRatioMode aspectRatio = Qt::KeepAspectRatio;
			if(factor < 0.2 || factor > 5)
				aspectRatio = Qt::KeepAspectRatioByExpanding;
			thumbnail = image.scaled(
							Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight,
							aspectRatio , Qt::SmoothTransformation
							);
			if(aspectRatio == Qt::KeepAspectRatioByExpanding)
				thumbnail = thumbnail.copy(0,0,Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight);
				
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
	return thumbnail;
}