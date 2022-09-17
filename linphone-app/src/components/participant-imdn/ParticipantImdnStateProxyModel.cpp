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
	auto listModel = qobject_cast<ParticipantImdnStateListModel*>(sourceModel());
	const QModelIndex index = listModel->index(sourceRow, 0, sourceParent);
	const ParticipantImdnStateModel *imdn = index.data().value<ParticipantImdnStateModel *>();
	return imdn->getState() != LinphoneEnums::ChatMessageState::ChatMessageStateIdle;
}

bool ParticipantImdnStateProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const ParticipantImdnStateModel *imdnA = sourceModel()->data(left).value<ParticipantImdnStateModel *>();
  const ParticipantImdnStateModel *imdnB = sourceModel()->data(right).value<ParticipantImdnStateModel *>();

  return imdnA->getState() < imdnB->getState() 
	|| (imdnA->getState() == imdnB->getState() && imdnA->getStateChangeTime() < imdnB->getStateChangeTime());
}
//---------------------------------------------------------------------------------
int ParticipantImdnStateProxyModel::getCount(){
	//return sourceModel() ? sourceModel()->rowCount() : 0;
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
			if(model)
				disconnect(model, &ParticipantImdnStateListModel::countChanged, this, &ParticipantImdnStateProxyModel::countChanged);
			setSourceModel(messageModel);
			connect(messageModel, &ParticipantImdnStateListModel::countChanged, this, &ParticipantImdnStateProxyModel::countChanged);
			connect(messageModel, &ParticipantImdnStateListModel::stateChangedFromIdle, this, &ParticipantImdnStateProxyModel::invalidate);
			connect(messageModel, &ParticipantImdnStateListModel::stateChangedFromIdle, this, &ParticipantImdnStateProxyModel::countChanged);
			sort(0);
			emit countChanged();
		}
	}
	emit chatMessageModelChanged();
}
