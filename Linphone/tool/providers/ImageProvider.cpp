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
#include "tool/Utils.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

const QString ImageProvider::ProviderId = "internal";

ImageAsyncImageResponse::ImageAsyncImageResponse(const QString &id, const QSize &requestedSize) {

	QString path = ":/data/image/";
	QStringList filters;
	filters << "*.svg";
	filters << "*.png";
	QDir imageDir(path);
	if (!imageDir.exists()) {
		lDebug() << QStringLiteral("[ImageProvider] Dir doesn't exist: `%1`.").arg(path);
		emit imageGrabbed(QImage(":/data/image/warning-circle.svg"));
		return;
	}
	QFileInfoList files = QDir(path).entryInfoList(filters, QDir::Files, QDir::Name);
	QFileInfo fileInfo;
	for (QFileInfo file : files) {
		if (file.fileName() == id) {
			fileInfo = file;
			mPath = file.absoluteFilePath();
			break;
		}
	}

	QFile file(mPath);

	if (!file.exists()) {
		lDebug() << QStringLiteral("[ImageProvider] File doesn't exist: `%1`.").arg(path + id);
		emit imageGrabbed(QImage(":/data/image/warning-circle.svg"));
		return;
	}

	if (Q_UNLIKELY(!file.open(QIODevice::ReadOnly))) {
		qWarning() << QStringLiteral("[ImageProvider] Unable to open file: `%1`.").arg(path);
		emit imageGrabbed(QImage(":/data/image/warning-circle.svg"));
		return;
	}

	QImage image;

	if (fileInfo.suffix() == "svg") {
		QSvgRenderer renderer(mPath);
		if (Q_UNLIKELY(!renderer.isValid())) {
			qWarning() << QStringLiteral("Invalid svg file: `%1`.").arg(path);
			image = QImage(mPath); // Fallback to QImage
		} else {
			renderer.setAspectRatioMode(Qt::KeepAspectRatio);
			QSize askedSize = !requestedSize.isEmpty()
			                      ? requestedSize
			                      : renderer.defaultSize() * QGuiApplication::primaryScreen()->devicePixelRatio();
			// 3. Create image.
			image = QImage(askedSize, QImage::Format_ARGB32_Premultiplied);
			if (Q_UNLIKELY(image.isNull())) {
				qWarning() << QStringLiteral("Unable to create image from path: `%1`.").arg(path);
				image = QImage(mPath); // Fallback to QImage
			} else {
				image.fill(Qt::transparent); // Fill with transparent to set alpha channel
				// 4. Paint!
				QPainter painter(&image);
				renderer.render(&painter);
			}
		}
	} else image = QImage(mPath);

	if (!image.isNull()) emit imageGrabbed(image);
	else emit imageGrabbed(QImage(":/data/image/warning-circle.svg"));
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
