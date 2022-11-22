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
#include "components/conferenceInfo/ConferenceInfoModel.hpp"
#include "utils/Utils.hpp"

#include "ParticipantListModel.hpp"
#include "ParticipantModel.hpp"

#include <QDebug>


// =============================================================================

// -----------------------------------------------------------------------------

ParticipantProxyModel::ParticipantProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	setSourceModel(new ParticipantListModel((ConferenceModel*)nullptr, this));
	connect(this, &ParticipantProxyModel::chatRoomModelChanged, this, &ParticipantProxyModel::countChanged);
	connect(this, &ParticipantProxyModel::conferenceModelChanged, this, &ParticipantProxyModel::countChanged);
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
			connect(participants, &ParticipantListModel::countChanged, this, &ParticipantProxyModel::countChanged);
			setSourceModel(participants);
			emit participantListModelChanged();
			for(int i = 0 ; i < participants->getCount() ; ++i) {
				auto participant = participants->getAt<ParticipantModel>(i);
				connect(participant.get(), &ParticipantModel::invitationTimeout, this, &ParticipantProxyModel::removeModel);
				emit addressAdded(participant->getSipAddress());
			}
		}else if(!sourceModel()){
			auto model = new ParticipantListModel((ChatRoomModel*)nullptr, this); 
			connect(model, &ParticipantListModel::countChanged, this, &ParticipantProxyModel::countChanged);
			setSourceModel(model);
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
			connect(participants, &ParticipantListModel::countChanged, this, &ParticipantProxyModel::countChanged);
			setSourceModel(participants);
			emit participantListModelChanged();
			for(int i = 0 ; i < participants->getCount() ; ++i) {
				auto participant = participants->getAt<ParticipantModel>(i);
				connect(participant.get(), &ParticipantModel::invitationTimeout, this, &ParticipantProxyModel::removeModel);
				emit addressAdded(participant->getSipAddress());
			}
		}else if(!sourceModel()){
			auto model = new ParticipantListModel((ConferenceModel*)nullptr, this); 
			connect(model, &ParticipantListModel::countChanged, this, &ParticipantProxyModel::countChanged);
			setSourceModel(model);
			emit participantListModelChanged();
		}
		sort(0);
		emit conferenceModelChanged();
	}
}

void ParticipantProxyModel::setAddresses(ConferenceInfoModel * conferenceInfoModel){
	if(conferenceInfoModel && conferenceInfoModel->getConferenceInfo())
		for(auto address : conferenceInfoModel->getConferenceInfo()->getParticipants())
			addAddress(QString::fromStdString(address->asString()));
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
		connect(participant.get(), &ParticipantModel::invitationTimeout, this, &ParticipantProxyModel::removeModel);
		participant->setSipAddress(address);
		participantsModel->add(participant);
		if(mChatRoomModel && mChatRoomModel->getChatRoom()){// Invite and wait for its creation
			participant->startInvitation();
			mChatRoomModel->getChatRoom()->addParticipant(Utils::interpretUrl(address));
		}
		if( mConferenceModel && mConferenceModel->getConference()){
			auto addressToInvite = Utils::interpretUrl(address);
			std::list<std::shared_ptr<linphone::Call>> runningCallsToAdd;			
			auto currentCalls = CoreManager::getInstance()->getCore()->getCalls();
			auto haveCall = std::find_if(currentCalls.begin(), currentCalls.end(), [addressToInvite](const std::shared_ptr<linphone::Call>& call){
				return call->getRemoteAddress()->weakEqual(addressToInvite);
			});
			participant->startInvitation();
			if( haveCall == currentCalls.end())
				mConferenceModel->getConference()->addParticipant(addressToInvite);
			else{
				runningCallsToAdd.push_back(*haveCall);
				mConferenceModel->getConference()->addParticipants(runningCallsToAdd);
			}
		/*
			std::list<std::shared_ptr<linphone::Address>> addressesToInvite;
			addressesToInvite.push_back(addressToInvite);
			auto callParameters = CoreManager::getInstance()->getCore()->createCallParams(mConferenceModel->getConference()->getCall());
			mConferenceModel->getConference()->inviteParticipants(addressesToInvite, callParameters);*/		
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
}

bool ParticipantProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const ParticipantModel* a = sourceModel()->data(left).value<ParticipantModel*>();
	const ParticipantModel* b = sourceModel()->data(right).value<ParticipantModel*>();
	
	return a->getCreationTime() > b->getCreationTime();
}
