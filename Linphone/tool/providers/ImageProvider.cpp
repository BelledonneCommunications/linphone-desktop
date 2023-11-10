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

#include <QElapsedTimer>
#include <QFileInfo>
#include <QPainter>
#include <QQmlPropertyMap>
#include <QRegularExpression>
#include <QScreen>
#include <QSvgRenderer>

#include "core/App.hpp"

#include "ImageProvider.hpp"

#include "tool/Constants.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

const QString ImageProvider::ProviderId = "internal";

ImageAsyncImageResponse::ImageAsyncImageResponse(const QString &id, const QSize &requestedSize) {

	QString path = ":/data/image/";
	QStringList filters;
	filters << "*.svg";
	QDir imageDir(path);
	if (!imageDir.exists()) {
		qDebug() << QStringLiteral("[ImageProvider] Dir doesn't exist: `%1`.").arg(path);
		return;
	}
	QFileInfoList files = QDir(path).entryInfoList(filters, QDir::Files, QDir::Name);
	for (QFileInfo file : files) {
		if (file.fileName() == id) {
			mPath = file.absoluteFilePath();
			break;
		}
	}

	QFile file(mPath);

	if (!file.exists()) {
		qDebug() << QStringLiteral("[ImageProvider] File doesn't exist: `%1`.").arg(path + id);
		return;
	}
	QImage originalImage(mPath);

	if (!originalImage.isNull()) {
		emit imageGrabbed(originalImage);
	}
}

void ImageAsyncImageResponse::imageGrabbed(QImage image) {
	mImage = image;
	emit finished();
}

QQuickTextureFactory *ImageAsyncImageResponse::textureFactory() const {
	return QQuickTextureFactory::textureFactoryForImage(mImage);
}
QQuickImageResponse *ImageProvider::requestImageResponse(const QString &id, const QSize &requestedSize) {
	ImageAsyncImageResponse *response = new ImageAsyncImageResponse(id, requestedSize);
	return response;
}
