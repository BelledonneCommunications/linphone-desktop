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

#include "ThumbnailProvider.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/QExifImageHeader.hpp"
#include "tool/Utils.hpp"

#include <QFileInfo>
#include <QImageReader>
#include <QPainter>
#include <QSvgRenderer>

DEFINE_ABSTRACT_OBJECT(ThumbnailAsyncImageResponse)

// =============================================================================

const QString ThumbnailProvider::ProviderId = "thumbnail";

ThumbnailAsyncImageResponse::ThumbnailAsyncImageResponse(const QString &id, const QSize &requestedSize) {
	mPath = id;
	// connect(&mListener, &VideoFrameGrabberListener::imageGrabbed, this, &ThumbnailAsyncImageResponse::imageGrabbed);

	if (QFileInfo(mPath).isFile()) {
		bool removeExportedFile = SettingsModel::getInstance()->getVfsEncrypted();
		if (removeExportedFile) {
			std::shared_ptr<linphone::Content> content =
			    linphone::Factory::get()->createContentFromFile(Utils::appStringToCoreString(mPath));
			mPath = Utils::coreStringToAppString(content->exportPlainFile());
		}
		QImage originalImage(mPath);
		if (originalImage.isNull()) { // Try to determine format from headers
			QImageReader reader(mPath);
			reader.setDecideFormatFromContent(true);
			QByteArray format = reader.format();
			if (!format.isEmpty()) {
				originalImage = QImage(mPath, format);
			} else if (Utils::isVideo(mPath)) {
				originalImage = QImage(mPath);
				// VideoFrameGrabber *grabber = new VideoFrameGrabber(removeExportedFile);
				// removeExportedFile = false;
				// connect(grabber, &VideoFrameGrabber::grabFinished, &mListener,
				//         &VideoFrameGrabberListener::imageGrabbed);
				// grabber->requestFrame(mPath);
			}
		}
		if (removeExportedFile) QFile(mPath).remove();
		if (!originalImage.isNull()) {
			emit imageGrabbed(originalImage);
		}
	}
}

QImage ThumbnailAsyncImageResponse::createThumbnail(const QString &path, QImage originalImage) {
	QImage thumbnail;
	if (!originalImage.isNull()) {
		int rotation = 0;
		QExifImageHeader exifImageHeader;
		if (exifImageHeader.loadFromJpeg(path))
			rotation = int(exifImageHeader.value(QExifImageHeader::ImageTag::Orientation).toShort());
		double factor = originalImage.width() / (double)originalImage.height();
		Qt::AspectRatioMode aspectRatio = Qt::KeepAspectRatio;
		if (factor < 0.2 || factor > 5) aspectRatio = Qt::KeepAspectRatioByExpanding;
		QImageReader reader(path);
		if (reader.format() == "svg") {
			QSvgRenderer svgRenderer(path);
			if (svgRenderer.isValid()) {
				thumbnail = QImage(Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight,
				                   originalImage.format());
				thumbnail.fill(QColor(Qt::transparent));
				QPainter painter(&thumbnail);
				svgRenderer.setAspectRatioMode(aspectRatio);
				svgRenderer.render(&painter);
			}
		}
		if (thumbnail.isNull()) {
			QImage image(originalImage.size(), originalImage.format());
			// Fill with color to replace transparency with white color instead of black (default).
			image.fill(QColor(Qt::white).rgb());
			QPainter painter(&image);
			painter.drawImage(0, 0, originalImage);
			//--------------------
			thumbnail = image.scaled(Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight,
			                         aspectRatio, Qt::SmoothTransformation);
			if (aspectRatio == Qt::KeepAspectRatioByExpanding) // Cut
				thumbnail =
				    thumbnail.copy(0, 0, Constants::ThumbnailImageFileWidth, Constants::ThumbnailImageFileHeight);
		}

		if (rotation != 0) {
			QTransform transform;
			if (rotation == 3 || rotation == 4) transform.rotate(180);
			else if (rotation == 5 || rotation == 6) transform.rotate(90);
			else if (rotation == 7 || rotation == 8) transform.rotate(-90);
			thumbnail = thumbnail.transformed(transform);
			if (rotation == 2 || rotation == 4 || rotation == 5 || rotation == 7)
#if QT_VERSION < QT_VERSION_CHECK(6, 9, 0)
				thumbnail = thumbnail.mirrored(true, false);
#else
				thumbnail = thumbnail.flipped(Qt::Horizontal);
#endif
		}
	}
	return thumbnail;
}

void ThumbnailAsyncImageResponse::imageGrabbed(QImage image) {
	mImage = createThumbnail(mPath, image);
	emit finished();
}

QQuickTextureFactory *ThumbnailAsyncImageResponse::textureFactory() const {
	return QQuickTextureFactory::textureFactoryForImage(mImage);
}
QQuickImageResponse *ThumbnailProvider::requestImageResponse(const QString &id, const QSize &requestedSize) {
	ThumbnailAsyncImageResponse *response = new ThumbnailAsyncImageResponse(id, requestedSize);
	return response;
}