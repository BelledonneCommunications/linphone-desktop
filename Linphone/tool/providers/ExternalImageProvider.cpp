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

#include "core/path/Paths.hpp"
#include "tool/Utils.hpp"

#include "ExternalImageProvider.hpp"

#include <QImageReader>

// =============================================================================

const QString ExternalImageProvider::ProviderId = "external";

ExternalImageProvider::ExternalImageProvider()
    : QQuickImageProvider(QQmlImageProviderBase::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading) {
}

QImage ExternalImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
	QImage image(Utils::getImage(QUrl::fromPercentEncoding(id.toUtf8())));
	double requestedFactor = 1.0;
	double factor = image.width() / (double)image.height();
	if (requestedSize.isValid()) requestedFactor = requestedSize.width() / (double)requestedSize.height();
	if (factor < 0.2) { // too height
		image = image.copy(0, 0, image.width(), image.width() / requestedFactor);
	} else if (factor > 5) { // too large
		image = image.copy(0, 0, image.height() * requestedFactor, image.height());
	}
	*size = image.size();
	return image;
}
