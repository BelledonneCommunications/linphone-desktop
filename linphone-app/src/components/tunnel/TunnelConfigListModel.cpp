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

TunnelConfigListModel::TunnelConfigListModel (std::shared_ptr<linphone::Tunnel> tunnel, QObject *parent) : QAbstractListModel(parent) {
	std::list<std::shared_ptr<linphone::TunnelConfig>> tunnelConfigs = tunnel->getServers() ;
	for(auto config : tunnelConfigs){
		auto configModel = std::make_shared<TunnelConfigModel>(config);
		mList << configModel;
	}
	if( mList.size() == 0) {
		mList << std::make_shared<TunnelConfigModel>(linphone::Factory::get()->createTunnelConfig());
	}
}

int TunnelConfigListModel::rowCount (const QModelIndex &index) const{
	return mList.count();
}

int TunnelConfigListModel::count(){
	return mList.count();
}

void TunnelConfigListModel::updateTunnelConfigs(std::shared_ptr<linphone::Tunnel> tunnel){
	std::list<std::shared_ptr<linphone::TunnelConfig>> tunnelConfigs = tunnel->getServers() ;
	beginResetModel();
	mList.clear();
	for(auto config : tunnelConfigs){
		mList << std::make_shared<TunnelConfigModel>(config);
	}
	endResetModel();
	emit layoutChanged();
}

bool TunnelConfigListModel::apply(std::shared_ptr<linphone::Tunnel> tunnel){
	tunnel->cleanServers();
	for(auto config : mList){
		tunnel->addServer(config->getTunnelConfig());
	}
	updateTunnelConfigs(tunnel);
	return true;
}

void TunnelConfigListModel::addTunnelConfig(){
	int row = rowCount();
	beginInsertRows(QModelIndex(),row,row);
	mList << std::make_shared<TunnelConfigModel>(linphone::Factory::get()->createTunnelConfig());
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

QHash<int, QByteArray> TunnelConfigListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$tunnelConfig";
	return roles;
}

QVariant TunnelConfigListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row].get());
	
	return QVariant();
}

bool TunnelConfigListModel::removeRow (int row, const QModelIndex &parent){
	return removeRows(row, 1, parent);
}

bool TunnelConfigListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row);
	
	endRemoveRows();
	
	return true;
}
