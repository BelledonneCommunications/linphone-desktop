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

#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "ParticipantListModel.hpp"
#include "ParticipantModel.hpp"

#include <QDebug>


// =============================================================================

ParticipantListModel::ParticipantListModel (ChatRoomModel * chatRoomModel, QObject *parent) : ProxyListModel(parent) {
	if( chatRoomModel) {
		mChatRoomModel = chatRoomModel;//CoreManager::getInstance()->getChatRoomModel(chatRoomModel);
		
		connect(mChatRoomModel, &ChatRoomModel::securityEvent, this, &ParticipantListModel::onSecurityEvent);
		
		connect(mChatRoomModel, &ChatRoomModel::conferenceJoined, this, &ParticipantListModel::onConferenceJoined);
		
		connect(mChatRoomModel, &ChatRoomModel::participantAdded, this, &ParticipantListModel::onParticipantAdded);
		connect(mChatRoomModel, &ChatRoomModel::participantRemoved, this, &ParticipantListModel::onParticipantRemoved);
		connect(mChatRoomModel, &ChatRoomModel::participantDeviceAdded, this, &ParticipantListModel::onParticipantDeviceAdded);
		connect(mChatRoomModel, &ChatRoomModel::participantDeviceRemoved, this, &ParticipantListModel::onParticipantDeviceRemoved);
		
		connect(mChatRoomModel, &ChatRoomModel::participantAdminStatusChanged, this, &ParticipantListModel::onParticipantAdminStatusChanged);
		connect(mChatRoomModel, &ChatRoomModel::participantRegistrationSubscriptionRequested, this, &ParticipantListModel::onParticipantRegistrationSubscriptionRequested);
		connect(mChatRoomModel, &ChatRoomModel::participantRegistrationUnsubscriptionRequested, this, &ParticipantListModel::onParticipantRegistrationUnsubscriptionRequested);
		
		updateParticipants();
	}
}
ParticipantListModel::~ParticipantListModel(){
	mList.clear();
	mChatRoomModel = nullptr;
}

// -----------------------------------------------------------------------------

ChatRoomModel *ParticipantListModel::getChatRoomModel() const{
	return mChatRoomModel;
}

std::list<std::shared_ptr<linphone::Address>> ParticipantListModel::getParticipants()const{
	std::list<std::shared_ptr<linphone::Address>> participants;
	for(auto participant : mList){
		participants.push_back(Utils::interpretUrl(participant.objectCast<ParticipantModel>()->getSipAddress()));
	}
	return participants;
}

QString ParticipantListModel::addressesToString()const{
	QStringList txt;
	for(auto item : mList){
		auto participant = item.objectCast<ParticipantModel>();
		if( participant->getParticipant())// is Participant. We test it because this participant is not accepted by chat room yet.
			txt << Utils::coreStringToAppString(participant->getParticipant()->getAddress()->asStringUriOnly());
	}
	txt.removeFirst();// Remove me
	return txt.join(", ");
}

QString ParticipantListModel::displayNamesToString()const{
	QStringList txt;
	for(auto participant : mList){
		auto p = participant.objectCast<ParticipantModel>()->getParticipant();
		if(p){
			QString displayName = Utils::getDisplayName(p->getAddress());
			if(displayName != "")
				txt << displayName;
		}
	}
	txt.removeFirst();// Remove me
	return txt.join(", ");
}

QString ParticipantListModel::usernamesToString()const{
	QStringList txt;
	for(auto item : mList){
		auto participant = item.objectCast<ParticipantModel>()->getParticipant();
		std::string username = participant->getAddress()->getDisplayName();
		if(username == "")
			username = participant->getAddress()->getUsername();
		txt << Utils::coreStringToAppString(username);
	}
	txt.removeFirst();// Remove me
	return txt.join(", ");
}

bool ParticipantListModel::contains(const QString& address) const{
	auto testAddress = Utils::interpretUrl(address);
	bool exists = false;
	for(auto itParticipant = mList.begin() ; !exists && itParticipant != mList.end() ; ++itParticipant)
		exists = testAddress->weakEqual(Utils::interpretUrl(itParticipant->objectCast<ParticipantModel>()->getSipAddress() ));
	return exists;
}

// -----------------------------------------------------------------------------

