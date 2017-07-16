/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt scene graph research project.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

// This file was copied from Qt Extended 4.5

#include <QFile>
#include <QImage>
#include <QDataStream>
#include <QBuffer>
#include <QDateTime>
#include <QtDebug>
#include <QTextCodec>

#include "Utils.hpp"

#include "QExifImageHeader.h"

/*!
    \typedef QExifSRational

    A synonym for \c QPair<qint32,qint32> representing a signed rational number as stored in EXIF
    headers.  The first integer in the pair is the numerator and the second the denominator.
 */

/*!
    \typedef QExifURational

    A synonym for \c QPair<qint32,qint32> representing an unsigned rational number as stored in
    EXIF headers.  The first integer in the pair is the numerator and the second the denominator.
 */

struct ExifIfdHeader {
  quint16 tag;
  quint16 type;
  quint32 count;
  union {
    quint32 offset;
    quint8 offsetBytes[4];
    char offsetAscii[4];
    quint16 offsetShorts[2];
  };
};

QDataStream &operator>> (QDataStream &stream, ExifIfdHeader &header) {
  stream >> header.tag;
  stream >> header.type;
  stream >> header.count;

  if (header.type == QExifValue::Byte && header.count <= 4) {
    stream.readRawData(header.offsetAscii, 4);
  } else if (header.type == QExifValue::Ascii && header.count <= 4) {
    stream.readRawData(header.offsetAscii, 4);
  } else if (header.type == QExifValue::Short && header.count <= 2) {
    stream >> header.offsetShorts[0];
    stream >> header.offsetShorts[1];
  } else {
    stream >> header.offset;
  }

  return stream;
}

class QExifValuePrivate : public QSharedData {
public:
  QExifValuePrivate (quint16 t, int c)
    : type(t), count(c)
  {}

  virtual ~QExifValuePrivate () {}

  quint16 type;
  int count;
};

class QExifByteValuePrivate : public QExifValuePrivate {
public:
  QExifByteValuePrivate ()
    : QExifValuePrivate(QExifValue::Byte, 0) {
    ref.ref();
  }

  QExifByteValuePrivate (const QVector<quint8> &v)
    : QExifValuePrivate(QExifValue::Byte, v.size()), value(v)
  {}

  QVector<quint8> value;
};

class QExifUndefinedValuePrivate : public QExifValuePrivate {
public:
  QExifUndefinedValuePrivate (const QByteArray &v)
    : QExifValuePrivate(QExifValue::Undefined, v.size()), value(v)
  {}

  QByteArray value;
};

class QExifAsciiValuePrivate : public QExifValuePrivate {
public:
  QExifAsciiValuePrivate (const QString &v)
    : QExifValuePrivate(QExifValue::Ascii, v.size() + 1), value(v)
  {}

  QString value;
};

class QExifShortValuePrivate : public QExifValuePrivate {
public:
  QExifShortValuePrivate (const QVector<quint16> &v)
    : QExifValuePrivate(QExifValue::Short, v.size()), value(v)
  {}

  QVector<quint16> value;
};

class QExifLongValuePrivate : public QExifValuePrivate {
public:
  QExifLongValuePrivate (const QVector<quint32> &v)
    : QExifValuePrivate(QExifValue::Long, v.size()), value(v)
  {}

  QVector<quint32> value;
};

class QExifSignedLongValuePrivate : public QExifValuePrivate {
public:
  QExifSignedLongValuePrivate (const QVector<qint32> &v)
    : QExifValuePrivate(QExifValue::SignedLong, v.size()), value(v)
  {}

  QVector<qint32> value;
};

class QExifRationalValuePrivate : public QExifValuePrivate {
public:
  QExifRationalValuePrivate (const QVector<QExifURational> &v)
    : QExifValuePrivate(QExifValue::Rational, v.size()), value(v)
  {}

  QVector<QExifURational> value;
};

class QExifSignedRationalValuePrivate : public QExifValuePrivate {
public:
  QExifSignedRationalValuePrivate (const QVector<QExifSRational> &v)
    : QExifValuePrivate(QExifValue::SignedRational, v.size()), value(v)
  {}

  QVector<QExifSRational> value;
};

Q_GLOBAL_STATIC(QExifByteValuePrivate, qExifValuePrivateSharedNull)

/*!
    \class QExifValue
    \inpublicgroup QtBaseModule
    \brief The QExifValue class represents data types found in EXIF image headers.

    Tag values in EXIF headers are stored as arrays of a limited number of data types. QExifValue
    encapsulates a union of these types and provides conversions to and from appropriate Qt types.

    \section1 String encoding

    Most tags with string values in EXIF headers are ASCII encoded and have the Ascii value type,
    but some tags allow other encodings.  In this case the value type is Undefined and the encoding
    of the text is given by the encoding function().

    \section1 Date-time values

    Date-time values in EXIF headers are stored in ASCII encoded strings of the form
    \c {yyyy:MM:dd HH:mm:ss}.  Constructing a QExifValue from a QDateTime will perform this
    conversion and likewise an appropriately formed QExifValue can be converted to a QDateTime
    using the toDateTime() function.

    \sa QExifImageHeader

    \preliminary
 */

/*!
    \enum QExifValue::Type

    Enumerates the possible types of EXIF values.

    \value Byte An unsigned 8 bit integer.
    \value Ascii A null terminated ascii string.
    \value Short An unsigned 16 bit integer.
    \value Long An unsigned 32 bit integer.
    \value Rational Two unsigned 32 bit integers, representing a the numerator and denominator of an unsigned rational number.
    \value Undefined An array of 8 bit integers.
    \value SignedLong A signed 32 bit integer.
    \value SignedRational Two signed 32 bit integers representing the numerator and denominator of a signed rational number.
 */

/*!
      \enum QExifValue::TextEncoding

      Enumerates the encodings of text strings in EXIF values of Undefined type.

      \value NoEncoding An ASCII string of Ascii type.
      \value AsciiEncoding An ASCII string of Undefined type.
      \value JisEncoding A JIS X208-1990 string of Undefined type.
      \value UnicodeEncoding A Unicode string of Undefined type.
      \value UndefinedEncoding An unspecified string encoding of Undefined type.  Assumed to be the local 8-bit encoding.
 */

/*!
    Constructs a null QExifValue.
 */
QExifValue::QExifValue ()
  : d(qExifValuePrivateSharedNull())
{}

/*!
    Constructs a QExifValue with a \a value of type Byte.
 */
QExifValue::QExifValue (quint8 value)
  : d(new QExifByteValuePrivate(QVector<quint8>(1, value)))
{}

/*!
    Constructs a QExifValue with an array of \a values of type Byte.
 */
