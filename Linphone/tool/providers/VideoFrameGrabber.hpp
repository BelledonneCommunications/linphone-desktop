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

#ifndef VIDEO_FRAME_GRABBER_H
#define VIDEO_FRAME_GRABBER_H

#include <QMediaPlayer>
#include <QVideoFrameFormat>
#include <QVideoSink>

// Call VideoFrameGrabber::requestFrame() and wait for imageGrabbed() to get the image.
// You will need to link your listener with connect(grabber, &VideoFrameGrabber::grabFinished, listener,
// &VideoFrameGrabberListener::imageGrabbed);
class VideoFrameGrabberListener : public QObject {
	Q_OBJECT
public:
	VideoFrameGrabberListener();
signals:
	void imageGrabbed(QImage image);
};

class VideoFrameGrabber : public QVideoSink {
	Q_OBJECT
public:
	VideoFrameGrabber(bool deleteFile = false, QObject *parent = 0);
	~VideoFrameGrabber();

	void requestFrame(const QString &path); // Function to call.

	void end();

	QList<QVideoFrameFormat::PixelFormat> supportedPixelFormats() const;
	bool isFormatSupported(const QVideoFrame &frame) const;

	bool start(const QVideoFrameFormat::PixelFormat &format);
	void stop();

	QMediaPlayer *mPlayer = nullptr;
	QVideoSink *mVideoSink = nullptr;
	bool mLoadedMedia = false;
	bool mResultSent = false;
	bool mDeleteFile = false;
	QString mPath;
	QImage mResult;

signals:
	void frameAvailable(QImage frame);
	void grabFinished(QImage frame);
};

#endif
