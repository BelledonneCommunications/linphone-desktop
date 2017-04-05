/*
 * AbstractAbstractCodecsModel.cBase::pp
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

#include <linphone++/linphone.hh>

#include "../../utils.hpp"

#include "AbstractCodecsModel.hpp"

// =============================================================================

AbstractCodecsModel::AbstractCodecsModel (QObject *parent) : QAbstractListModel(parent) {}

int AbstractCodecsModel::rowCount (const QModelIndex &) const {
  return m_codecs.count();
}

QHash<int, QByteArray> AbstractCodecsModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$codec";
  return roles;
}

QVariant AbstractCodecsModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= m_codecs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return m_codecs[row];

  return QVariant();
}

// -----------------------------------------------------------------------------

void AbstractCodecsModel::enableCodec (int id, bool status) {
  Q_ASSERT(id >= 0 && id < m_codecs.count());

  QVariantMap &map = m_codecs[id];
  shared_ptr<linphone::PayloadType> codec = map.value("__codec").value<shared_ptr<linphone::PayloadType> >();

  codec->enable(status);
  map["enabled"] = status;

  emit dataChanged(index(id, 0), index(id, 0));
}

void AbstractCodecsModel::moveCodec (int source, int destination) {
  moveRow(QModelIndex(), source, QModelIndex(), destination);
}

// -----------------------------------------------------------------------------

bool AbstractCodecsModel::moveRows (
  const QModelIndex &source_parent,
  int source_row,
  int count,
  const QModelIndex &destination_parent,
  int destination_child
) {
  int limit = source_row + count - 1;

  {
    int n_codecs = m_codecs.count();
    if (
      source_row < 0 ||
      destination_child < 0 ||
      count < 0 ||
      destination_child > n_codecs ||
      limit >= n_codecs ||
      (source_row <= destination_child && source_row + count >= destination_child)
    )
      return false;
  }

  beginMoveRows(source_parent, source_row, limit, destination_parent, destination_child);

  if (destination_child > source_row) {
    --destination_child;
    for (int i = source_row; i <= limit; ++i) {
      m_codecs.move(source_row, destination_child + i - source_row);
    }
  } else {
    for (int i = source_row; i <= limit; ++i)
      m_codecs.move(source_row + i - source_row, destination_child + i - source_row);
  }

  endMoveRows();

  return true;
}

// -----------------------------------------------------------------------------

void AbstractCodecsModel::addCodec (std::shared_ptr<linphone::PayloadType> &codec) {
  QVariantMap map;

  map["bitrate"] = codec->getNormalBitrate();
  map["channels"] = codec->getChannels();
  map["clockRate"] = codec->getClockRate();
  map["description"] = ::Utils::linphoneStringToQString(codec->getDescription());
  map["enabled"] = codec->enabled();
  map["encoderDescription"] = ::Utils::linphoneStringToQString(codec->getEncoderDescription());
  map["isUsable"] = codec->isUsable();
  map["isVbr"] = codec->isVbr();
  map["mime"] = ::Utils::linphoneStringToQString(codec->getMimeType());
  map["number"] = codec->getNumber();
  map["recvFmtp"] = ::Utils::linphoneStringToQString(codec->getRecvFmtp());
  map["__codec"] = QVariant::fromValue(codec);

  m_codecs << map;
}
