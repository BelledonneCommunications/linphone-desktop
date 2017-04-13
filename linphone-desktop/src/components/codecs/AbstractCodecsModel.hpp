/*
 * AbstractCodecsModel.hpp
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
 *  Created on: April 4, 2017
 *      Author: Ronan Abhamon
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

public:
  AbstractCodecsModel (QObject *parent = Q_NULLPTR);
  virtual ~AbstractCodecsModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  Q_INVOKABLE void enableCodec (int id, bool status);
  Q_INVOKABLE void moveCodec (int source, int destination);

  Q_INVOKABLE void setBitrate (int id, int bitrate);
  Q_INVOKABLE void setRecvFmtp (int id, const QString &recvFmtp);

protected:
  bool moveRows (
    const QModelIndex &sourceParent,
    int sourceRow,
    int count,
    const QModelIndex &destinationParent,
    int destinationChild
  ) override;

  void addCodec (std::shared_ptr<linphone::PayloadType> &codec);

  virtual void updateCodecs (std::list<std::shared_ptr<linphone::PayloadType> > &codecs) = 0;

private:
  QList<QVariantMap> mCodecs;
};

Q_DECLARE_METATYPE(std::shared_ptr<linphone::PayloadType> );

#endif // ABSTRACT_CODECS_MODEL_H_
