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

#ifndef IMAGE_PROVIDER_H_
#define IMAGE_PROVIDER_H_

#include <QQuickAsyncImageProvider>

// =============================================================================
class ImageAsyncImageResponse : public QQuickImageResponse {
public:
	ImageAsyncImageResponse(const QString &id, const QSize &requestedSize);

	QQuickTextureFactory *textureFactory() const override; // Convert QImage into texture.
	                                                       // If Image is null, then sourceSize will be egal to 0.
	                                                       // So there will be no errors.

	void imageGrabbed(QImage image);

	QImage mImage;
	QString mPath;
};

class ImageProvider : public QQuickAsyncImageProvider {
public:
	virtual QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;

	static const QString ProviderId;
};

#endif // IMAGE_PROVIDER_H_