QExifValue::QExifValue (const QVector<quint8> &values)
  : d(new QExifByteValuePrivate(values))
{}

/*!
    Constructs a QExifValue with a \a value of type Ascii or Undefined.

    If the \a encoding is NoEncoding the value will be of type Ascii, otherwise it will be Undefined and the string
    encoded using the given \a encoding.
 */
QExifValue::QExifValue (const QString &value, TextEncoding encoding)
  : d(qExifValuePrivateSharedNull()) {
  switch (encoding) {
    case AsciiEncoding:
      d = new QExifUndefinedValuePrivate(QByteArray::fromRawData("ASCII\0\0\0", 8) + value.toUtf8());
      break;
    case JisEncoding: {
      QTextCodec *codec = QTextCodec::codecForName("JIS X 0208");
      if (codec)
        d = new QExifUndefinedValuePrivate(QByteArray::fromRawData("JIS\0\0\0\0\0", 8) + codec->fromUnicode(value));
    }
                      break;
    case UnicodeEncoding: {
      QTextCodec *codec = QTextCodec::codecForName("UTF-16");
      if (codec)
        d = new QExifUndefinedValuePrivate(QByteArray::fromRawData("UNICODE\0", 8) + codec->fromUnicode(value));
    }
                          break;
    case UndefinedEncoding:
      d = new QExifUndefinedValuePrivate(QByteArray::fromRawData("\0\0\0\0\0\0\0\\0", 8) + value.toLocal8Bit());
      break;
    default:
      d = new QExifAsciiValuePrivate(value);
  }
}

/*!
    Constructs a QExifValue with a \a value of type Short.
 */
QExifValue::QExifValue (quint16 value)
  : d(new QExifShortValuePrivate(QVector<quint16>(1, value)))
{}

/*!
    Constructs a QExifValue with an array of \a values of type Short.
 */
QExifValue::QExifValue (const QVector<quint16> &values)
  : d(new QExifShortValuePrivate(values))
{}

/*!
    Constructs a QExifValue with a \a value of type Long.
 */
QExifValue::QExifValue (quint32 value)
  : d(new QExifLongValuePrivate(QVector<quint32>(1, value)))
{}

/*!
    Constructs a QExifValue with an array of \a values of type Long.
 */
QExifValue::QExifValue (const QVector<quint32> &values)
  : d(new QExifLongValuePrivate(values))
{}

/*!
    Constructs a QExifValue with a \a value of type Rational.
 */
QExifValue::QExifValue (const QExifURational &value)
  : d(new QExifRationalValuePrivate(QVector<QExifURational>(1, value)))
{}

/*!
    Constructs a QExifValue with an array of \a values of type Rational.
 */
QExifValue::QExifValue (const QVector<QExifURational> &values)
  : d(new QExifRationalValuePrivate(values))
{}

/*!
    Constructs a QExifValue with a \a value of type Undefined.
 */
QExifValue::QExifValue (const QByteArray &value)
  : d(new QExifUndefinedValuePrivate(value))
{}

/*!
    Constructs a QExifValue with a \a value of type SignedLong.
 */
QExifValue::QExifValue (qint32 value)
  : d(new QExifSignedLongValuePrivate(QVector<qint32>(1, value)))
{}

/*!
    Constructs a QExifValue with an array of \a values of type SignedLong.
 */
QExifValue::QExifValue (const QVector<qint32> &values)
  : d(new QExifSignedLongValuePrivate(values))
{}

/*!
    Constructs a QExifValue with a \a value of type SignedRational.
 */
QExifValue::QExifValue (const QExifSRational &value)
  : d(new QExifSignedRationalValuePrivate(QVector<QExifSRational>(1, value)))
{}

/*!
    Constructs a QExifValue with an array of \a values of type SignedRational.
 */
QExifValue::QExifValue (const QVector<QExifSRational> &values)
  : d(new QExifSignedRationalValuePrivate(values))
{}

/*!
    Constructs a QExifValue of type Ascii with an ascii string formatted from a date-time \a value.

    Date-times are stored as strings in the format \c {yyyy:MM:dd HH:mm:ss}.
 */
QExifValue::QExifValue (const QDateTime &value)
  : d(new QExifAsciiValuePrivate(value.toString(QLatin1String("yyyy:MM:dd HH:mm:ss"))))
{}

/*!
    Constructs a copy of the QExifValue \a other.
 */
QExifValue::QExifValue (const QExifValue &other)
  : d(other.d)
{}

/*!
    Assigns the value of \a other to a QExifValue.
 */
QExifValue &QExifValue::operator= (const QExifValue &other) {
  d = other.d;

  return *this;
}

/*!
    Destroys a QExifValue.
 */
QExifValue::~QExifValue ()
{}

/*!
    Compares a QExifValue to \a other.  Returns true if they are the same value and false otherwise.
 */
bool QExifValue::operator== (const QExifValue &other) const {
  return d == other.d;
}

/*!
    Returns true if a QExifValue has a null value and false otherwise.
 */
bool QExifValue::isNull () const {
  return d == qExifValuePrivateSharedNull();
}

/*!
    Returns the type of a QExifValue.
 */
int QExifValue::type () const {
  return d->type;
}

/*!
    Returns the number of elements in a QExifValue.  For ascii strings this is the length of the string
    including the terminating null.
 */
int QExifValue::count () const {
  return d->count;
}

/*!
      Returns the encoding of strings stored in Undefined values.
 */
QExifValue::TextEncoding QExifValue::encoding () const {
  if (d->type == Undefined && d->count > 8) {
    QByteArray value = static_cast<const QExifUndefinedValuePrivate *>(d.constData())->value;

    if (value.startsWith(QByteArray::fromRawData("ASCII\0\0\0", 8)))
      return AsciiEncoding;
    else if (value.startsWith(QByteArray::fromRawData("JIS\0\0\0\0\0", 8)))
      return JisEncoding;
    else if (value.startsWith(QByteArray::fromRawData("UNICODE\0", 8)))
      return UnicodeEncoding;
    else if (value.startsWith(QByteArray::fromRawData("\0\0\0\0\0\0\0\0", 8)))
      return UndefinedEncoding;
  }
  return NoEncoding;
}

/*!
    Returns the value of a single element QExifValue of type Byte.
 */
quint8 QExifValue::toByte () const {
  return d->type == Byte && d->count == 1
         ? static_cast<const QExifByteValuePrivate *>(d.constData())->value.at(0)
         : 0;
}

/*!
    Returns the value of a multiple element QExifValue of type Byte.
 */
QVector<quint8> QExifValue::toByteVector () const {
  return d->type == Byte
         ? static_cast<const QExifByteValuePrivate *>(d.constData())->value
         : QVector<quint8>();
}

/*!
    Returns the value of a QExifValue of type Ascii.
 */
