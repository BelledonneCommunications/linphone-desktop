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

#include "ParticipantDeviceListModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

ParticipantDeviceListModel::ParticipantDeviceListModel (std::shared_ptr<linphone::Participant> participant, QObject *parent) : QAbstractListModel(parent) {
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices() ;
	for(auto device : devices){
		auto deviceModel = std::make_shared<ParticipantDeviceModel>(device);
		connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
		mList << deviceModel;
	}
}

int ParticipantDeviceListModel::rowCount (const QModelIndex &index) const{
	return mList.count();
}

QHash<int, QByteArray> ParticipantDeviceListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$participantDevice";
	return roles;
}

QVariant ParticipantDeviceListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
  
	if (!index.isValid() || row < 0 || row >= mList.count())
	  return QVariant();
  
	if (role == Qt::DisplayRole)
	  return QVariant::fromValue(mList[row].get());
  
	return QVariant();
}

bool ParticipantDeviceListModel::removeRow (int row, const QModelIndex &parent){
	return removeRows(row, 1, parent);
}

bool ParticipantDeviceListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
  
	if (row < 0 || count < 0 || limit >= mList.count())
	  return false;
  
	beginRemoveRows(parent, row, limit);
  
	for (int i = 0; i < count; ++i)
	  mList.takeAt(row)->deleteLater();
  
	endRemoveRows();
  
	return true;
}

void ParticipantDeviceListModel::onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device){
	emit securityLevelChanged(device);
}