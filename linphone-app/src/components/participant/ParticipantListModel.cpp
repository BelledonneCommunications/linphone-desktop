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
#include "components/conference/ConferenceModel.hpp"
#include "utils/Utils.hpp"

#include "ParticipantListModel.hpp"
#include "ParticipantModel.hpp"

#include <QDebug>


// =============================================================================

ParticipantListModel::ParticipantListModel (ChatRoomModel * chatRoomModel, QObject *parent) : ProxyListModel(parent) {
	if( chatRoomModel) {
		mChatRoomModel = chatRoomModel;
		
		connect(mChatRoomModel, &ChatRoomModel::securityEvent, this, &ParticipantListModel::onSecurityEvent);
		connect(mChatRoomModel, &ChatRoomModel::conferenceJoined, this, &ParticipantListModel::onConferenceJoined);
		connect(mChatRoomModel, &ChatRoomModel::participantAdded, this, QOverload<const std::shared_ptr<const linphone::EventLog> &>::of(&ParticipantListModel::onParticipantAdded));
		connect(mChatRoomModel, &ChatRoomModel::participantRemoved, this, QOverload<const std::shared_ptr<const linphone::EventLog> &>::of(&ParticipantListModel::onParticipantRemoved));
		connect(mChatRoomModel, &ChatRoomModel::participantAdminStatusChanged, this, QOverload<const std::shared_ptr<const linphone::EventLog> &>::of(&ParticipantListModel::onParticipantAdminStatusChanged));
		connect(mChatRoomModel, &ChatRoomModel::participantDeviceAdded, this, &ParticipantListModel::onParticipantDeviceAdded);
		connect(mChatRoomModel, &ChatRoomModel::participantDeviceRemoved, this, &ParticipantListModel::onParticipantDeviceRemoved);
		connect(mChatRoomModel, &ChatRoomModel::participantRegistrationSubscriptionRequested, this, &ParticipantListModel::onParticipantRegistrationSubscriptionRequested);
		connect(mChatRoomModel, &ChatRoomModel::participantRegistrationUnsubscriptionRequested, this, &ParticipantListModel::onParticipantRegistrationUnsubscriptionRequested);
		
		updateParticipants();
	}
}

ParticipantListModel::ParticipantListModel (ConferenceModel * conferenceModel, QObject *parent) : ProxyListModel(parent) {
	if( conferenceModel) {
		mConferenceModel = conferenceModel;

		connect(mConferenceModel, &ConferenceModel::participantAdded, this, QOverload<const std::shared_ptr<const linphone::Participant> &>::of(&ParticipantListModel::onParticipantAdded));
		connect(mConferenceModel, &ConferenceModel::participantRemoved, this, QOverload<const std::shared_ptr<const linphone::Participant> &>::of(&ParticipantListModel::onParticipantRemoved));
		connect(mConferenceModel, &ConferenceModel::participantAdminStatusChanged, this, QOverload<const std::shared_ptr<const linphone::Participant> &>::of(&ParticipantListModel::onParticipantAdminStatusChanged));
		connect(mConferenceModel, &ConferenceModel::conferenceStateChanged, this, &ParticipantListModel::onStateChanged);
		
		updateParticipants();
	}
}


ParticipantListModel::~ParticipantListModel(){
	mList.clear();
	mChatRoomModel = nullptr;
	mConferenceModel = nullptr;
}

// -----------------------------------------------------------------------------

ChatRoomModel *ParticipantListModel::getChatRoomModel() const{
	return mChatRoomModel;
}

