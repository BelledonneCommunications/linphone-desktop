/*
 * CodecsModel.cpp
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

 #include "../../utils.hpp"
 #include "../core/CoreManager.hpp"

 #include "CodecsModel.hpp"

// ============================================================================

template<typename T>
inline void addCodecToList (QVariantList &list, const T &codec, CodecsModel::CodecType type) {
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
  map["type"] = type;
  map["recvFmtp"] = ::Utils::linphoneStringToQString(codec->getRecvFmtp());

  list << map;
}

// -----------------------------------------------------------------------------

CodecsModel::CodecsModel (QObject *parent) : QAbstractListModel(parent) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  for (const auto &codec : core->getAudioPayloadTypes())
    addCodecToList(m_codecs, codec, AudioCodec);

  for (const auto &codec : core->getVideoPayloadTypes())
    addCodecToList(m_codecs, codec, VideoCodec);

  for (const auto &codec : core->getTextPayloadTypes())
    addCodecToList(m_codecs, codec, TextCodec);
}

int CodecsModel::rowCount (const QModelIndex &) const {
  return m_codecs.count();
}

QHash<int, QByteArray> CodecsModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$codec";
  return roles;
}

QVariant CodecsModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= m_codecs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return m_codecs[row];

  return QVariant();
}
