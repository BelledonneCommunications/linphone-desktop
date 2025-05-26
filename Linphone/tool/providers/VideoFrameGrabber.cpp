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

#include <QFile>
#include <QVideoFrame>

VideoFrameGrabberListener::VideoFrameGrabberListener() {
}

VideoFrameGrabber::VideoFrameGrabber(bool deleteFile, QObject *parent) : QVideoSink(parent) {
	mDeleteFile = deleteFile;
	mPlayer = new QMediaPlayer();
	mVideoSink = new QVideoSink();
	connect(
	    mPlayer, &QMediaPlayer::errorOccurred, this,
	    [this](QMediaPlayer::Error error, const QString &errorString) { end(); }, Qt::DirectConnection);
	QObject::connect(
	    mPlayer, &QMediaPlayer::mediaStatusChanged, this,
	    [this](QMediaPlayer::MediaStatus status) mutable {
		    switch (status) {
			    case QMediaPlayer::LoadedMedia:
				    if (!mLoadedMedia) {
					    mLoadedMedia = true;
					    if (mPlayer->hasVideo()) {
						    mPlayer->setPosition(mPlayer->duration() / 2);
						    mPlayer->play();
					    } else {
						    end();
					    }
				    }
				    break;
			    case QMediaPlayer::InvalidMedia:
			    case QMediaPlayer::EndOfMedia:
			    case QMediaPlayer::NoMedia:
				    end();
				    break;
			    default: {
			    }
		    }
	    },
	    Qt::DirectConnection);

	connect(mVideoSink, &QVideoSink::videoFrameChanged, this, [this](const QVideoFrame &frame) {
		if (isFormatSupported(frame)) mResult = frame.toImage().copy();
	});

	mPlayer->setVideoSink(mVideoSink);
	mPlayer->setVideoOutput(this);
}

VideoFrameGrabber::~VideoFrameGrabber() {
	if (mDeleteFile) QFile(mPath).remove();
}

void VideoFrameGrabber::requestFrame(const QString &path) {
	mLoadedMedia = false;
	mPath = path;
	// mPlayer->set(QUrl::fromLocalFile(mPath));
}

void VideoFrameGrabber::end() {
	if (mPlayer->mediaStatus() != QMediaPlayer::NoMedia) {
		// mPlayer->setMedia(QUrl());
	} else if (!mResultSent) { // Avoid sending multiple times before destroying the object
		mResultSent = true;
		emit grabFinished(mResult);
		deleteLater();
	}
}

QList<QVideoFrameFormat::PixelFormat> VideoFrameGrabber::supportedPixelFormats() const {
	return QList<QVideoFrameFormat::PixelFormat>()
	       << QVideoFrameFormat::Format_YUV420P << QVideoFrameFormat::Format_YV12 << QVideoFrameFormat::Format_UYVY
	       << QVideoFrameFormat::Format_YUYV << QVideoFrameFormat::Format_NV12 << QVideoFrameFormat::Format_NV21
	       << QVideoFrameFormat::Format_IMC1 << QVideoFrameFormat::Format_IMC2 << QVideoFrameFormat::Format_IMC3
	       << QVideoFrameFormat::Format_IMC4 << QVideoFrameFormat::Format_Y8 << QVideoFrameFormat::Format_Y16
	       << QVideoFrameFormat::Format_Jpeg << QVideoFrameFormat::Format_ABGR8888 << QVideoFrameFormat::Format_ARGB8888
	       << QVideoFrameFormat::Format_ARGB8888_Premultiplied << QVideoFrameFormat::Format_AYUV
	       << QVideoFrameFormat::Format_AYUV_Premultiplied << QVideoFrameFormat::Format_BGRA8888
	       << QVideoFrameFormat::Format_BGRA8888_Premultiplied << QVideoFrameFormat::Format_BGRA8888_Premultiplied
	       << QVideoFrameFormat::Format_BGRX8888;
}

bool VideoFrameGrabber::isFormatSupported(const QVideoFrame &frame) const {
	const QImage::Format imageFormat = QVideoFrameFormat::imageFormatFromPixelFormat(frame.pixelFormat());
	const QSize size = frame.size();

	return imageFormat != QImage::Format_Invalid && !size.isEmpty() &&
	       frame.handleType() == QVideoFrame::HandleType::NoHandle;
}

bool VideoFrameGrabber::start(const QVideoFrameFormat::PixelFormat &format) {
	return true;
	// return QVideoSink::start(format);
}

void VideoFrameGrabber::stop() {
	// QVideoSink::stop();
}