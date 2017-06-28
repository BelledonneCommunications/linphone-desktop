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

#include <QElapsedTimer>
#include <QFileInfo>
#include <QPainter>
#include <QSvgRenderer>

#include "../App.hpp"

#include "ImageProvider.hpp"

// Max image size in bytes. (100Kb)
#define MAX_IMAGE_SIZE 102400

using namespace std;

// =============================================================================

static void removeAttribute (QXmlStreamAttributes &readerAttributes, const QString &name) {
  auto it = find_if(readerAttributes.cbegin(), readerAttributes.cend(), [&name](const QXmlStreamAttribute &attribute) {
        return name == attribute.name() && !attribute.prefix().length();
      });
  if (it != readerAttributes.cend())
    readerAttributes.remove(static_cast<int>(distance(readerAttributes.cbegin(), it)));
}

static QByteArray buildByteArrayAttribute (const QByteArray &name, const QByteArray &value) {
  QByteArray attribute = name;
  attribute.append("=\"");
  attribute.append(value);
  attribute.append("\" ");
  return attribute;
}

static QByteArray parseFillAndStroke (QXmlStreamAttributes &readerAttributes, const Colors &colors) {
  static QRegExp regex("^color-([^-]+)-(fill|stroke)$");

  QByteArray attributes;

  for (const auto &classValue : readerAttributes.value("class").toLatin1().split(' ')) {
    regex.indexIn(classValue.trimmed());
    if (Q_LIKELY(regex.pos() == -1))
      continue;

    const QStringList list = regex.capturedTexts();

    const QVariant colorValue = colors.property(list[1].toStdString().c_str());
    if (Q_UNLIKELY(!colorValue.isValid())) {
      qWarning() << QStringLiteral("Color name `%1` does not exist.").arg(list[1]);
      continue;
    }

    ::removeAttribute(readerAttributes, list[2]);
    attributes.append(::buildByteArrayAttribute(list[2].toLatin1(), colorValue.value<QColor>().name().toLatin1()));
  }

  return attributes;
}

static QByteArray parseStyle (QXmlStreamAttributes &readerAttributes, const Colors &colors) {
  static QRegExp regex("^color-([^-]+)-style-(fill|stroke)$");

  QByteArray attribute;

  QSet<QString> overrode;
  for (const auto &classValue : readerAttributes.value("class").toLatin1().split(' ')) {
    regex.indexIn(classValue.trimmed());
    if (Q_LIKELY(regex.pos() == -1))
      continue;

    const QStringList list = regex.capturedTexts();

    overrode.insert(list[2]);

    const QVariant colorValue = colors.property(list[1].toStdString().c_str());
    if (Q_UNLIKELY(!colorValue.isValid())) {
      qWarning() << QStringLiteral("Color name `%1` does not exist.").arg(list[1]);
      continue;
    }

    attribute.append(list[2].toLatin1());
    attribute.append(":");
    attribute.append(colorValue.value<QColor>().name().toLatin1());
    attribute.append(";");
  }

  const QByteArrayList styleValues = readerAttributes.value("style").toLatin1().split(';');
  for (const auto &styleValue : styleValues) {
    const QByteArrayList list = styleValue.split(':');
    if (Q_UNLIKELY(list.length() > 0 && !overrode.contains(list[0]))) {
      attribute.append(styleValue);
      attribute.append(";");
    }
  }

  ::removeAttribute(readerAttributes, "style");

  if (attribute.length() > 0) {
    attribute.prepend("style=\"");
    attribute.append("\" ");
  }

  return attribute;
}

static QByteArray parseAttributes (const QXmlStreamReader &reader, const Colors &colors) {
  QXmlStreamAttributes readerAttributes = reader.attributes();

  QByteArray attributes = ::parseFillAndStroke(readerAttributes, colors);
  attributes.append(::parseStyle(readerAttributes, colors));

  for (const auto &attribute : readerAttributes) {
    const QByteArray prefix = attribute.prefix().toLatin1();
    if (Q_UNLIKELY(prefix.length() > 0)) {
      attributes.append(prefix);
      attributes.append(":");
    }

    attributes.append(
      ::buildByteArrayAttribute(attribute.name().toLatin1(), attribute.value().toLatin1())
    );
  }

  return attributes;
}

static QByteArray parseDeclarations (const QXmlStreamReader &reader) {
  QByteArray declarations;
  for (const auto &declaration : reader.namespaceDeclarations()) {
    const QByteArray prefix = declaration.prefix().toLatin1();
    if (Q_UNLIKELY(prefix.length() > 0)) {
      declarations.append("xmlns:");
      declarations.append(prefix);
    } else
      declarations.append("xmlns");

    declarations.append("=\"");
    declarations.append(declaration.namespaceUri().toLatin1());
    declarations.append("\" ");
  }

  return declarations;
}

