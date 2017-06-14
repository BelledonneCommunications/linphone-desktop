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

#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "AbstractCodecsModel.hpp"

using namespace std;

// =============================================================================

inline shared_ptr<linphone::PayloadType> getCodecFromMap (const QVariantMap &map) {
  return map.value("__codec").value<shared_ptr<linphone::PayloadType> >();
}

// -----------------------------------------------------------------------------

AbstractCodecsModel::AbstractCodecsModel (QObject *parent) : QAbstractListModel(parent) {}

int AbstractCodecsModel::rowCount (const QModelIndex &) const {
  return mCodecs.count();
}

QHash<int, QByteArray> AbstractCodecsModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$codec";
  return roles;
}

QVariant AbstractCodecsModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mCodecs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return mCodecs[row];

  return QVariant();
}

// -----------------------------------------------------------------------------

void AbstractCodecsModel::enableCodec (int id, bool status) {
  Q_ASSERT(id >= 0 && id < mCodecs.count());

  QVariantMap &map = mCodecs[id];
  shared_ptr<linphone::PayloadType> codec = ::getCodecFromMap(map);

  codec->enable(status);
  map["enabled"] = codec->enabled();

  emit dataChanged(index(id, 0), index(id, 0));
}

void AbstractCodecsModel::moveCodec (int source, int destination) {
  moveRow(QModelIndex(), source, QModelIndex(), destination);
}

void AbstractCodecsModel::setBitrate (int id, int bitrate) {
  Q_ASSERT(id >= 0 && id < mCodecs.count());

  QVariantMap &map = mCodecs[id];
  shared_ptr<linphone::PayloadType> codec = ::getCodecFromMap(map);

  codec->setNormalBitrate(bitrate);
  map["bitrate"] = codec->getNormalBitrate();

  emit dataChanged(index(id, 0), index(id, 0));
}

void AbstractCodecsModel::setRecvFmtp (int id, const QString &recvFmtp) {
  Q_ASSERT(id >= 0 && id < mCodecs.count());

  QVariantMap &map = mCodecs[id];
  shared_ptr<linphone::PayloadType> codec = ::getCodecFromMap(map);

  codec->setRecvFmtp(::Utils::appStringToCoreString(recvFmtp));
  map["recvFmtp"] = ::Utils::coreStringToAppString(codec->getRecvFmtp());

  emit dataChanged(index(id, 0), index(id, 0));
}

// -----------------------------------------------------------------------------

bool AbstractCodecsModel::moveRows (
  const QModelIndex &sourceParent,
  int sourceRow,
  int count,
  const QModelIndex &destinationParent,
  int destinationChild
) {
  int limit = sourceRow + count - 1;

  {
    int nCodecs = mCodecs.count();
    if (
      sourceRow < 0 ||
      destinationChild < 0 ||
      count < 0 ||
      destinationChild > nCodecs ||
      limit >= nCodecs ||
      (sourceRow <= destinationChild && sourceRow + count >= destinationChild)
    )
      return false;
  }

  beginMoveRows(sourceParent, sourceRow, limit, destinationParent, destinationChild);

  // Update UI.
  if (destinationChild > sourceRow) {
    --destinationChild;
    for (int i = sourceRow; i <= limit; ++i) {
      mCodecs.move(sourceRow, destinationChild + i - sourceRow);
    }
  } else {
    for (int i = sourceRow; i <= limit; ++i)
      mCodecs.move(sourceRow + i - sourceRow, destinationChild + i - sourceRow);
  }

  // Update linphone codecs list.
  list<shared_ptr<linphone::PayloadType> > codecs;
  for (const auto &map : mCodecs)
    codecs.push_back(::getCodecFromMap(map));
  updateCodecs(codecs);

  endMoveRows();

  return true;
}

// -----------------------------------------------------------------------------

void AbstractCodecsModel::addCodec (shared_ptr<linphone::PayloadType> &codec) {
  QVariantMap map;

  map["bitrate"] = codec->getNormalBitrate();
  map["channels"] = codec->getChannels();
  map["clockRate"] = codec->getClockRate();
  map["description"] = ::Utils::coreStringToAppString(codec->getDescription());
  map["enabled"] = codec->enabled();
  map["encoderDescription"] = ::Utils::coreStringToAppString(codec->getEncoderDescription());
  map["isUsable"] = codec->isUsable();
  map["isVbr"] = codec->isVbr();
  map["mime"] = ::Utils::coreStringToAppString(codec->getMimeType());
  map["number"] = codec->getNumber();
  map["recvFmtp"] = ::Utils::coreStringToAppString(codec->getRecvFmtp());
  map["__codec"] = QVariant::fromValue(codec);

  mCodecs << map;
}
