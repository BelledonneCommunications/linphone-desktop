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

#ifndef IMAGE_MODEL_H
#define IMAGE_MODEL_H

// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QColor>

#include "utils/LinphoneEnums.hpp"
#include <QAbstractVideoSurface>
#include <QMediaPlayer>

class VideoFrameGrabberListener;

class ImageModel : public QObject {
	Q_OBJECT
	
public:
	ImageModel (const QString& id, const QString& path, const QString& description, QObject * parent = nullptr);
	
	Q_PROPERTY(QString path MEMBER mPath WRITE setPath NOTIFY pathChanged)
	Q_PROPERTY(QString description MEMBER mDescription WRITE setDescription NOTIFY descriptionChanged)
	Q_PROPERTY(QString id MEMBER mId NOTIFY idChanged)
	
	QString getPath() const;
	QString getDescription() const;
	QString getId() const;
	
	void setPath(const QString& path);
	void setDescription(const QString& description);
	Q_INVOKABLE void setUrl(const QUrl& url);
	
	static QImage createThumbnail(const QString& path, QImage originalImage);	// Build the thumbnail from an image.
	static void retrieveImageAsync(const QString& path, VideoFrameGrabberListener* requester);	// Get an image from the path. When it is ready, the signal imageGrabbed() is send to the listener. It can be direct if this is not a media file.
	
signals:
	void pathChanged();
	void descriptionChanged();
	void idChanged();
	
private:
	QString mId;
	QString mPath;
	QString mDescription;
};

Q_DECLARE_METATYPE(std::shared_ptr<ImageModel>);

#endif