ConferenceModel *ParticipantListModel::getConferenceModel() const{
	return mConferenceModel;
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
	if( mChatRoomModel || mConferenceModel) {
		bool changed = false;
		auto dbParticipants = (mChatRoomModel ? mChatRoomModel->getParticipants() : mConferenceModel->getParticipantList());
		//Remove left participants
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
			while(itParticipant != mList.end() 
					&& (( itParticipant->objectCast<ParticipantModel>()->getParticipant() 
						&& !dbParticipant->getAddress()->weakEqual(itParticipant->objectCast<ParticipantModel>()->getParticipant()->getAddress()) )
						
						|| (!itParticipant->objectCast<ParticipantModel>()->getParticipant() 
							&& !dbParticipant->getAddress()->weakEqual(Utils::interpretUrl(itParticipant->objectCast<ParticipantModel>()->getSipAddress()))
						))
				  ){
				++itParticipant;
			}
			if( itParticipant == mList.end()){
				auto participant = QSharedPointer<ParticipantModel>::create(dbParticipant);
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

void ParticipantListModel::add(const std::shared_ptr<const linphone::Participant> & participant){
	updateParticipants();
}

void ParticipantListModel::add(const std::shared_ptr<const linphone::Address> & participantAddress){
	add((mChatRoomModel ? mChatRoomModel->getChatRoom()->findParticipant(participantAddress->clone()) : mConferenceModel->getConference()->findParticipant(participantAddress)));
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
const QSharedPointer<ParticipantModel> ParticipantListModel::getParticipant(const std::shared_ptr<const linphone::Participant>& pParticipant) const{
	if(pParticipant){
		auto itParticipant = std::find_if(mList.begin(), mList.end(), [pParticipant] (const QSharedPointer<QObject>& participant){
			return participant.objectCast<ParticipantModel>()->getParticipant() == pParticipant;
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
	if(mChatRoomModel)
		mChatRoomModel->getChatRoom()->setParticipantAdminStatus(participant, isAdmin);
	if(mConferenceModel)
		mConferenceModel->getConference()->setParticipantAdminStatus(participant, isAdmin);
}

void ParticipantListModel::onSecurityEvent(const std::shared_ptr<const linphone::EventLog> & eventLog) {
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

void ParticipantListModel::onConferenceJoined(){
	updateParticipants();
}

void ParticipantListModel::onParticipantAdded(const std::shared_ptr<const linphone::EventLog> & eventLog){
	qDebug() << "onParticipantAdded event: " << eventLog->getParticipantAddress()->asString().c_str();
	add(eventLog->getParticipantAddress());
}

void ParticipantListModel::onParticipantAdded(const std::shared_ptr<const linphone::Participant> & participant){
	qDebug() << "onParticipantAdded part: " << participant->getAddress()->asString().c_str();
	add(participant);
}

void ParticipantListModel::onParticipantAdded(const std::shared_ptr<const linphone::Address>& address){
	qDebug() << "onParticipantAdded addr: " << address->asString().c_str();
	add(address);
}

void ParticipantListModel::onParticipantRemoved(const std::shared_ptr<const linphone::EventLog> & eventLog){
	onParticipantRemoved(eventLog->getParticipantAddress());
}

void ParticipantListModel::onParticipantRemoved(const std::shared_ptr<const linphone::Participant> & participant){
	auto p = getParticipant(participant);
	if(p)
		remove(p.get());
}

void ParticipantListModel::onParticipantRemoved(const std::shared_ptr<const linphone::Address>& address){
	auto participant = getParticipant(address);
	if(participant)
		remove(participant.get());
}

void ParticipantListModel::onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::EventLog> & eventLog){
	onParticipantAdminStatusChanged(eventLog->getParticipantAddress());
}
void ParticipantListModel::onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Participant> & participant){
	auto p = getParticipant(participant);
	if( participant) emit p->adminStatusChanged();// Request to participant to update its status from its data
}
void ParticipantListModel::onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Address>& address ){
	auto participant = getParticipant(address);
	if( participant) emit participant->adminStatusChanged();// Request to participant to update its status from its data
}
void ParticipantListModel::onParticipantDeviceAdded(const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto participant = getParticipant(eventLog->getParticipantAddress());
	if( participant){
		emit participant->deviceCountChanged();
	}
}
void ParticipantListModel::onParticipantDeviceRemoved(const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto participant = getParticipant(eventLog->getParticipantAddress());
	if( participant){
		emit participant->deviceCountChanged();
	}
}
void ParticipantListModel::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<const linphone::Address> & participantAddress){
}
void ParticipantListModel::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<const linphone::Address> & participantAddress){
}

void ParticipantListModel::onStateChanged(){
	if(mConferenceModel){
		if(mConferenceModel->getConference()->getState() == linphone::Conference::State::Created){
			updateParticipants();
		}
	}
}
