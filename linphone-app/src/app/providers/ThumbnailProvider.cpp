/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "app/paths/Paths.hpp"
#include "components/other/images/ImageModel.hpp"

#include "ThumbnailProvider.hpp"

// =============================================================================

const QString ThumbnailProvider::ProviderId = "thumbnail";

ThumbnailAsyncImageResponse::ThumbnailAsyncImageResponse(const QString &id, const QSize &requestedSize) {
	mPath = id;
	connect(&mListener, &VideoFrameGrabberListener::imageGrabbed, this, &ThumbnailAsyncImageResponse::imageGrabbed);
	ImageModel::retrieveImageAsync(id, &mListener);
}

void ThumbnailAsyncImageResponse::imageGrabbed(QImage image) {
	mImage = ImageModel::createThumbnail(mPath, image);
	emit finished();
}

QQuickTextureFactory *ThumbnailAsyncImageResponse::textureFactory() const {
	return QQuickTextureFactory::textureFactoryForImage(mImage);
}
QQuickImageResponse *ThumbnailProvider::requestImageResponse(const QString &id, const QSize &requestedSize){
	ThumbnailAsyncImageResponse *response = new ThumbnailAsyncImageResponse(id, requestedSize);
	return response;
}