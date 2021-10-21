/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "TunnelConfigProxyModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "TunnelConfigListModel.hpp"

// =============================================================================

TunnelConfigProxyModel::TunnelConfigProxyModel (QObject *parent) : QSortFilterProxyModel(parent){
}

bool TunnelConfigProxyModel::filterAcceptsRow (
  int sourceRow,
  const QModelIndex &sourceParent
) const {
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
	return true;
}

bool TunnelConfigProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const TunnelConfigModel *deviceA = sourceModel()->data(left).value<TunnelConfigModel *>();
  const TunnelConfigModel *deviceB = sourceModel()->data(right).value<TunnelConfigModel *>();

  return deviceA->getHost() > deviceB->getHost();
}
//---------------------------------------------------------------------------------

void TunnelConfigProxyModel::setTunnel(TunnelModel * tunnel){
	setSourceModel(tunnel->getTunnelConfigs().get());
}