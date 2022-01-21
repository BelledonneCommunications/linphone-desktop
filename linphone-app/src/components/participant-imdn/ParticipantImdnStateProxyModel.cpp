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
#include "ParticipantImdnStateProxyModel.hpp"
#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "ParticipantImdnStateListModel.hpp"
#include "ParticipantImdnStateModel.hpp"

// =============================================================================

ParticipantImdnStateProxyModel::ParticipantImdnStateProxyModel (QObject *parent) : QSortFilterProxyModel(parent){
}

bool ParticipantImdnStateProxyModel::filterAcceptsRow (
  int sourceRow,
  const QModelIndex &sourceParent
) const {
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
  //const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  //const ParticipantDeviceModel *device = index.data().value<ParticipantDeviceModel *>();
	return true;
}

bool ParticipantImdnStateProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const ParticipantImdnStateModel *imdnA = sourceModel()->data(left).value<ParticipantImdnStateModel *>();
  const ParticipantImdnStateModel *imdnB = sourceModel()->data(right).value<ParticipantImdnStateModel *>();

  return imdnA->getState() < imdnB->getState() 
	|| (imdnA->getState() == imdnB->getState() && imdnA->getStateChangeTime() < imdnB->getStateChangeTime());
}
//---------------------------------------------------------------------------------
int ParticipantImdnStateProxyModel::getCount(){
	return rowCount();
}

ChatMessageModel * ParticipantImdnStateProxyModel::getChatMessageModel(){
	return mChatMessageModel;
}

void ParticipantImdnStateProxyModel::setChatMessageModel(ChatMessageModel * message){
	mChatMessageModel = message;
	if(message){
		ParticipantImdnStateListModel *model = static_cast<ParticipantImdnStateListModel*>(sourceModel());
		ParticipantImdnStateListModel *messageModel = message->getParticipantImdnStates().get();
		if( model != messageModel){
			setSourceModel(messageModel);
			connect(messageModel, &ParticipantImdnStateListModel::countChanged, this, &ParticipantImdnStateProxyModel::countChanged);
			sort(0);
			emit countChanged();
		}
	}
	emit chatMessageModelChanged();
}