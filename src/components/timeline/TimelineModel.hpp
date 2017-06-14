/*
 * TimelineModel.hpp
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
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef TIMELINE_MODEL_H_
#define TIMELINE_MODEL_H_

#include <QSortFilterProxyModel>

// =============================================================================

class TimelineModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  TimelineModel (QObject *parent = Q_NULLPTR);
  ~TimelineModel () = default;

  QHash<int, QByteArray> roleNames () const override;

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
};

#endif // TIMELINE_MODEL_H_
