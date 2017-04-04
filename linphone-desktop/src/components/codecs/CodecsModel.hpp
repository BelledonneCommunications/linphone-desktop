/*
 * CodecsModel.hpp
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
 *  Created on: April 3, 2017
 *      Author: Ronan Abhamon
 */

#ifndef CODECS_MODEL_H_
#define CODECS_MODEL_H_

#include <memory>

#include <QAbstractListModel>

// =============================================================================

namespace linphone {
  class PayloadType;
}

class CodecsModel : public QAbstractListModel {
  Q_OBJECT;

public:
  enum CodecType {
    AudioCodec,
    VideoCodec,
    TextCodec
  };

  Q_ENUMS(CodecType);

  CodecsModel (QObject *parent = Q_NULLPTR);
  ~CodecsModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  void enableCodec (int id, bool status);

private:
  QVariantList m_codecs;
};

Q_DECLARE_METATYPE(std::shared_ptr<linphone::PayloadType> );

#endif // CODECS_MODEL_H_
