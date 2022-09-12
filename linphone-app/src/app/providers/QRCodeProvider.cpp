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

#include <QElapsedTimer>
#include <QFileInfo>
#include <QPainter>
#include <QScreen>
#include <QSvgRenderer>
#include <QQmlPropertyMap>
#include <QByteArray>
#include <QBuffer>
#include <QImageReader>
#include "app/App.hpp"

#include "QRCodeProvider.hpp"
#include "components/other/colors/ColorListModel.hpp"
#include "components/other/colors/ColorModel.hpp"
#include "components/other/images/ImageListModel.hpp"
#include "components/other/images/ImageModel.hpp"

#include "utils/Constants.hpp"

// =============================================================================

using namespace std;

const QString QRCodeProvider::ProviderId = "qrcode";

QRCodeProvider::QRCodeProvider () : QQuickImageProvider(
									  QQmlImageProviderBase::Image,
									  QQmlImageProviderBase::ForceAsynchronousImageLoading
									  ) {}

// -----------------------------------------------------------------------------

QImage QRCodeProvider::requestImage (const QString &id, QSize *size, const QSize &requestedSize) {
	unsigned int w = requestedSize.width()>0?requestedSize.width() : 100;
	unsigned int h = requestedSize.height()>0 ? requestedSize.height() : 100;
	auto content = linphone::Factory::get()->createQrcode(id.toStdString(), w, h, 0);
	if( !content)
		return QImage();
	QImage image(w, h, QImage::Format_Indexed8);
    for (int y = 0;y<h; y++)
    	memcpy(image.scanLine(y), content->getBuffer() + y*w, w);
	QVector<QRgb> colorTable(256);
    for(int i=0;i<256;i++)
    	colorTable[i] = qRgb(i,i,i);
    image.setColorTable(colorTable);
	*size = image.size();
	return image;
}

QPixmap QRCodeProvider::requestPixmap (const QString &id, QSize *size, const QSize &requestedSize) {
	return QPixmap::fromImage(requestImage(id, size, requestedSize));
}
