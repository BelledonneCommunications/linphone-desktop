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

#ifndef QEXIFIMAGEHEADER_H_
#define QEXIFIMAGEHEADER_H_

#include <QPair>
#include <QVector>
#include <QSharedData>
#include <QVariant>
#include <QSysInfo>
#include <QIODevice>

typedef QPair<quint32, quint32> QExifURational;
typedef QPair<qint32, qint32> QExifSRational;

class QExifValuePrivate;

class QExifValue {
public:
  enum Type {
    Byte = 1,
    Ascii = 2,
    Short = 3,
    Long = 4,
    Rational = 5,
    Undefined = 7,
    SignedLong = 9,
    SignedRational = 10
  };

  enum TextEncoding {
    NoEncoding,
    AsciiEncoding,
    JisEncoding,
    UnicodeEncoding,
    UndefinedEncoding
  };

  QExifValue ();
  QExifValue (quint8 value);
  QExifValue (const QVector<quint8> &value);
  QExifValue (const QString &value, TextEncoding encoding = NoEncoding);
  QExifValue (quint16 value);
  QExifValue (const QVector<quint16> &value);
  QExifValue (quint32 value);
  QExifValue (const QVector<quint32> &value);
  QExifValue (const QExifURational &value);
  QExifValue (const QVector<QExifURational> &value);
  QExifValue (const QByteArray &value);
  QExifValue (qint32 value);
  QExifValue (const QVector<qint32> &value);
  QExifValue (const QExifSRational &value);
  QExifValue (const QVector<QExifSRational> &value);
  QExifValue (const QDateTime &value);
  QExifValue (const QExifValue &other);
  QExifValue &operator= (const QExifValue &other);
  ~QExifValue ();

  bool operator== (const QExifValue &other) const;

  bool isNull () const;

  int type () const;
  int count () const;

  TextEncoding encoding () const;

  quint8 toByte () const;
  QVector<quint8> toByteVector () const;
  QString toString () const;
  quint16 toShort () const;
  QVector<quint16> toShortVector () const;
  quint32 toLong () const;
  QVector<quint32> toLongVector () const;
  QExifURational toRational () const;
  QVector<QExifURational> toRationalVector () const;
  QByteArray toByteArray () const;
  qint32 toSignedLong () const;
  QVector<qint32> toSignedLongVector () const;
  QExifSRational toSignedRational () const;
  QVector<QExifSRational> toSignedRationalVector () const;
  QDateTime toDateTime () const;

private:
  QExplicitlySharedDataPointer<QExifValuePrivate> d;
};

struct ExifIfdHeader;

class QExifImageHeaderPrivate;

class QExifImageHeader {
  Q_DISABLE_COPY(QExifImageHeader)

public:
  enum ImageTag {
    ImageWidth = 0x0100,
    ImageLength = 0x0101,
    BitsPerSample = 0x0102,
    Compression = 0x0103,
    PhotometricInterpretation = 0x0106,
    Orientation = 0x0112,
    SamplesPerPixel = 0x0115,
    PlanarConfiguration = 0x011C,
    YCbCrSubSampling = 0x0212,
    XResolution = 0x011A,
    YResolution = 0x011B,
    ResolutionUnit = 0x0128,
    StripOffsets = 0x0111,
    RowsPerStrip = 0x0116,
    StripByteCounts = 0x0117,
    TransferFunction = 0x012D,
    WhitePoint = 0x013E,
    PrimaryChromaciticies = 0x013F,
    YCbCrCoefficients = 0x0211,
    ReferenceBlackWhite = 0x0214,
    DateTime = 0x0132,
    ImageDescription = 0x010E,
    Make = 0x010F,
    Model = 0x0110,
    Software = 0x0131,
    Artist = 0x013B,
    Copyright = 0x8298
  };

  enum ExifExtendedTag {
    ExifVersion = 0x9000,
    FlashPixVersion = 0xA000,
    ColorSpace = 0xA001,
    ComponentsConfiguration = 0x9101,
    CompressedBitsPerPixel = 0x9102,
    PixelXDimension = 0xA002,
    PixelYDimension = 0xA003,
    MakerNote = 0x927C,
    UserComment = 0x9286,
    RelatedSoundFile = 0xA004,
    DateTimeOriginal = 0x9003,
    DateTimeDigitized = 0x9004,
    SubSecTime = 0x9290,
    SubSecTimeOriginal = 0x9291,
    SubSecTimeDigitized = 0x9292,
    ImageUniqueId = 0xA420,
    ExposureTime = 0x829A,
    FNumber = 0x829D,
    ExposureProgram = 0x8822,
    SpectralSensitivity = 0x8824,
    ISOSpeedRatings = 0x8827,
    Oecf = 0x8828,
    ShutterSpeedValue = 0x9201,
    ApertureValue = 0x9202,
    BrightnessValue = 0x9203,
    ExposureBiasValue = 0x9204,
    MaxApertureValue = 0x9205,
    SubjectDistance = 0x9206,
    MeteringMode = 0x9207,
    LightSource = 0x9208,
    Flash = 0x9209,
    FocalLength = 0x920A,
    SubjectArea = 0x9214,
    FlashEnergy = 0xA20B,
    SpatialFrequencyResponse = 0xA20C,
    FocalPlaneXResolution = 0xA20E,
    FocalPlaneYResolution = 0xA20F,
    FocalPlaneResolutionUnit = 0xA210,
    SubjectLocation = 0xA214,
    ExposureIndex = 0xA215,
    SensingMethod = 0xA217,
    FileSource = 0xA300,
    SceneType = 0xA301,
    CfaPattern = 0xA302,
    CustomRendered = 0xA401,
    ExposureMode = 0xA402,
    WhiteBalance = 0xA403,
    DigitalZoomRatio = 0xA404,
    FocalLengthIn35mmFilm = 0xA405,
    SceneCaptureType = 0xA406,
    GainControl = 0xA407,
    Contrast = 0xA408,
    Saturation = 0xA409,
    Sharpness = 0xA40A,
    DeviceSettingDescription = 0xA40B,
    SubjectDistanceRange = 0x40C
  };