QString QExifValue::toString () const {
  switch (d->type) {
    case Ascii:
      return static_cast<const QExifAsciiValuePrivate *>(d.constData())->value;
    case Undefined: {
      QByteArray string = static_cast<const QExifUndefinedValuePrivate *>(d.constData())->value.mid(8);

      switch (encoding()) {
        case AsciiEncoding:
          return QString::fromUtf8(string.constData(), string.length());
        case JisEncoding: {
          QTextCodec *codec = QTextCodec::codecForName("JIS X 0208");
          if (codec)
            return codec->toUnicode(string);
        } break;
        case UnicodeEncoding: {
          QTextCodec *codec = QTextCodec::codecForName("UTF-16");
          if (codec)
            return codec->toUnicode(string);
        } UTILS_NO_BREAK;
        case UndefinedEncoding:
          return QString::fromLocal8Bit(string.constData(), string.length());
        default:
          break;
      }
    } UTILS_NO_BREAK;
    default:
      return QString();
  }
}

/*!
    Returns the value of a single element QExifValue of type Byte or Short.
 */
quint16 QExifValue::toShort () const {
  if (d->count == 1) {
    switch (d->type) {
      case Byte:
        return static_cast<const QExifByteValuePrivate *>(d.constData())->value.at(0);
      case Short:
        return static_cast<const QExifShortValuePrivate *>(d.constData())->value.at(0);
    }
  }
  return 0;
}

/*!
    Returns the value of a single element QExifValue of type Short.
 */
QVector<quint16> QExifValue::toShortVector () const {
  return d->type == Short
         ? static_cast<const QExifShortValuePrivate *>(d.constData())->value
         : QVector<quint16>();
}

/*!
    Returns the value of a single element QExifValue of type Byte, Short, Long, or SignedLong.
 */
quint32 QExifValue::toLong () const {
  if (d->count == 1) {
    switch (d->type) {
      case Byte:
        return static_cast<const QExifByteValuePrivate *>(d.constData())->value.at(0);
      case Short:
        return static_cast<const QExifShortValuePrivate *>(d.constData())->value.at(0);
      case Long:
        return static_cast<const QExifLongValuePrivate *>(d.constData())->value.at(0);
      case SignedLong:
        return static_cast<const QExifSignedLongValuePrivate *>(d.constData())->value.at(0);
    }
  }
  return 0;
}

/*!
    Returns the value of a multiple element QExifValue of type Long.
 */
QVector<quint32> QExifValue::toLongVector () const {
  return d->type == Long
         ? static_cast<const QExifLongValuePrivate *>(d.constData())->value
         : QVector<quint32>();
}

/*!
    Returns the value of a multiple element QExifValue of type Rational.
 */
QExifURational QExifValue::toRational () const {
  return d->type == Rational && d->count == 1
         ? static_cast<const QExifRationalValuePrivate *>(d.constData())->value.at(0)
         : QExifURational();
}

/*!
    Returns the value of a multiple element QExifValue of type Rational.
 */
QVector<QExifURational> QExifValue::toRationalVector () const {
  return d->type == Rational
         ? static_cast<const QExifRationalValuePrivate *>(d.constData())->value
         : QVector<QExifURational>();
}

/*!
    Returns the value of a QExifValue of type Undefined.
 */
QByteArray QExifValue::toByteArray () const {
  switch (d->type) {
    case Ascii:
      return static_cast<const QExifAsciiValuePrivate *>(d.constData())->value.toUtf8();
    case Undefined:
      return static_cast<const QExifUndefinedValuePrivate *>(d.constData())->value;
    default:
      return QByteArray();
  }
}

/*!
    Returns the value of a single element QExifValue of type Byte, Short, Long, or SignedLong.
 */
qint32 QExifValue::toSignedLong () const {
  if (d->count == 1) {
    switch (d->type) {
      case Byte:
        return static_cast<const QExifByteValuePrivate *>(d.constData())->value.at(0);
      case Short:
        return static_cast<const QExifShortValuePrivate *>(d.constData())->value.at(0);
      case Long:
        return static_cast<const QExifLongValuePrivate *>(d.constData())->value.at(0);
      case SignedLong:
        return static_cast<const QExifSignedLongValuePrivate *>(d.constData())->value.at(0);
    }
  }
  return 0;
}

/*!
    Returns the value of a multiple element QExifValue of type SignedLong.
 */
QVector<qint32> QExifValue::toSignedLongVector () const {
  return d->type == SignedLong
         ? static_cast<const QExifSignedLongValuePrivate *>(d.constData())->value
         : QVector<qint32>();
}

/*!
    Returns the value of a single element QExifValue of type SignedRational.
 */
QExifSRational QExifValue::toSignedRational () const {
  return d->type == SignedRational && d->count == 1
         ? static_cast<const QExifSignedRationalValuePrivate *>(d.constData())->value.at(0)
         : QExifSRational();
}

/*!
    Returns the value of a multiple element QExifValue of type SignedRational.
 */
QVector<QExifSRational> QExifValue::toSignedRationalVector () const {
  return d->type == SignedRational
         ? static_cast<const QExifSignedRationalValuePrivate *>(d.constData())->value
         : QVector<QExifSRational>();
}

/*!
    Returns the value of QExifValue storing a date-time.

    Date-times are stored as ascii strings in the format \c {yyyy:MM:dd HH:mm:ss}.
 */
QDateTime QExifValue::toDateTime () const {
  return d->type == Ascii && d->count == 20
         ? QDateTime::fromString(static_cast<const QExifAsciiValuePrivate *>(d.constData())->value, QLatin1String("yyyy:MM:dd HH:mm:ss"))
         : QDateTime();
}

class QExifImageHeaderPrivate {
public:
  QSysInfo::Endian byteOrder;
  mutable qint64 size;
  QMap<QExifImageHeader::ImageTag, QExifValue> imageIfdValues;
  QMap<QExifImageHeader::ExifExtendedTag, QExifValue> exifIfdValues;
  QMap<QExifImageHeader::GpsTag, QExifValue> gpsIfdValues;

  QSize thumbnailSize;
  QByteArray thumbnailData;
  QExifValue thumbnailXResolution;
  QExifValue thumbnailYResolution;
  QExifValue thumbnailResolutionUnit;
  QExifValue thumbnailOrientation;
};

