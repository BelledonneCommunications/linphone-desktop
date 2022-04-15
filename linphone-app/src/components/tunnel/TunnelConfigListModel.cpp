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

#include "TunnelConfigListModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

TunnelConfigListModel::TunnelConfigListModel (std::shared_ptr<linphone::Tunnel> tunnel, QObject *parent) : ProxyListModel(parent) {
	std::list<std::shared_ptr<linphone::TunnelConfig>> tunnelConfigs = tunnel->getServers() ;
	for(auto config : tunnelConfigs){
		auto configModel = QSharedPointer<TunnelConfigModel>::create(config);
		mList << configModel;
	}
	if( mList.size() == 0) {
		mList << QSharedPointer<TunnelConfigModel>::create(linphone::Factory::get()->createTunnelConfig());
	}
}

void TunnelConfigListModel::updateTunnelConfigs(std::shared_ptr<linphone::Tunnel> tunnel){
	std::list<std::shared_ptr<linphone::TunnelConfig>> tunnelConfigs = tunnel->getServers() ;
	beginResetModel();
	mList.clear();
	for(auto config : tunnelConfigs){
		mList << QSharedPointer<TunnelConfigModel>::create(config);
	}
	endResetModel();
	emit layoutChanged();
}

bool TunnelConfigListModel::apply(std::shared_ptr<linphone::Tunnel> tunnel){
	tunnel->cleanServers();
	for(auto config : mList){
		tunnel->addServer(config.objectCast<TunnelConfigModel>()->getTunnelConfig());
	}
	updateTunnelConfigs(tunnel);
	return true;
}

void TunnelConfigListModel::addTunnelConfig(){
	int row = rowCount();
	beginInsertRows(QModelIndex(),row,row);
	mList << QSharedPointer<TunnelConfigModel>::create(linphone::Factory::get()->createTunnelConfig());
	endInsertRows();
}

void TunnelConfigListModel::removeTunnelConfig(std::shared_ptr<linphone::Tunnel> tunnel, TunnelConfigModel * model){
	int row = 0;
	while(row < mList.size() && mList[row].get() != model)
		++row;
	if( row < mList.size()) {
		removeRow(row);
		tunnel->removeServer(model->getTunnelConfig());
	}
}
