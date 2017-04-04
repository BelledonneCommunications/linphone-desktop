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

#include <QSortFilterProxyModel>

// =============================================================================

class AbstractCodecsModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  AbstractCodecsModel (QObject *parent = Q_NULLPTR);
  virtual ~AbstractCodecsModel () = default;

  Q_INVOKABLE void enableCodec (int id, bool status);

protected:
  virtual bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const override = 0;
};

#endif // ABSTRACT_CODECS_MODEL_H_
