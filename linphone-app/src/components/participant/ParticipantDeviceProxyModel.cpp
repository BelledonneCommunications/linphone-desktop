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

#include "ParticipantDeviceProxyModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "ParticipantDeviceListModel.hpp"

// =============================================================================

ParticipantDeviceProxyModel::ParticipantDeviceProxyModel (QObject *parent) : SortFilterProxyModel(parent){
}

bool ParticipantDeviceProxyModel::filterAcceptsRow (
  int sourceRow,
  const QModelIndex &sourceParent
) const {
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
	auto listModel = qobject_cast<ParticipantDeviceListModel*>(sourceModel());
	/*
	if(mFilterType == 1 && listModel->rowCount() <= 2){
		return sourceRow == 0;
	}else{*/
		const QModelIndex index = listModel->index(sourceRow, 0, sourceParent);
		const ParticipantDeviceModel *device = index.data().value<ParticipantDeviceModel *>();
		return device && (isShowMe() || !device->isMe());
	//}
}

bool ParticipantDeviceProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const ParticipantDeviceModel *deviceA = sourceModel()->data(left).value<ParticipantDeviceModel *>();
  const ParticipantDeviceModel *deviceB = sourceModel()->data(right).value<ParticipantDeviceModel *>();

  return deviceA->getTimeOfJoining() > deviceB->getTimeOfJoining();
}
//---------------------------------------------------------------------------------


ParticipantDeviceModel *ParticipantDeviceProxyModel::getAt(int row){
	QModelIndex sourceIndex = mapToSource(this->index(row, 0));
	return sourceModel()->data(sourceIndex).value<ParticipantDeviceModel *>();
}

CallModel * ParticipantDeviceProxyModel::getCallModel() const{
	return mCallModel;
}

bool ParticipantDeviceProxyModel::isShowMe() const{
	return mShowMe;
}
	
void ParticipantDeviceProxyModel::setCallModel(CallModel * callModel){
	setFilterType(1);
	mCallModel = callModel;
	auto sourceModel = new ParticipantDeviceListModel(mCallModel);
	connect(sourceModel, &ParticipantDeviceListModel::countChanged, this, &ParticipantDeviceProxyModel::onCountChanged);
	setSourceModel(sourceModel);
	emit countChanged();
}

void ParticipantDeviceProxyModel::setParticipant(ParticipantModel * participant){
	setFilterType(0);
	auto sourceModel = participant->getParticipantDevices().get();
	connect(sourceModel, &ParticipantDeviceListModel::countChanged, this, &ParticipantDeviceProxyModel::countChanged);
	setSourceModel(sourceModel);
	emit countChanged();
}

void ParticipantDeviceProxyModel::setShowMe(const bool& show){
	if( mShowMe != show) {
		mShowMe = show;
		emit showMeChanged();
	}
}

void ParticipantDeviceProxyModel::onCountChanged(){
	auto listModel = qobject_cast<ParticipantDeviceListModel*>(sourceModel());
	if(mFilterType == 1 || mFilterType == 2){
		//if( listModel->getCount()
		}
}