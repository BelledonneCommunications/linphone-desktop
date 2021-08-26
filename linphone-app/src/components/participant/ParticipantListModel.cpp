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

ParticipantListModel::ParticipantListModel (ChatRoomModel * chatRoomModel, QObject *parent) : QAbstractListModel(parent) {
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
	mParticipants.clear();
	mChatRoomModel = nullptr;
}

// -----------------------------------------------------------------------------

ParticipantModel * ParticipantListModel::getAt(const int& index){
	return mParticipants[index].get();
}

ChatRoomModel *ParticipantListModel::getChatRoomModel() const{
	return mChatRoomModel;
}

int ParticipantListModel::getCount() const{
	return mParticipants.size();
}

QString ParticipantListModel::addressesToString()const{
	QStringList txt;
	for(auto participant : mParticipants){
		if( participant->getParticipant())// is Participant. We test it because this participant is not accepted by chat room yet.
			txt << Utils::coreStringToAppString(participant->getParticipant()->getAddress()->asStringUriOnly());
	}
	txt.removeFirst();// Remove me
	return txt.join(", ");
}

QString ParticipantListModel::displayNamesToString()const{
	QStringList txt;
	for(auto participant : mParticipants){
		auto p = participant->getParticipant();
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
	for(auto participant : mParticipants){
		std::string username = participant->getParticipant()->getAddress()->getDisplayName();
		if(username == "")
			username = participant->getParticipant()->getAddress()->getUsername();
		txt << Utils::coreStringToAppString(username);
	}
	txt.removeFirst();// Remove me
	return txt.join(", ");
}

bool ParticipantListModel::contains(const QString& address) const{
	auto testAddress = Utils::interpretUrl(address);
	bool exists = false;
	for(auto itParticipant = mParticipants.begin() ; !exists && itParticipant != mParticipants.end() ; ++itParticipant)
		exists = testAddress->weakEqual(Utils::interpretUrl((*itParticipant)->getSipAddress() ));
	return exists;
}

//----------------------------------------------------------------------------
int ParticipantListModel::rowCount (const QModelIndex &) const {
	return mParticipants.count();
}

QHash<int, QByteArray> ParticipantListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$participant";
	return roles;
}

QVariant ParticipantListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mParticipants.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mParticipants[row].get());
	
	return QVariant();
}

// -----------------------------------------------------------------------------



// -----------------------------------------------------------------------------

bool ParticipantListModel::removeRow (int row, const QModelIndex &parent) {
	return removeRows(row, 1, parent);
}

bool ParticipantListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mParticipants.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i){
		mParticipants.takeAt(row);
	}
	
	endRemoveRows();
	emit countChanged();
	return true;
}


// -----------------------------------------------------------------------------

void ParticipantListModel::updateParticipants () {
	if( mChatRoomModel) {
		bool changed = false;
		auto dbParticipants = mChatRoomModel->getChatRoom()->getParticipants();
		auto me = mChatRoomModel->getChatRoom()->getMe();
		dbParticipants.push_front(me);
		
		//Remove left participants
		//for(auto participant : mParticipants){
		auto itParticipant = mParticipants.begin();
		while(itParticipant != mParticipants.end()) {
			auto itDbParticipant = dbParticipants.begin();
			while(itDbParticipant != dbParticipants.end() 
				  && ((*itParticipant)->getParticipant() &&  !(*itDbParticipant)->getAddress()->weakEqual((*itParticipant)->getParticipant()->getAddress())
					  || !(*itParticipant)->getParticipant() && !(*itDbParticipant)->getAddress()->weakEqual(Utils::interpretUrl((*itParticipant)->getSipAddress()))
					  )
				  ){
				++itDbParticipant;
			}
			if( itDbParticipant == dbParticipants.end()){
				int row = itParticipant - mParticipants.begin();
				beginRemoveRows(QModelIndex(), row, row);
				itParticipant = mParticipants.erase(itParticipant);
				endRemoveRows();
				changed = true;
			}else
				++itParticipant;
		}
		// Add new
		for(auto dbParticipant : dbParticipants){
			auto itParticipant = mParticipants.begin();			
			while(itParticipant != mParticipants.end() && ( (*itParticipant)->getParticipant() && !dbParticipant->getAddress()->weakEqual((*itParticipant)->getParticipant()->getAddress())
															|| (!(*itParticipant)->getParticipant() && !dbParticipant->getAddress()->weakEqual(Utils::interpretUrl((*itParticipant)->getSipAddress())))
															)
				  ){
				
				++itParticipant;
			}
			if( itParticipant == mParticipants.end()){
				auto participant = std::make_shared<ParticipantModel>(dbParticipant);
				connect(this, &ParticipantListModel::deviceSecurityLevelChanged, participant.get(), &ParticipantModel::onDeviceSecurityLevelChanged);
				connect(this, &ParticipantListModel::securityLevelChanged, participant.get(), &ParticipantModel::onSecurityLevelChanged);
				connect(participant.get(),&ParticipantModel::updateAdminStatus, this, &ParticipantListModel::setAdminStatus);
				int row = mParticipants.count();
				beginInsertRows(QModelIndex(), row, row);
				mParticipants << participant;
				endInsertRows();
				changed = true;
			}else if(!(*itParticipant)->getParticipant()){
				(*itParticipant)->setParticipant(dbParticipant);
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

void ParticipantListModel::add (std::shared_ptr<ParticipantModel> participant){
	int row = mParticipants.count();
	connect(this, &ParticipantListModel::deviceSecurityLevelChanged, participant.get(), &ParticipantModel::onDeviceSecurityLevelChanged);
	connect(this, &ParticipantListModel::securityLevelChanged, participant.get(), &ParticipantModel::onSecurityLevelChanged);
	connect(participant.get(),&ParticipantModel::updateAdminStatus, this, &ParticipantListModel::setAdminStatus);
	beginInsertRows(QModelIndex(), row, row);
	mParticipants << participant;
	endInsertRows();
	emit layoutChanged();
	emit participantsChanged();
	emit countChanged();
}

void ParticipantListModel::remove (ParticipantModel *model) {
	QString address = model->getSipAddress();
	int index = 0;
	bool found = false;
	auto itParticipant = mParticipants.begin() ;
	while(!found && itParticipant != mParticipants.end()){
		if( (*itParticipant)->getSipAddress() == address)
			found = true;
		else{
			++itParticipant;
			++index;
		}
	}
	if(found) {
		beginRemoveRows(QModelIndex(), index, index);
		mParticipants.erase(itParticipant);
		endRemoveRows();
		emit participantsChanged();
		emit countChanged();
	}
}

const std::shared_ptr<ParticipantModel> ParticipantListModel::getParticipant(const std::shared_ptr<const linphone::Address>& address) const{
	if(address){
		auto itParticipant = std::find_if(mParticipants.begin(), mParticipants.end(), [address] (const std::shared_ptr<ParticipantModel>& participant){		
			return participant->getParticipant()->getAddress()->weakEqual(address);
		});
		if( itParticipant == mParticipants.end())
			return nullptr;
		else
			return *itParticipant;
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