/*!
    \class QExifImageHeader
    \inpublicgroup QtBaseModule
    \brief The QExifImageHeader class provides functionality for reading and writing EXIF image headers.

    EXIF headers are a collection of properties that describe the image they're embedded in.
    Each property is identified by a tag of which there are three kinds.  \l {ImageTag}{Image tags}
    which mostly describe the format (dimensions, resolution, orientation) but also include some
    descriptive information (description, camera make and model, artist).  \l {ExifExtendedTag}
    {EXIF extended tags} which elaborate on some of the image tags and record the camera settings at
    time of capture among other things.  Finally there are \l {GpsTag}{GPS tags} which record the
    location the image was captured.

    EXIF tags are typically found in JPEG images but may be found in other image formats.  To read
    headers from a JPEG image QExifImageHeader provides the loadFromJpeg() function, and the
    complementary saveToJpeg() function for writing.  To allow reading and writing arbitrary
    formats QExifImageHeader provides the read() and write() functions which work with just the
    EXIF header data itself.

    \preliminary
 */

/*!
    \enum QExifImageHeader::ImageTag
    Enumerates the TIFF image tag IDs defined in the EXIF specification.

    \value ImageWidth
    \value ImageLength
    \value BitsPerSample
    \value Compression
    \value PhotometricInterpretation
    \value Orientation
    \value SamplesPerPixel
    \value PlanarConfiguration
    \value YCbCrSubSampling
    \value XResolution
    \value YResolution
    \value ResolutionUnit
    \value StripOffsets
    \value RowsPerStrip
    \value StripByteCounts
    \value TransferFunction
    \value WhitePoint
    \value PrimaryChromaciticies
    \value YCbCrCoefficients
    \value ReferenceBlackWhite
    \value DateTime
    \value ImageDescription
    \value Make
    \value Model
    \value Software
    \value Artist
    \value Copyright
 */

/*!
    \enum QExifImageHeader::ExifExtendedTag
    Enumerates the extended EXIF tag IDs defined in the EXIF specification.

    \value ExifVersion
    \value FlashPixVersion
    \value ColorSpace
    \value ComponentsConfiguration
    \value CompressedBitsPerPixel
    \value PixelXDimension
    \value PixelYDimension
    \value MakerNote
    \value UserComment
    \value RelatedSoundFile
    \value DateTimeOriginal
    \value DateTimeDigitized
    \value SubSecTime
    \value SubSecTimeOriginal
    \value SubSecTimeDigitized
    \value ImageUniqueId
    \value ExposureTime
    \value FNumber
    \value ExposureProgram
    \value SpectralSensitivity
    \value ISOSpeedRatings
    \value Oecf
    \value ShutterSpeedValue
    \value ApertureValue
    \value BrightnessValue
    \value ExposureBiasValue
    \value MaxApertureValue
    \value SubjectDistance
    \value MeteringMode
    \value LightSource
    \value Flash
    \value FocalLength
    \value SubjectArea
    \value FlashEnergy
    \value SpatialFrequencyResponse
    \value FocalPlaneXResolution
    \value FocalPlaneYResolution
    \value FocalPlaneResolutionUnit
    \value SubjectLocation
    \value ExposureIndex
    \value SensingMethod
    \value FileSource
    \value SceneType
    \value CfaPattern
    \value CustomRendered
    \value ExposureMode
    \value WhiteBalance
    \value DigitalZoomRatio
    \value FocalLengthIn35mmFilm
    \value SceneCaptureType
    \value GainControl
    \value Contrast
    \value Saturation
    \value Sharpness
    \value DeviceSettingDescription
    \value SubjectDistanceRange
 */

/*!
    \enum QExifImageHeader::GpsTag
    Enumerates the GPS tag IDs from the EXIF specification.

    \value GpsVersionId
    \value GpsLatitudeRef
    \value GpsLatitude
    \value GpsLongitudeRef
    \value GpsLongitude
    \value GpsAltitudeRef
    \value GpsAltitude
    \value GpsTimeStamp
    \value GpsSatellites
    \value GpsStatus
    \value GpsMeasureMode
    \value GpsDop
    \value GpsSpeedRef
    \value GpsSpeed
    \value GpsTrackRef
    \value GpsTrack
    \value GpsImageDirectionRef
    \value GpsImageDirection
    \value GpsMapDatum
    \value GpsDestLatitudeRef
    \value GpsDestLatitude
    \value GpsDestLongitudeRef
    \value GpsDestLongitude
    \value GpsDestBearingRef
    \value GpsDestBearing
    \value GpsDestDistanceRef
    \value GpsDestDistance
    \value GpsProcessingMethod
    \value GpsAreaInformation
    \value GpsDateStamp
    \value GpsDifferential
 */

/*!
    Constructs a new EXIF image data editor.
 */
QExifImageHeader::QExifImageHeader ()
  : d(new QExifImageHeaderPrivate) {
  d->byteOrder = QSysInfo::ByteOrder;
  d->size = -1;
}

/*!
    Constructs a new EXIF image data editor and reads the meta-data from a JPEG image with the given \a fileName.
 */
QExifImageHeader::QExifImageHeader (const QString &fileName)
  : d(new QExifImageHeaderPrivate) {
  d->byteOrder = QSysInfo::ByteOrder;
  d->size = -1;

  loadFromJpeg(fileName);
}

/*!
    Destroys an EXIF image data editor.
 */
QExifImageHeader::~QExifImageHeader () {
  clear();

  delete d;
}

/*!
    Reads meta-data from a JPEG image with the given \a fileName.

    Returns true if the data was successfully parsed and false otherwise.
 */
bool QExifImageHeader::loadFromJpeg (const QString &fileName) {
  QFile file(fileName);

  if (file.open(QIODevice::ReadOnly))
    return loadFromJpeg(&file);
  else
    return false;
}

/*!
    Reads meta-data from an I/O \a device containing a JPEG image.

    Returns true if the data was successfully parsed and false otherwise.
 */
bool QExifImageHeader::loadFromJpeg (QIODevice *device) {
  clear();

  QByteArray exifData = extractExif(device);

  if (!exifData.isEmpty()) {
    QBuffer buffer(&exifData);

    return buffer.open(QIODevice::ReadOnly) && read(&buffer);
  }

  return false;
}

/*!
    Saves meta-data to a JPEG image with the given \a fileName.

    Returns true if the data was successfully written.
 */
bool QExifImageHeader::saveToJpeg (const QString &fileName) const {
  QFile file(fileName);

  if (file.open(QIODevice::ReadWrite))
    return saveToJpeg(&file);
  else
    return false;
}

/*!
    Save meta-data to the given I/O \a device.

    The device must be non-sequential and already contain a valid JPEG image.

    Returns true if the data was successfully written.
 */