void ParticipantListModel::updateParticipants () {
	if( mChatRoomModel) {
		bool changed = false;
		auto dbParticipants = mChatRoomModel->getChatRoom()->getParticipants();
		auto me = mChatRoomModel->getChatRoom()->getMe();
		dbParticipants.push_front(me);
		
		//Remove left participants
		//for(auto participant : mList){
		auto itParticipant = mList.begin();
		while(itParticipant != mList.end()) {
			auto itDbParticipant = dbParticipants.begin();
			while(itDbParticipant != dbParticipants.end() 
				  && (itParticipant->objectCast<ParticipantModel>()->getParticipant() &&  !(*itDbParticipant)->getAddress()->weakEqual(itParticipant->objectCast<ParticipantModel>()->getParticipant()->getAddress())
					  || !itParticipant->objectCast<ParticipantModel>()->getParticipant() && !(*itDbParticipant)->getAddress()->weakEqual(Utils::interpretUrl(itParticipant->objectCast<ParticipantModel>()->getSipAddress()))
					  )
				  ){
				++itDbParticipant;
			}
			if( itDbParticipant == dbParticipants.end()){
				int row = itParticipant - mList.begin();
				beginRemoveRows(QModelIndex(), row, row);
				itParticipant = mList.erase(itParticipant);
				endRemoveRows();
				changed = true;
			}else
				++itParticipant;
		}
		// Add new
		for(auto dbParticipant : dbParticipants){
			auto itParticipant = mList.begin();			
			while(itParticipant != mList.end() && ( itParticipant->objectCast<ParticipantModel>()->getParticipant() && !dbParticipant->getAddress()->weakEqual(itParticipant->objectCast<ParticipantModel>()->getParticipant()->getAddress())
															|| (!itParticipant->objectCast<ParticipantModel>()->getParticipant() && !dbParticipant->getAddress()->weakEqual(Utils::interpretUrl(itParticipant->objectCast<ParticipantModel>()->getSipAddress())))
															)
				  ){
				
				++itParticipant;
			}
			if( itParticipant == mList.end()){
				auto participant = QSharedPointer<ParticipantModel>::create(dbParticipant);
				connect(this, &ParticipantListModel::deviceSecurityLevelChanged, participant.get(), &ParticipantModel::onDeviceSecurityLevelChanged);
				connect(this, &ParticipantListModel::securityLevelChanged, participant.get(), &ParticipantModel::onSecurityLevelChanged);
				connect(participant.get(),&ParticipantModel::updateAdminStatus, this, &ParticipantListModel::setAdminStatus);
				add(participant);
				changed = true;
			}else if(!itParticipant->objectCast<ParticipantModel>()->getParticipant() || itParticipant->objectCast<ParticipantModel>()->getParticipant() != dbParticipant){
				itParticipant->objectCast<ParticipantModel>()->setParticipant(dbParticipant);
				changed = true;
			}
		}
		if( changed){
			emit layoutChanged();
			emit participantsChanged();
			emit countChanged();
		}
	}
}

void ParticipantListModel::add (QSharedPointer<ParticipantModel> participant){
	int row = mList.count();
	connect(this, &ParticipantListModel::deviceSecurityLevelChanged, participant.get(), &ParticipantModel::onDeviceSecurityLevelChanged);
	connect(this, &ParticipantListModel::securityLevelChanged, participant.get(), &ParticipantModel::onSecurityLevelChanged);
	connect(participant.get(),&ParticipantModel::updateAdminStatus, this, &ParticipantListModel::setAdminStatus);
	ProxyListModel::add(participant);
	emit layoutChanged();
	emit participantsChanged();
}

void ParticipantListModel::remove (ParticipantModel *model) {
	QString address = model->getSipAddress();
	int index = 0;
	bool found = false;
	auto itParticipant = mList.begin() ;
	while(!found && itParticipant != mList.end()){
		if( itParticipant->objectCast<ParticipantModel>()->getSipAddress() == address)
			found = true;
		else{
			++itParticipant;
			++index;
		}
	}
	if(found) {
		removeRow(index);
		emit participantsChanged();
	}
}

const QSharedPointer<ParticipantModel> ParticipantListModel::getParticipant(const std::shared_ptr<const linphone::Address>& address) const{
	if(address){
		auto itParticipant = std::find_if(mList.begin(), mList.end(), [address] (const QSharedPointer<QObject>& participant){		
			return participant.objectCast<ParticipantModel>()->getParticipant()->getAddress()->weakEqual(address);
		});
		if( itParticipant == mList.end())
			return nullptr;
		else
			return itParticipant->objectCast<ParticipantModel>();
	}else
		return nullptr;
}

//-------------------------------------------------------------


void ParticipantListModel::setAdminStatus(const std::shared_ptr<linphone::Participant> participant, const bool& isAdmin){
	mChatRoomModel->getChatRoom()->setParticipantAdminStatus(participant, isAdmin);
}

void ParticipantListModel::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	auto address = eventLog->getParticipantAddress();
	if(address) {
		auto participant = getParticipant(address);
		if( participant){
			emit participant->securityLevelChanged();
		}	
	}else{
		address = eventLog->getDeviceAddress();
		// Looping on all participant ensure to get all devices. Can be optimized if Device address is unique :  Gain 2n operations.
		if(address)
			emit deviceSecurityLevelChanged(address);
	}
}

void ParticipantListModel::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateParticipants();
}
void ParticipantListModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateParticipants();
}

void ParticipantListModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateParticipants();
}

void ParticipantListModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	
	auto participant = getParticipant(eventLog->getParticipantAddress());
	if( participant){
		emit participant->adminStatusChanged();// Request to participant to update its status from its data
	}
}
void ParticipantListModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto participant = getParticipant(eventLog->getParticipantAddress());
	if( participant){
		emit participant->deviceCountChanged();
	}
}
void ParticipantListModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto participant = getParticipant(eventLog->getParticipantAddress());
	if( participant){
		emit participant->deviceCountChanged();
	}
}
void ParticipantListModel::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
}
void ParticipantListModel::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
}
