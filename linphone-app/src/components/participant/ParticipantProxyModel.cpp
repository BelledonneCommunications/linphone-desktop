/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "ParticipantProxyModel.hpp"

#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "ParticipantListModel.hpp"
#include "ParticipantModel.hpp"

#include <QDebug>


// =============================================================================

// -----------------------------------------------------------------------------

ParticipantProxyModel::ParticipantProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	mChatRoomModel = nullptr;
}

// -----------------------------------------------------------------------------

ChatRoomModel *ParticipantProxyModel::getChatRoomModel() const{
	return mChatRoomModel;
}

QStringList ParticipantProxyModel::getSipAddresses() const{
	QStringList participants;
	ParticipantListModel * list = dynamic_cast<ParticipantListModel*>(sourceModel());
	for(int i = 0 ; i < list->rowCount() ; ++i)
			participants << list->getAt(i)->getSipAddress();
	return participants;
}

QVariantList ParticipantProxyModel::getParticipants() const{
	QVariantList participants;
	ParticipantListModel * list = dynamic_cast<ParticipantListModel*>(sourceModel());
	for(int i = 0 ; i < list->rowCount() ; ++i)
			participants << QVariant::fromValue(list->getAt(i));
	return participants;
}

int ParticipantProxyModel::count(){
	return dynamic_cast<ParticipantListModel*>(sourceModel())->rowCount();
}

// -----------------------------------------------------------------------------

void ParticipantProxyModel::setChatRoomModel(ChatRoomModel * chatRoomModel){
	if(!mChatRoomModel || mChatRoomModel != chatRoomModel){
		mChatRoomModel = chatRoomModel;
		if(mChatRoomModel)
			setSourceModel(mChatRoomModel->getParticipants());
		else {
			setSourceModel(new ParticipantListModel(nullptr, this));
		}
		sort(0);
		emit chatRoomModelChanged();
	}
}

void ParticipantProxyModel::add(const QString& address){
	ParticipantListModel * participantsModel = dynamic_cast<ParticipantListModel*>(sourceModel());
	if(!participantsModel->contains(address)){
		std::shared_ptr<ParticipantModel> participant = std::make_shared<ParticipantModel>(nullptr);
		participant->setSipAddress(address);
		participantsModel->add(participant);
	}
}

void ParticipantProxyModel::remove(ParticipantModel * participant){
	if(participant)
		dynamic_cast<ParticipantListModel*>(sourceModel())->remove(participant);
}

// -----------------------------------------------------------------------------

bool ParticipantProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  //const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  return true;
}

bool ParticipantProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
    const ParticipantModel* a = sourceModel()->data(left).value<ParticipantModel*>();
    const ParticipantModel* b = sourceModel()->data(right).value<ParticipantModel*>();
  
    return a->getCreationTime() >= b->getCreationTime();
}
