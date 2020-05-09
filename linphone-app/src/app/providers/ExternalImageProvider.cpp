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
#include "utils/Utils.hpp"

#include "ExternalImageProvider.hpp"

#include <QImageReader>

// =============================================================================

const QString ExternalImageProvider::ProviderId = "external";

ExternalImageProvider::ExternalImageProvider () : QQuickImageProvider(
  QQmlImageProviderBase::Image,
  QQmlImageProviderBase::ForceAsynchronousImageLoading
) {
}

QImage ExternalImageProvider::requestImage (const QString &id, QSize *size, const QSize &) {
  QImage image(id);
  if(image.isNull()){// Try to determine format from headers instead of using suffix
	QImageReader reader(id);
	reader.setDecideFormatFromContent(true);
	QByteArray format = reader.format();
	if(!format.isEmpty())
		image = QImage(id, format);
  }
  *size = image.size();
  return image;
}