bool QExifImageHeader::saveToJpeg (QIODevice *device) const {
  if (device->isSequential())
    return false;

  QByteArray exif;

  {
    QBuffer buffer(&exif);

    if (!buffer.open(QIODevice::WriteOnly))
      return false;

    write(&buffer);

    buffer.close();

    exif = QByteArray::fromRawData("Exif\0\0", 6) + exif;
  }

  QDataStream stream(device);

  stream.setByteOrder(QDataStream::BigEndian);

  if (device->read(2) != "\xFF\xD8")         // Not a valid JPEG image.
    return false;

  quint16 segmentId;
  quint16 segmentLength;

  stream >> segmentId;
  stream >> segmentLength;

  if (segmentId == 0xFFE0) {
    QByteArray jfif = device->read(segmentLength - 2);

    if (!jfif.startsWith("JFIF"))
      return false;

    stream >> segmentId;
    stream >> segmentLength;

    if (segmentId == 0xFFE1) {
      QByteArray oldExif = device->read(segmentLength - 2);

      if (!oldExif.startsWith("Exif"))
        return false;

      int dSize = oldExif.size() - exif.size();

      if (dSize > 0)
        exif += QByteArray(dSize, '\0');

      QByteArray remainder = device->readAll();

      device->seek(0);

      stream << quint16(0xFFD8);         // SOI
      stream << quint16(0xFFE0);         // APP0
      stream << quint16(jfif.size() + 2);
      device->write(jfif);
      stream << quint16(0xFFE1);         // APP1
      stream << quint16(exif.size() + 2);
      device->write(exif);
      device->write(remainder);
    } else {
      QByteArray remainder = device->readAll();

      device->seek(0);

      stream << quint16(0xFFD8);         // SOI
      stream << quint16(0xFFE0);         // APP0
      stream << quint16(jfif.size() + 2);
      device->write(jfif);
      stream << quint16(0xFFE1);         // APP1
      stream << quint16(exif.size() + 2);
      device->write(exif);
      stream << quint16(0xFFE0);         // APP0
      stream << segmentId;
      stream << segmentLength;
      device->write(remainder);
    }
  } else if (segmentId == 0xFFE1) {
    QByteArray oldExif = device->read(segmentLength - 2);

    if (!oldExif.startsWith("Exif"))
      return false;

    int dSize = oldExif.size() - exif.size();

    if (dSize > 0)
      exif += QByteArray(dSize, '\0');

    QByteArray remainder = device->readAll();

    device->seek(0);

    stream << quint16(0xFFD8);       // SOI
    stream << quint16(0xFFE1);       // APP1
    stream << quint16(exif.size() + 2);
    device->write(exif);
    device->write(remainder);
  } else {
    QByteArray remainder = device->readAll();

    device->seek(0);

    stream << quint16(0xFFD8);       // SOI
    stream << quint16(0xFFE1);       // APP1
    stream << quint16(exif.size() + 2);
    device->write(exif);
    stream << segmentId;
    stream << segmentLength;
    device->write(remainder);
  }

  return true;
}

/*!
    Returns the byte order of EXIF file.
 */
QSysInfo::Endian QExifImageHeader::byteOrder () const {
  return d->byteOrder;
}

quint32 QExifImageHeader::sizeOf (const QExifValue &value) const {
  switch (value.type()) {
    case QExifValue::Byte:
    case QExifValue::Undefined:
      return value.count() > 4 ? 12 + value.count() : 12;
    case QExifValue::Ascii:
      return value.count() > 4 ? 12 + value.count() : 12;
    case QExifValue::Short:
      return value.count() > 2 ? static_cast<quint32>(12 + value.count() * sizeof(quint16)) : 12;
    case QExifValue::Long:
    case QExifValue::SignedLong:
      return value.count() > 1 ? static_cast<quint32>(12 + value.count() * sizeof(quint32)) : 12;
    case QExifValue::Rational:
    case QExifValue::SignedRational:
      return value.count() > 0 ? static_cast<quint32>(12 + value.count() * sizeof(quint32) * 2) : 12;
    default:
      return 0;
  }
}

template<typename T>
quint32 QExifImageHeader::calculateSize (const QMap<T, QExifValue> &values) const {
  quint32 size = sizeof(quint16);

  foreach(const QExifValue &value, values)
  size += sizeOf(value);

  return size;
}

/*!
    Returns the size of EXIF data in bytes.
 */
qint64 QExifImageHeader::size () const {
  if (d->size == -1) {
    d->size = 2 +                                      // Byte Order
      2 +                                              // Marker
      4 +                                              // Image Ifd offset
      12 +                                             // ExifIfdPointer Ifd
      4 +                                              // Thumbnail Ifd offset
      calculateSize(d->imageIfdValues) +               // Image headers and values.
      calculateSize(d->exifIfdValues);                 // Exif headers and values.

    if (!d->gpsIfdValues.isEmpty()) {
      d->size += 12 +                                  // GpsInfoIfdPointer Ifd
        calculateSize(d->gpsIfdValues);                // Gps headers and values.
    }

    if (!d->thumbnailData.isEmpty()) {
      d->size += 2 +                                   // Thumbnail Ifd count
        12 +                                           // Compression Ifd
        20 +                                           // XResolution Ifd
        20 +                                           // YResolution Ifd
        12 +                                           // ResolutionUnit Ifd
        12 +                                           // JpegInterchangeFormat Ifd
        12 +                                           // JpegInterchangeFormatLength Ifd
        d->thumbnailData.size();                       // Thumbnail data size.
    }
  }

  return d->size;
}

/*!
    Clears all image meta-data.
 */
void QExifImageHeader::clear () {
  d->imageIfdValues.clear();
  d->exifIfdValues.clear();
  d->gpsIfdValues.clear();
  d->thumbnailData.clear();

  d->size = -1;
}

/*!
    Returns a list of all image tags in an EXIF header.
 */
QList<QExifImageHeader::ImageTag> QExifImageHeader::imageTags () const {
  return d->imageIfdValues.keys();
}

/*!
    Returns a list of all extended EXIF tags in a header.
 */
QList<QExifImageHeader::ExifExtendedTag> QExifImageHeader::extendedTags () const {
  return d->exifIfdValues.keys();
}

/*!
    Returns a list of all GPS tags in an EXIF header.
 */
QList<QExifImageHeader::GpsTag> QExifImageHeader::gpsTags () const {
  return d->gpsIfdValues.keys();
}

/*!
    Returns true if an EXIf header contains a value for an image \a tag and false otherwise.
 */
bool QExifImageHeader::contains (ImageTag tag) const {
  return d->imageIfdValues.contains(tag);
}

/*!
    Returns true if a header contains a a value for an extended EXIF \a tag and false otherwise.
 */
bool QExifImageHeader::contains (ExifExtendedTag tag) const {
  return d->exifIfdValues.contains(tag);
}

/*!
    Returns true if an EXIf header contains a value for a GPS \a tag and false otherwise.
 */
bool QExifImageHeader::contains (GpsTag tag) const {
  return d->gpsIfdValues.contains(tag);
}

