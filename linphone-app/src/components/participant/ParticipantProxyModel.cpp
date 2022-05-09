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
#include "components/conference/ConferenceModel.hpp"
#include "utils/Utils.hpp"

#include "ParticipantListModel.hpp"
#include "ParticipantModel.hpp"

#include <QDebug>


// =============================================================================

// -----------------------------------------------------------------------------

ParticipantProxyModel::ParticipantProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
}

// -----------------------------------------------------------------------------

ChatRoomModel *ParticipantProxyModel::getChatRoomModel() const{
	return mChatRoomModel;
}

ConferenceModel *ParticipantProxyModel::getConferenceModel() const{
	return mConferenceModel;
}

ParticipantListModel * ParticipantProxyModel::getParticipantListModel() const{
	return qobject_cast<ParticipantListModel*>(sourceModel());
}

QStringList ParticipantProxyModel::getSipAddresses() const{
	QStringList participants;
	ParticipantListModel * list = qobject_cast<ParticipantListModel*>(sourceModel());
	for(int i = 0 ; i < list->rowCount() ; ++i)
		participants << list->getAt<ParticipantModel>(i)->getSipAddress();
	return participants;
}

QVariantList ParticipantProxyModel::getParticipants() const{
	QVariantList participants;
	ParticipantListModel * list = qobject_cast<ParticipantListModel*>(sourceModel());
	for(int i = 0 ; i < list->rowCount() ; ++i)
		participants << QVariant::fromValue(list->getAt<ParticipantModel>(i).get());
	return participants;
}

int ParticipantProxyModel::getCount() const{
	auto model = getParticipantListModel();
	return model ? model->rowCount() : 0;
}

bool ParticipantProxyModel::getShowMe() const{
	return mShowMe;
}

// -----------------------------------------------------------------------------

void ParticipantProxyModel::setChatRoomModel(ChatRoomModel * chatRoomModel){
	if(!mChatRoomModel || mChatRoomModel != chatRoomModel){
		mChatRoomModel = chatRoomModel;
		if(mChatRoomModel) {
			auto participants = mChatRoomModel->getParticipantListModel();
			setSourceModel(participants);
			emit participantListModelChanged();
			for(int i = 0 ; i < participants->getCount() ; ++i)
				emit addressAdded(participants->getAt<ParticipantModel>(i)->getSipAddress());
		}else if(!sourceModel()){
			setSourceModel(new ParticipantListModel((ChatRoomModel*)nullptr, this));
			emit participantListModelChanged();
		}
		sort(0);
		emit chatRoomModelChanged();
	}
}

void ParticipantProxyModel::setConferenceModel(ConferenceModel * conferenceModel){
	if(!mConferenceModel || mConferenceModel != conferenceModel){
		mConferenceModel = conferenceModel;
		if(mConferenceModel) {
			auto participants = mConferenceModel->getParticipantListModel();
			setSourceModel(participants);
			emit participantListModelChanged();
			for(int i = 0 ; i < participants->getCount() ; ++i)
				emit addressAdded(participants->getAt<ParticipantModel>(i)->getSipAddress());
		}else if(!sourceModel()){
			setSourceModel(new ParticipantListModel((ConferenceModel*)nullptr, this));
			emit participantListModelChanged();
		}
		sort(0);
		emit conferenceModelChanged();
	}
}

void ParticipantProxyModel::setShowMe(const bool& show){
	if(mShowMe != show){
		mShowMe = show;
		emit showMeChanged();
		invalidate();
	}
}

void ParticipantProxyModel::addAddress(const QString& address){
	ParticipantListModel * participantsModel = qobject_cast<ParticipantListModel*>(sourceModel());
	if(!participantsModel->contains(address)){
		QSharedPointer<ParticipantModel> participant = QSharedPointer<ParticipantModel>::create(nullptr);
		participant->setSipAddress(address);
		participantsModel->add(participant);
		if(mChatRoomModel && mChatRoomModel->getChatRoom()){// Invite and wait for its creation
			mChatRoomModel->getChatRoom()->addParticipant(Utils::interpretUrl(address));
			connect(participant.get(), &ParticipantModel::invitationTimeout, this, &ParticipantProxyModel::removeModel);
			participant->startInvitation();
		}
		if( mConferenceModel && mConferenceModel->getConference()){
			//mConferenceModel->getConference()->addParticipant(Utils::interpretUrl(address));
			std::list<std::shared_ptr<linphone::Address>> addressesToInvite;
			addressesToInvite.push_back(Utils::interpretUrl(address));
			auto callParameters = CoreManager::getInstance()->getCore()->createCallParams(mConferenceModel->getConference()->getCall());
			
			mConferenceModel->getConference()->inviteParticipants(addressesToInvite, callParameters);
			connect(participant.get(), &ParticipantModel::invitationTimeout, this, &ParticipantProxyModel::removeModel);
			participant->startInvitation();
		}
		emit countChanged();
		emit addressAdded(address);
	}
}

void ParticipantProxyModel::removeModel(ParticipantModel * participant){
	if(participant) {
		QString sipAddress =  participant->getSipAddress();
		auto dbParticipant = participant->getParticipant();
		if(mChatRoomModel && dbParticipant && mChatRoomModel->getChatRoom())
			mChatRoomModel->getChatRoom()->removeParticipant(dbParticipant);	// Remove already added
		if( mConferenceModel && dbParticipant && mConferenceModel->getConference())
			mConferenceModel->getConference()->removeParticipant(dbParticipant );
		ParticipantListModel * participantsModel = qobject_cast<ParticipantListModel*>(sourceModel());
		participantsModel->remove(participant);
		emit countChanged();
		emit addressRemoved(sipAddress);
	}
}

// -----------------------------------------------------------------------------

bool ParticipantProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	if( mShowMe)
		return true;
	else{
		const ParticipantModel* a = sourceModel()->data(sourceModel()->index(sourceRow, 0, sourceParent)).value<ParticipantModel*>();
		return !a->isMe();
	}
	//const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	//return true;
}

bool ParticipantProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const ParticipantModel* a = sourceModel()->data(left).value<ParticipantModel*>();
	const ParticipantModel* b = sourceModel()->data(right).value<ParticipantModel*>();
	
	return a->getCreationTime() > b->getCreationTime();
}
