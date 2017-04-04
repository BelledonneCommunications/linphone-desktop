/*
 * VideoCodecsModel.cpp
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

#include "../core/CoreManager.hpp"

#include "VideoCodecsModel.hpp"

// =============================================================================

VideoCodecsModel::VideoCodecsModel (QObject *parent) : AbstractCodecsModel(parent) {
  setSourceModel(CoreManager::getInstance()->getCodecsModel());
}

bool VideoCodecsModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  const QModelIndex &index = sourceModel()->index(source_row, 0, source_parent);
  return index.data().toMap()["type"] == CodecsModel::VideoCodec;
}