/*!
    Removes the value for an image \a tag.
 */
void QExifImageHeader::remove (ImageTag tag) {
  d->imageIfdValues.remove(tag);

  d->size = -1;
}

/*!
    Removes the value for an extended EXIF \a tag.
 */
void QExifImageHeader::remove (ExifExtendedTag tag) {
  d->exifIfdValues.remove(tag);

  d->size = -1;
}

/*!
    Removes the value for a GPS \a tag.
 */
void QExifImageHeader::remove (GpsTag tag) {
  d->gpsIfdValues.remove(tag);

  d->size = -1;
}

/*!
    Returns the value for an image \a tag.
 */
QExifValue QExifImageHeader::value (ImageTag tag) const {
  return d->imageIfdValues.value(tag);
}

/*!
    Returns the value for an extended EXIF \a tag.
 */
QExifValue QExifImageHeader::value (ExifExtendedTag tag) const {
  return d->exifIfdValues.value(tag);
}

/*!
    Returns the value for a GPS tag.
 */
QExifValue QExifImageHeader::value (GpsTag tag) const {
  return d->gpsIfdValues.value(tag);
}

/*!
    Sets the \a value for an image \a tag.
 */
void QExifImageHeader::setValue (ImageTag tag, const QExifValue &value) {
  d->imageIfdValues[tag] = value;

  d->size = -1;
}

/*!
    Sets the \a value for an extended EXIF \a tag.
 */
void QExifImageHeader::setValue (ExifExtendedTag tag, const QExifValue &value) {
  d->exifIfdValues[tag] = value;

  d->size = -1;
}

/*!
    Sets the \a value for an GPS \a tag.
 */
void QExifImageHeader::setValue (GpsTag tag, const QExifValue &value) {
  d->gpsIfdValues[tag] = value;

  d->size = -1;
}

/*!
    Returns the image thumbnail.
 */
QImage QExifImageHeader::thumbnail () const {
  QImage image;

  image.loadFromData(d->thumbnailData, "JPG");

  if (!d->thumbnailOrientation.isNull()) {
    switch (d->thumbnailOrientation.toShort()) {
      case 1:
        return image;
      case 2:
        return image.transformed(QTransform().rotate(180, Qt::YAxis));
      case 3:
        return image.transformed(QTransform().rotate(180, Qt::ZAxis));
      case 4:
        return image.transformed(QTransform().rotate(180, Qt::XAxis));
      case 5:
        return image.transformed(QTransform().rotate(180, Qt::YAxis).rotate(90, Qt::ZAxis));
      case 6:
        return image.transformed(QTransform().rotate(90, Qt::ZAxis));
      case 7:
        return image.transformed(QTransform().rotate(180, Qt::XAxis).rotate(90, Qt::ZAxis));
      case 8:
        return image.transformed(QTransform().rotate(270, Qt::ZAxis));
    }
  }

  return image;
}

/*!
    Sets the image \a thumbnail.
 */
void QExifImageHeader::setThumbnail (const QImage &thumbnail) {
  if (!thumbnail.isNull()) {
    QBuffer buffer;

    if (buffer.open(QIODevice::WriteOnly) && thumbnail.save(&buffer, "JPG")) {
      buffer.close();

      d->thumbnailSize = thumbnail.size();
      d->thumbnailData = buffer.data();
      d->thumbnailOrientation = QExifValue();
    }
  } else {
    d->thumbnailSize = QSize();
    d->thumbnailData = QByteArray();
  }

  d->size = -1;
}

QByteArray QExifImageHeader::extractExif (QIODevice *device) const {
  QDataStream stream(device);

  stream.setByteOrder(QDataStream::BigEndian);

  if (device->read(2) != "\xFF\xD8")
    return QByteArray();

  while (device->read(2) != "\xFF\xE1") {
    if (device->atEnd())
      return QByteArray();

    quint16 length;

    stream >> length;

    device->seek(device->pos() + length - 2);
  }

  quint16 length;

  stream >> length;

  if (device->read(4) != "Exif")
    return QByteArray();

  device->read(2);

  return device->read(length - 8);
}

QList<ExifIfdHeader> QExifImageHeader::readIfdHeaders (QDataStream &stream) const {
  QList<ExifIfdHeader> headers;

  quint16 count;

  stream >> count;

  for (quint16 i = 0; i < count; i++) {
    ExifIfdHeader header;

    stream >> header;

    headers.append(header);
  }

  return headers;
}

QExifValue QExifImageHeader::readIfdValue (QDataStream &stream, int startPos, const ExifIfdHeader &header) const {
  switch (header.type) {
    case QExifValue::Byte: {
      QVector<quint8> value(header.count);

      if (header.count > 4) {
        stream.device()->seek(startPos + header.offset);

        for (quint32 i = 0; i < header.count; i++)
          stream >> value[i];
      } else {
        for (quint32 i = 0; i < header.count; i++)
          value[i] = header.offsetBytes[i];
      }
      return QExifValue(value);
    }
    case QExifValue::Undefined:
      if (header.count > 4) {
        stream.device()->seek(startPos + header.offset);

        return QExifValue(stream.device()->read(header.count));
      } else {
        return QExifValue(QByteArray::fromRawData(header.offsetAscii, header.count));
      }
    case QExifValue::Ascii:
      if (header.count > 4) {
        stream.device()->seek(startPos + header.offset);

        QByteArray ascii = stream.device()->read(header.count);

        return QExifValue(QString::fromUtf8(ascii.constData(), ascii.size() - 1));
      } else {
        return QExifValue(QString::fromUtf8(header.offsetAscii, header.count - 1));
      }
    case QExifValue::Short: {
      QVector<quint16> value(header.count);

      if (header.count > 2) {
        stream.device()->seek(startPos + header.offset);

        for (quint32 i = 0; i < header.count; i++)
          stream >> value[i];
      } else {
        for (quint32 i = 0; i < header.count; i++)
          value[i] = header.offsetShorts[i];
      }
      return QExifValue(value);
    }
    case QExifValue::Long: {
      QVector<quint32> value(header.count);

      if (header.count > 1) {
        stream.device()->seek(startPos + header.offset);

        for (quint32 i = 0; i < header.count; i++)
          stream >> value[i];
      } else if (header.count == 1) {
        value[0] = header.offset;
      }
      return QExifValue(value);
    }
    case QExifValue::SignedLong: {
      QVector<qint32> value(header.count);

      if (header.count > 1) {
        stream.device()->seek(startPos + header.offset);

        for (quint32 i = 0; i < header.count; i++)
          stream >> value[i];
      } else if (header.count == 1) {
        value[0] = header.offset;
      }
      return QExifValue(value);
    }
                                 break;
    case QExifValue::Rational: {
      QVector<QExifURational> value(header.count);

      stream.device()->seek(startPos + header.offset);

      for (quint32 i = 0; i < header.count; i++)
        stream >> value[i];

      return QExifValue(value);
    }
    case QExifValue::SignedRational: {
      QVector<QExifSRational> value(header.count);

      stream.device()->seek(startPos + header.offset);

      for (quint32 i = 0; i < header.count; i++)
        stream >> value[i];

      return QExifValue(value);
    }
    default:
      qWarning() << "Invalid Ifd Type" << header.type;

      return QExifValue();
  }
}

