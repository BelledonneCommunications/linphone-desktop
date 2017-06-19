/*
 * ImageProvider.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: June 19, 2017
 *      Author: Ronan Abhamon
 */

#include <QFile>
#include <QImage>
#include <QPainter>
#include <QSvgRenderer>
#include <QXmlStreamReader>
#include <QtDebug>

#include "ImageProvider.hpp"

// =============================================================================

const QString ImageProvider::PROVIDER_ID = "internal";

ImageProvider::ImageProvider () : QQuickImageProvider(
    QQmlImageProviderBase::Image,
    QQmlImageProviderBase::ForceAsynchronousImageLoading
  ) {}

QImage ImageProvider::requestImage (const QString &id, QSize *, const QSize &) {
  const QString path = QStringLiteral(":/assets/images/%1").arg(id);

  // 1. Read and update XML content.
  QFile file(path);
  if (!file.open(QIODevice::ReadOnly))
    return QImage(); // Invalid file.

  QString content;
  QXmlStreamReader reader(&file);
  bool soFarSoGood = true;

  while (soFarSoGood && !reader.atEnd())
    switch (reader.readNext()) {
      case QXmlStreamReader::NoToken:
      case QXmlStreamReader::Invalid:
        break;

      case QXmlStreamReader::StartDocument:
      case QXmlStreamReader::EndDocument:
      case QXmlStreamReader::StartElement: {
        QXmlStreamAttributes attributes = reader.attributes();
      } break;
      case QXmlStreamReader::EndElement:
        content.append(QStringLiteral("</%1>").arg(reader.name().toString()));
        break;

      case QXmlStreamReader::Characters:
      case QXmlStreamReader::Comment:
      case QXmlStreamReader::DTD:
      case QXmlStreamReader::EntityReference:
      case QXmlStreamReader::ProcessingInstruction:
        break;
    }

  qDebug() << content;

  if (!soFarSoGood || reader.hasError())
    return QImage(); // Invalid file.

  // 2. Build svg renderer.
  QSvgRenderer renderer(&reader);
  if (!renderer.isValid())
    return QImage(path); // Not a svg file.

  // 3. Create en empty image.
  const QRectF viewBox = renderer.viewBoxF();
  QImage image(static_cast<int>(viewBox.width()), static_cast<int>(viewBox.height()), QImage::Format_ARGB32);
  if (image.isNull())
    return QImage(); // Memory cannot be allocated.
  image.fill(0x00000000);

  // 4. Paint!
  QPainter painter(&image);
  renderer.render(&painter);

  return image;
}
