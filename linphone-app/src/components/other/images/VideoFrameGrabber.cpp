/*
 * Copyright (c) 2023 Belledonne Communications SARL.
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

#include "VideoFrameGrabber.hpp"

#include <QVideoSurfaceFormat>
#include <QFile>

VideoFrameGrabberListener::VideoFrameGrabberListener(){
}

VideoFrameGrabber::VideoFrameGrabber(bool deleteFile, QObject *parent)
	: QAbstractVideoSurface(parent){
	mDeleteFile = deleteFile;
	QObject::connect(&player, QOverload<QMediaPlayer::Error>::of(&QMediaPlayer::error), this, [this](QMediaPlayer::Error error) mutable{
		end();
	}, Qt::DirectConnection);
	QObject::connect(&player, &QMediaPlayer::mediaStatusChanged, this, [this](QMediaPlayer::MediaStatus status) mutable{
		switch(status){
			case QMediaPlayer::LoadedMedia : if(!mLoadedMedia){
					mLoadedMedia = true;
					if( player.isVideoAvailable() ){
						player.setPosition(player.duration() / 2);
						player.play();
					}else{
						end();
					}
				}
				break;
			case QMediaPlayer::UnknownMediaStatus:
			case QMediaPlayer::InvalidMedia:
			case QMediaPlayer::EndOfMedia:
			case QMediaPlayer::NoMedia:
				end();
				break;
			default:{}
		}
	}, Qt::DirectConnection);
	QObject::connect(this, &VideoFrameGrabber::frameAvailable, this, [this](QImage frame) mutable{
		mResult = frame.copy();
		player.setMedia(QUrl());
	}, Qt::DirectConnection);
	
	player.setVideoOutput(this);
}

VideoFrameGrabber::~VideoFrameGrabber(){
	if(mDeleteFile)
		QFile(mPath).remove();
}

void VideoFrameGrabber::requestFrame(const QString& path){
	mLoadedMedia = false;
	mPath = path;
	player.setMedia(QUrl::fromLocalFile(mPath));
}

void VideoFrameGrabber::end(){
	if(player.mediaStatus() != QMediaPlayer::NoMedia){
		player.setMedia(QUrl());
	}else if(!mResultSent){// Avoid sending multiple times before destroying the object
		mResultSent = true;
		emit grabFinished(mResult);
		deleteLater();
	}
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