template<typename T>
QMap<T, QExifValue> QExifImageHeader::readIfdValues (
  QDataStream &stream,
  int startPos,
  const QList<ExifIfdHeader> &headers
) const {
  QMap<T, QExifValue> values;

  // This needs to be non-const so it works with gcc3
  QList<ExifIfdHeader> headers_ = headers;
  foreach(const ExifIfdHeader &header, headers_)
  values[T(header.tag)] = readIfdValue(stream, startPos, header);

  return values;
}

template<typename T>
QMap<T, QExifValue> QExifImageHeader::readIfdValues (
  QDataStream &stream,
  int startPos,
  const QExifValue &pointer
) const {
  if (pointer.type() == QExifValue::Long && pointer.count() == 1) {
    stream.device()->seek(startPos + pointer.toLong());

    QList<ExifIfdHeader> headers = readIfdHeaders(stream);

    return readIfdValues<T>(stream, startPos, headers);
  } else {
    return QMap<T, QExifValue>();
  }
}

/*!
    Reads the contents of an EXIF header from an I/O \a device.

    Returns true if the header was read and false otherwise.

    \sa loadFromJpeg(), write()
 */
bool QExifImageHeader::read (QIODevice *device) {
  clear();

  int startPos = static_cast<int>(device->pos());

  QDataStream stream(device);

  QByteArray byteOrder = device->read(2);

  if (byteOrder == "II") {
    d->byteOrder = QSysInfo::LittleEndian;

    stream.setByteOrder(QDataStream::LittleEndian);
  } else if (byteOrder == "MM") {
    d->byteOrder = QSysInfo::BigEndian;

    stream.setByteOrder(QDataStream::BigEndian);
  } else {
    return false;
  }

  quint16 id;
  quint32 offset;

  stream >> id;
  stream >> offset;

  if (id != 0x002A)
    return false;

  device->seek(startPos + offset);

  QList<ExifIfdHeader> headers = readIfdHeaders(stream);

  stream >> offset;

  d->imageIfdValues = readIfdValues<ImageTag>(stream, startPos, headers);

  QExifValue exifIfdPointer = d->imageIfdValues.take(ImageTag(ExifIfdPointer));
  QExifValue gpsIfdPointer = d->imageIfdValues.take(ImageTag(GpsInfoIfdPointer));

  d->exifIfdValues = readIfdValues<ExifExtendedTag>(stream, startPos, exifIfdPointer);
  d->gpsIfdValues = readIfdValues<GpsTag>(stream, startPos, gpsIfdPointer);

  d->exifIfdValues.remove(ExifExtendedTag(InteroperabilityIfdPointer));

  if (offset) {
    device->seek(startPos + offset);

    QMap<quint16, QExifValue> thumbnailIfdValues = readIfdValues<quint16>(
        stream, startPos, readIfdHeaders(stream));

    QExifValue jpegOffset = thumbnailIfdValues.value(JpegInterchangeFormat);
    QExifValue jpegLength = thumbnailIfdValues.value(JpegInterchangeFormatLength);

    if (jpegOffset.type() == QExifValue::Long && jpegOffset.count() == 1 &&
        jpegLength.type() == QExifValue::Long && jpegLength.count() == 1) {
      device->seek(startPos + jpegOffset.toLong());

      d->thumbnailData = device->read(jpegLength.toLong());

      d->thumbnailXResolution = thumbnailIfdValues.value(XResolution);
      d->thumbnailYResolution = thumbnailIfdValues.value(YResolution);
      d->thumbnailResolutionUnit = thumbnailIfdValues.value(ResolutionUnit);
      d->thumbnailOrientation = thumbnailIfdValues.value(Orientation);
    }
  }
  return true;
}

quint32 QExifImageHeader::writeExifHeader (QDataStream &stream, quint16 tag, const QExifValue &value, quint32 offset) const {
  stream << tag;
  stream << quint16(value.type());
  stream << quint32(value.count());

  switch (value.type()) {
    case QExifValue::Byte:
      if (value.count() <= 4) {
        foreach(quint8 byte, value.toByteVector())
        stream << byte;
        for (int j = value.count(); j < 4; j++)
          stream << quint8(0);
      } else {
        stream << offset;

        offset += value.count();
      }
      break;
    case QExifValue::Undefined:
      if (value.count() <= 4) {
        stream.device()->write(value.toByteArray());

        if (value.count() < 4)
          stream.writeRawData("\0\0\0\0", 4 - value.count());
      } else {
        stream << offset;

        offset += value.count();
      }
      break;
    case QExifValue::Ascii:
      if (value.count() <= 4) {
        QByteArray bytes = value.toByteArray();

        stream.writeRawData(bytes.constData(), value.count());
        if (value.count() < 4)
          stream.writeRawData("\0\0\0\0", 4 - value.count());
      } else {
        stream << offset;

        offset += value.count();
      }
      break;
    case QExifValue::Short:
      if (value.count() <= 2) {
        foreach(quint16 shrt, value.toShortVector())
        stream << shrt;
        for (int j = value.count(); j < 2; j++)
          stream << quint16(0);
      } else {
        stream << offset;

        offset += static_cast<quint32>(value.count() * sizeof(quint16));
      }
      break;
    case QExifValue::Long:
      if (value.count() == 0) {
        stream << quint32(0);
      } else if (value.count() == 1) {
        stream << value.toLong();
      } else {
        stream << offset;

        offset += static_cast<quint32>(value.count() * sizeof(quint32));
      }
      break;
    case QExifValue::SignedLong:
      if (value.count() == 0) {
        stream << quint32(0);
      } else if (value.count() == 1) {
        stream << value.toSignedLong();
      } else {
        stream << offset;

        offset += static_cast<quint32>(value.count() * sizeof(qint32));
      }
      break;
    case QExifValue::Rational:
      if (value.count() == 0) {
        stream << quint32(0);
      } else {
        stream << offset;

        offset += static_cast<quint32>(value.count() * sizeof(quint32) * 2);
      }
      break;
    case QExifValue::SignedRational:
      if (value.count() == 0) {
        stream << quint32(0);
      } else {
        stream << offset;

        offset += static_cast<quint32>(value.count() * sizeof(qint32) * 2);
      }
      break;
    default:
      qWarning() << "Invalid Ifd Type" << value.type();
      stream << quint32(0);
  }

  return offset;
}

