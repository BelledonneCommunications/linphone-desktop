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

#ifndef ABSTRACT_CODECS_MODEL_H_
#define ABSTRACT_CODECS_MODEL_H_

#include <memory>

#include <QAbstractListModel>

// =============================================================================

namespace linphone {
  class PayloadType;
}

class AbstractCodecsModel : public QAbstractListModel {
  Q_OBJECT;

  Q_PROPERTY(QString codecsFolder READ getCodecsFolder CONSTANT);

public:
  AbstractCodecsModel (QObject *parent = Q_NULLPTR);

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  Q_INVOKABLE void enableCodec (int id, bool status);
  Q_INVOKABLE void moveCodec (int source, int destination);

  Q_INVOKABLE void setBitrate (int id, int bitrate);
  Q_INVOKABLE void setRecvFmtp (int id, const QString &recvFmtp);

  Q_INVOKABLE virtual void reload () {};

  Q_INVOKABLE QVariantMap getCodecInfo (const QString &mime) const;

protected:
  bool moveRows (
    const QModelIndex &sourceParent,
    int sourceRow,
    int count,
    const QModelIndex &destinationParent,
    int destinationChild
  ) override;

  void addCodec (std::shared_ptr<linphone::PayloadType> &codec);
  void addDownloadableCodec (
    const QString &mime,
    const QString &encoderDescription,
    const QString &downloadUrl,
    const QString &installName
  );

  virtual void updateCodecs (std::list<std::shared_ptr<linphone::PayloadType>> &codecs) = 0;

  static QString getCodecsFolder ();

  QList<QVariantMap> mCodecs;
};

Q_DECLARE_METATYPE(std::shared_ptr<linphone::PayloadType>);

#endif // ABSTRACT_CODECS_MODEL_H_
