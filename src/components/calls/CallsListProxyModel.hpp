/*
 * CallsListProxyModel.hpp
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
 *  Created on: May 22, 2017
 *      Author: Ronan Abhamon
 */

#ifndef CALLS_LIST_PROXY_MODEL_H_
#define CALLS_LIST_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "../call/CallModel.hpp"

// =============================================================================

class CallsListProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  CallsListProxyModel (QObject *parent = Q_NULLPTR);
  ~CallsListProxyModel () = default;

signals:
  void callRunning (int index, CallModel *callModel);

private:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
};

#endif // CALLS_LIST_PROXY_MODEL_H_