  enum GpsTag {
    GpsVersionId = 0x0000,
    GpsLatitudeRef = 0x0001,
    GpsLatitude = 0x0002,
    GpsLongitudeRef = 0x0003,
    GpsLongitude = 0x0004,
    GpsAltitudeRef = 0x0005,
    GpsAltitude = 0x0006,
    GpsTimeStamp = 0x0007,
    GpsSatellites = 0x0008,
    GpsStatus = 0x0009,
    GpsMeasureMode = 0x000A,
    GpsDop = 0x000B,
    GpsSpeedRef = 0x000C,
    GpsSpeed = 0x000D,
    GpsTrackRef = 0x000E,
    GpsTrack = 0x000F,
    GpsImageDirectionRef = 0x0010,
    GpsImageDirection = 0x0011,
    GpsMapDatum = 0x0012,
    GpsDestLatitudeRef = 0x0013,
    GpsDestLatitude = 0x0014,
    GpsDestLongitudeRef = 0x0015,
    GpsDestLongitude = 0x0016,
    GpsDestBearingRef = 0x0017,
    GpsDestBearing = 0x0018,
    GpsDestDistanceRef = 0x0019,
    GpsDestDistance = 0x001A,
    GpsProcessingMethod = 0x001B,
    GpsAreaInformation = 0x001C,
    GpsDateStamp = 0x001D,
    GpsDifferential = 0x001E
  };

  QExifImageHeader ();
  explicit QExifImageHeader (const QString &fileName);
  ~QExifImageHeader ();

  bool loadFromJpeg (const QString &fileName);
  bool loadFromJpeg (QIODevice *device);
  bool saveToJpeg (const QString &fileName) const;
  bool saveToJpeg (QIODevice *device) const;

  bool read (QIODevice *device);
  qint64 write (QIODevice *device) const;

  qint64 size () const;

  QSysInfo::Endian byteOrder () const;

  void clear ();

  QList<ImageTag> imageTags () const;
  QList<ExifExtendedTag> extendedTags () const;
  QList<GpsTag> gpsTags () const;

  bool contains (ImageTag tag) const;
  bool contains (ExifExtendedTag tag) const;
  bool contains (GpsTag tag) const;

  void remove (ImageTag tag);
  void remove (ExifExtendedTag tag);
  void remove (GpsTag tag);

  QExifValue value (ImageTag tag) const;
  QExifValue value (ExifExtendedTag tag) const;
  QExifValue value (GpsTag tag) const;

  void setValue (ImageTag tag, const QExifValue &value);
  void setValue (ExifExtendedTag tag, const QExifValue &value);
  void setValue (GpsTag tag, const QExifValue &value);

  QImage thumbnail () const;
  void setThumbnail (const QImage &thumbnail);

private:
  enum PrivateTag {
    ExifIfdPointer = 0x8769,
    GpsInfoIfdPointer = 0x8825,
    InteroperabilityIfdPointer = 0xA005,
    JpegInterchangeFormat = 0x0201,
    JpegInterchangeFormatLength = 0x0202
  };

  QByteArray extractExif (QIODevice *device) const;

  QList<ExifIfdHeader> readIfdHeaders (QDataStream &stream) const;

  QExifValue readIfdValue (QDataStream &stream, int startPos, const ExifIfdHeader &header) const;
  template<typename T>
  QMap<T, QExifValue> readIfdValues (QDataStream &stream, int startPos, const QList<ExifIfdHeader> &headers) const;
  template<typename T>
  QMap<T, QExifValue> readIfdValues (QDataStream &stream, int startPos, const QExifValue &pointer) const;

  quint32 writeExifHeader (QDataStream &stream, quint16 tag, const QExifValue &value, quint32 offset) const;
  void writeExifValue (QDataStream &stream, const QExifValue &value) const;

  template<typename T>
  quint32 writeExifHeaders (QDataStream &stream, const QMap<T, QExifValue> &values, quint32 offset) const;
  template<typename T>
  void writeExifValues (QDataStream &target, const QMap<T, QExifValue> &values) const;

  quint32 sizeOf (const QExifValue &value) const;

  template<typename T>
  quint32 calculateSize (const QMap<T, QExifValue> &values) const;

  QExifImageHeaderPrivate *d;
};

#endif // ifndef QEXIFIMAGEHEADER_H_