static QByteArray parseStartDocument (const QXmlStreamReader &reader) {
  QByteArray startDocument = "<?xml version=\"";
  startDocument.append(reader.documentVersion().toLatin1());
  startDocument.append("\" encoding=\"");
  startDocument.append(reader.documentEncoding().toLatin1());
  startDocument.append("\"?>");
  return startDocument;
}

static QByteArray parseStartElement (const QXmlStreamReader &reader, const Colors &colors) {
  QByteArray startElement = "<";
  startElement.append(reader.name().toLatin1());
  startElement.append(" ");
  startElement.append(::parseAttributes(reader, colors));
  startElement.append(" ");
  startElement.append(::parseDeclarations(reader));
  startElement.append(">");
  return startElement;
}

static QByteArray parseEndElement (const QXmlStreamReader &reader) {
  QByteArray endElement = "</";
  endElement.append(reader.name().toLatin1());
  endElement.append(">");
  return endElement;
}

// -----------------------------------------------------------------------------

static QByteArray computeContent (QFile &file) {
  const Colors *colors = App::getInstance()->getColors();

  QByteArray content;
  QXmlStreamReader reader(&file);
  while (!reader.atEnd())
    switch (reader.readNext()) {
      case QXmlStreamReader::Comment:
      case QXmlStreamReader::DTD:
      case QXmlStreamReader::EndDocument:
      case QXmlStreamReader::Invalid:
      case QXmlStreamReader::NoToken:
      case QXmlStreamReader::ProcessingInstruction:
        break;

      case QXmlStreamReader::StartDocument:
        content.append(::parseStartDocument(reader));
        break;

      case QXmlStreamReader::StartElement:
        content.append(::parseStartElement(reader, *colors));
        break;

      case QXmlStreamReader::EndElement:
        content.append(::parseEndElement(reader));
        break;

      case QXmlStreamReader::Characters:
        content.append(reader.text().toLatin1());
        break;

      case QXmlStreamReader::EntityReference:
        content.append(reader.name().toLatin1());
        break;
    }

  return reader.hasError() ? QByteArray() : content;
}

// -----------------------------------------------------------------------------

const QString ImageProvider::PROVIDER_ID = "internal";

ImageProvider::ImageProvider () : QQuickImageProvider(
    QQmlImageProviderBase::Image,
    QQmlImageProviderBase::ForceAsynchronousImageLoading
  ) {}

// -----------------------------------------------------------------------------

QImage ImageProvider::requestImage (const QString &id, QSize *size, const QSize &requestedSize) {
  const QString path = QStringLiteral(":/assets/images/%1").arg(id);
  qInfo() << QStringLiteral("Image `%1` requested.").arg(path);

  QElapsedTimer timer;
  timer.start();

  // 1. Read and update XML content.
  QFile file(path);
  if (Q_UNLIKELY(QFileInfo(file).size() > MAX_IMAGE_SIZE)) {
    qWarning() << QStringLiteral("Unable to open large file: `%1`.").arg(path);
    return QImage();
  }

  if (Q_UNLIKELY(!file.open(QIODevice::ReadOnly))) {
    qWarning() << QStringLiteral("Unable to open file: `%1`.").arg(path);
    return QImage();
  }

  const QByteArray content = ::computeContent(file);
  if (Q_UNLIKELY(!content.length())) {
    qWarning() << QStringLiteral("Unable to parse file: `%1`.").arg(path);
    return QImage();
  }

  // 2. Build svg renderer.
  QSvgRenderer renderer(content);
  if (Q_UNLIKELY(!renderer.isValid())) {
    qWarning() << QStringLiteral("Invalid svg file: `%1`.").arg(path);
    return QImage();
  }

  // 3. Create en empty image.
  const QRectF viewBox = renderer.viewBoxF();
  const int width = requestedSize.width();
  const int height = requestedSize.height();
  QImage image(
    width > 0 ? width : static_cast<int>(viewBox.width()),
    height > 0 ? height : static_cast<int>(viewBox.height()),
    QImage::Format_ARGB32
  );
  if (Q_UNLIKELY(image.isNull())) {
    qWarning() << QStringLiteral("Unable to create image of size `(%1, %2)` from path: `%3`.")
      .arg(viewBox.width()).arg(viewBox.height()).arg(path);
    return QImage(); // Memory cannot be allocated.
  }
  image.fill(0x00000000);

  *size = image.size();

  // 4. Paint!
  QPainter painter(&image);
  renderer.render(&painter);

  qInfo() << QStringLiteral("Image `%1` loaded in %2 milliseconds.").arg(path).arg(timer.elapsed());

  return image;
}