void QExifImageHeader::writeExifValue (QDataStream &stream, const QExifValue &value) const {
  switch (value.type()) {
    case QExifValue::Byte:
      if (value.count() > 4)
        foreach(quint8 byte, value.toByteVector())
        stream << byte;
      break;
    case QExifValue::Undefined:
      if (value.count() > 4)
        stream.device()->write(value.toByteArray());
      break;
    case QExifValue::Ascii:
      if (value.count() > 4) {
        QByteArray bytes = value.toByteArray();

        stream.writeRawData(bytes.constData(), bytes.size() + 1);
      }
      break;
    case QExifValue::Short:
      if (value.count() > 2)
        foreach(quint16 shrt, value.toShortVector())
        stream << shrt;
      break;
    case QExifValue::Long:
      if (value.count() > 1)
        foreach(quint32 lng, value.toLongVector())
        stream << lng;
      break;
    case QExifValue::SignedLong:
      if (value.count() > 1)
        foreach(qint32 lng, value.toSignedLongVector())
        stream << lng;
      break;
    case QExifValue::Rational:
      if (value.count() > 0)
        foreach(QExifURational rational, value.toRationalVector())
        stream << rational;
      break;
    case QExifValue::SignedRational:
      if (value.count() > 0)
        foreach(QExifSRational rational, value.toSignedRationalVector())
        stream << rational;
      break;
    default:
      qWarning() << "Invalid Ifd Type" << value.type();
      break;
  }
}

template<typename T>
quint32 QExifImageHeader::writeExifHeaders (
  QDataStream &stream,
  const QMap<T, QExifValue> &values,
  quint32 offset
) const {
  offset += values.count() * 12;

  for (typename QMap<T, QExifValue>::const_iterator i = values.constBegin(); i != values.constEnd(); i++)
    offset = writeExifHeader(stream, i.key(), i.value(), offset);

  return offset;
}

template<typename T>
void QExifImageHeader::writeExifValues (
  QDataStream &stream,
  const QMap<T, QExifValue> &values
) const {
  for (typename QMap<T, QExifValue>::const_iterator i = values.constBegin(); i != values.constEnd(); i++)
    writeExifValue(stream, i.value());
}

/*!
    Writes an EXIF header to an I/O \a device.

    Returns the total number of bytes written.
 */
qint64 QExifImageHeader::write (QIODevice *device) const {
  // #ifndef QT_NO_DEBUG
  qint64 startPos = device->pos();
  // #endif

  QDataStream stream(device);

  if (d->byteOrder == QSysInfo::LittleEndian) {
    stream.setByteOrder(QDataStream::LittleEndian);

    device->write("II", 2);
    device->write("\x2A\x00", 2);
    device->write("\x08\x00\x00\x00", 4);
  } else if (d->byteOrder == QSysInfo::BigEndian) {
    stream.setByteOrder(QDataStream::BigEndian);

    device->write("MM", 2);
    device->write("\x00\x2A", 2);
    device->write("\x00\x00\x00\x08", 4);
  }

  quint16 count = static_cast<quint16>(d->imageIfdValues.count() + 1);
  quint32 offset = 26;

  if (!d->gpsIfdValues.isEmpty()) {
    count++;
    offset += 12;
  }

  stream << count;

  offset = writeExifHeaders(stream, d->imageIfdValues, offset);

  quint32 exifIfdOffset = offset;

  stream << quint16(ExifIfdPointer);
  stream << quint16(QExifValue::Long);
  stream << quint32(1);
  stream << exifIfdOffset;
  offset += calculateSize(d->exifIfdValues);

  quint32 gpsIfdOffset = offset;

  if (!d->gpsIfdValues.isEmpty()) {
    stream << quint16(GpsInfoIfdPointer);
    stream << quint16(QExifValue::Long);
    stream << quint32(1);
    stream << gpsIfdOffset;

    d->imageIfdValues.insert(ImageTag(GpsInfoIfdPointer), QExifValue(offset));

    offset += calculateSize(d->gpsIfdValues);
  }

  if (!d->thumbnailData.isEmpty())
    stream << offset;     // Write offset to thumbnail Ifd.
  else
    stream << quint32(0);

  writeExifValues(stream, d->imageIfdValues);

  Q_ASSERT(startPos + exifIfdOffset == device->pos());

  stream << quint16(d->exifIfdValues.count());

  writeExifHeaders(stream, d->exifIfdValues, exifIfdOffset);
  writeExifValues(stream, d->exifIfdValues);

  Q_ASSERT(startPos + gpsIfdOffset == device->pos());

  if (!d->gpsIfdValues.isEmpty()) {
    stream << quint16(d->gpsIfdValues.count());

    writeExifHeaders(stream, d->gpsIfdValues, gpsIfdOffset);
    writeExifValues(stream, d->gpsIfdValues);
  }

  Q_ASSERT(startPos + offset == device->pos());

  if (!d->thumbnailData.isEmpty()) {
    offset += 86;

    stream << quint16(7);

    QExifValue xResolution = d->thumbnailXResolution.isNull()
      ? QExifValue(QExifURational(72, 1))
      : d->thumbnailXResolution;

    QExifValue yResolution = d->thumbnailYResolution.isNull()
      ? QExifValue(QExifURational(72, 1))
      : d->thumbnailYResolution;

    QExifValue resolutionUnit = d->thumbnailResolutionUnit.isNull()
      ? QExifValue(quint16(2))
      : d->thumbnailResolutionUnit;

    QExifValue orientation = d->thumbnailOrientation.isNull()
      ? QExifValue(quint16(0))
      : d->thumbnailOrientation;

    writeExifHeader(stream, Compression, QExifValue(quint16(6)), offset);

    offset = writeExifHeader(stream, XResolution, xResolution, offset);
    offset = writeExifHeader(stream, YResolution, yResolution, offset);

    writeExifHeader(stream, ResolutionUnit, resolutionUnit, offset);
    writeExifHeader(stream, Orientation, orientation, offset);
    writeExifHeader(stream, JpegInterchangeFormat, QExifValue(offset), offset);
    writeExifHeader(stream, JpegInterchangeFormatLength,
      QExifValue(quint32(d->thumbnailData.size())), offset);

    writeExifValue(stream, xResolution);
    writeExifValue(stream, yResolution);

    Q_ASSERT(startPos + offset == device->pos());

    device->write(d->thumbnailData);

    offset += d->thumbnailData.size();
  }

  Q_ASSERT(startPos + offset == device->pos());

  d->size = offset;

  return offset;
}
