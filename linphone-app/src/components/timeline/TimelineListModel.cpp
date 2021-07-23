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

#include "TimelineListModel.hpp"

#include "components/core/CoreManager.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "utils/Utils.hpp"


#include "TimelineModel.hpp"

#include <QDebug>


// =============================================================================

TimelineListModel::TimelineListModel (QObject *parent) : QAbstractListModel(parent) {
  //initTimeline();
	mSelectedCount = 0;
	CoreHandlers* coreHandlers= CoreManager::getInstance()->getHandlers().get();
	connect(coreHandlers, &CoreHandlers::chatRoomStateChanged, this, &TimelineListModel::onChatRoomStateChanged);
	connect(coreHandlers, &CoreHandlers::messageReceived, this, &TimelineListModel::update);
	connect(coreHandlers, &CoreHandlers::messageReceived, this, &TimelineListModel::updated);
	
	updateTimelines ();
}

// -----------------------------------------------------------------------------

TimelineModel * TimelineListModel::getAt(const int& index){
	return mTimelines[index].get();
}

void TimelineListModel::reset(){
  //initTimeline();
	updateTimelines ();
}

void TimelineListModel::update(){
	updateTimelines ();
}

void TimelineListModel::selectAll(const bool& selected){
	for(auto it = mTimelines.begin() ; it != mTimelines.end() ; ++it)
		(*it)->mSelected = selected;
}
int TimelineListModel::rowCount (const QModelIndex &) const {
  return mTimelines.count();
}

QHash<int, QByteArray> TimelineListModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$timelines";
  return roles;
}

QVariant TimelineListModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mTimelines.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(mTimelines[row].get());

  return QVariant();
}

// -----------------------------------------------------------------------------



// -----------------------------------------------------------------------------

bool TimelineListModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool TimelineListModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mTimelines.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i){
	auto timeline = mTimelines.takeAt(row);
	timeline->getChatRoomModel()->getChatRoom()->removeListener(timeline);
  }

  endRemoveRows();

  return true;
}


// -----------------------------------------------------------------------------

void TimelineListModel::initTimeline () {
	/*
	CoreManager *coreManager = CoreManager::getInstance();
	auto currentAddress = coreManager->getAccountSettingsModel()->getUsedSipAddress();
			
	std::list<std::shared_ptr<linphone::ChatRoom>> allChatRooms = coreManager->getCore()->getChatRooms();
	QList<std::shared_ptr<TimelineModel>> models;
	for(auto itAllChatRooms = allChatRooms.begin() ; itAllChatRooms != allChatRooms.end() ; ++itAllChatRooms){
		if((*itAllChatRooms)->getMe()->getAddress()->weakEqual(currentAddress)){
			models << new TimelineModel(*itAllChatRooms);
		}
	}
	//beginInsertRows(QModelIndex(), 0, models.count()-1);
	
	mTimelines = models;
	
	//endInsertRows();
	*/
	/*
	initSipAddressesFromChat();
	initSipAddressesFromCalls();
	initRefs();
	initSipAddressesFromContacts();*/
	
	/*
	auto bcSections = lConfig->getSectionsNamesList();
	// Loop on all sections and load configuration. If this is not a LDAP configuration, the model is discarded.
	for(auto itSections = bcSections.begin(); itSections != bcSections.end(); ++itSections) {
		TimelineModel * model = new TimelineModel();
		if(model->load(*itSections)){
			mTimelines.append(model);
		}else
			delete model;
	}
	*/
}

std::shared_ptr<TimelineModel> TimelineListModel::getTimeline(std::shared_ptr<linphone::ChatRoom> chatRoom, const bool &create){
	if(chatRoom){
		for(auto it = mTimelines.begin() ; it != mTimelines.end() ; ++it){
			if( (*it)->getChatRoomModel()->getChatRoom() == chatRoom){
				return *it;
			}
		}
		if(create){
			std::shared_ptr<TimelineModel> model = std::make_shared<TimelineModel>(chatRoom);
			chatRoom->addListener(model);
			connect(model.get(), SIGNAL(selectedChanged(bool)), this, SLOT(selectedHasChanged(bool)));
			//connect(model.get(), SIGNAL(conferenceLeft()), this, SLOT(selectedHasChanged(bool)));
			return model;
		}
	}
	return nullptr;
}

QVariantList TimelineListModel::getLastChatRooms(const int& maxCount) const{
	QVariantList contacts;
	QMultiMap<qint64, ChatRoomModel*> sortedData;
	int count = 0;
	
	QDateTime currentDateTime = QDateTime::currentDateTime();
	auto contactList = CoreManager::getInstance()->getContactsListModel();
	
	for(auto timeline : mTimelines){
		auto chatRoom = timeline->getChatRoomModel();
		if(chatRoom && !chatRoom->isGroupEnabled() && !chatRoom->haveEncryption()) {
			//ContactModel * contact = contactList->findContactModelFromSipAddress(chatRoom->getPeerAddress());
			//if(contact)
				sortedData.insert(chatRoom->mLastUpdateTime.secsTo(currentDateTime),chatRoom);
		}
	}
	for(auto contact : sortedData){
		++count;
		contacts << QVariant::fromValue(contact);
		if(count >= maxCount)
			return contacts;
	}
	
	return contacts;
}

//-------------------------------------------------------------------------------------------------

void TimelineListModel::setSelectedCount(int selectedCount){
	if(mSelectedCount != selectedCount) {
		mSelectedCount = selectedCount;
		if( mSelectedCount <= 1)// Do not send signals when selection is higher than max : this is a transition state
			emit selectedCountChanged(mSelectedCount);
	}
}

void TimelineListModel::selectedHasChanged(bool selected){
	if(selected) {
		if(mSelectedCount >= 1){// We have more selection than wanted : count select first and unselect after : the final signal will be send only on limit
			setSelectedCount(mSelectedCount+1);// It will not send a change signal
			for(auto it = mTimelines.begin() ; it != mTimelines.end() ; ++it)
				if(it->get() != sender())
					(*it)->setSelected(false);
		}else
			setSelectedCount(mSelectedCount+1);
	} else
		setSelectedCount(mSelectedCount-1);
}

void TimelineListModel::updateTimelines () {
	//CoreManager *coreManager = CoreManager::getInstance();
	//auto currentAddress = coreManager->getAccountSettingsModel()->getUsedSipAddress();
			/*
	//std::list<std::shared_ptr<linphone::ChatRoom>> allChatRooms = coreManager->getCore()->getChatRooms();
	QList<std::shared_ptr<TimelineModel> > models;
	for(auto itAllChatRooms = allChatRooms.begin() ; itAllChatRooms != allChatRooms.end() ; ++itAllChatRooms){
		if((*itAllChatRooms)->getMe()->getAddress()->weakEqual(currentAddress)){
			models << getTimeline(*itAllChatRooms, true);
						  ;
		}
	}
	//beginInsertRows(QModelIndex(), 0, models.count()-1);
	
	mTimelines = models;
	*/
	CoreManager *coreManager = CoreManager::getInstance();
	auto currentAddress = coreManager->getAccountSettingsModel()->getUsedSipAddress();
	std::list<std::shared_ptr<linphone::ChatRoom>> allChatRooms = coreManager->getCore()->getChatRooms();
	
//Remove left participants
	auto itTimeline = mTimelines.begin();
	while(itTimeline != mTimelines.end()) {
		auto itDbTimeline = allChatRooms.begin();
		auto timeline = (*itTimeline)->getChatRoomModel()->getChatRoom();
		while(itDbTimeline != allChatRooms.end() && *itDbTimeline != timeline ){
			++itDbTimeline;
		}
		if( itDbTimeline == allChatRooms.end()){
			int index = itTimeline - mTimelines.begin();
			removeRow(index);
			++itTimeline;
			//itTimeline = mTimelines.erase(itTimeline);
		}else
			++itTimeline;
	}
// Add new
	for(auto dbChatRoom : allChatRooms){
		if(!getTimeline(dbChatRoom, false)){// Create a new Timeline if needed
			std::shared_ptr<TimelineModel> model = std::make_shared<TimelineModel>(dbChatRoom);
			dbChatRoom->addListener(model);
			connect(model.get(), SIGNAL(selectedChanged(bool)), this, SLOT(selectedHasChanged(bool)));
			add(model);
		}
	}
}
/*
// Create a new TimelineModel and put it in the list
void TimelineListModel::add(){
	int row = mTimelines.count();
	beginInsertRows(QModelIndex(), row, row);
	auto model = new TimelineModel();
	model->init();
	mTimelines << model;
	endInsertRows();
	resetInternalData();
}
*/

void TimelineListModel::add (std::shared_ptr<TimelineModel> timeline){
	int row = mTimelines.count();
	beginInsertRows(QModelIndex(), row, row);
	mTimelines << timeline;
	endInsertRows();
	resetInternalData();
}

void TimelineListModel::remove (TimelineModel* model) {
	/*
	int index = mTimelines.indexOf(model);
	if (index >=0){
		ldap->unsave();
		removeRow(index);
	}*/
}
void TimelineListModel::remove(std::shared_ptr<TimelineModel> model){
	int index = mTimelines.indexOf(model);
	if (index >=0){
		removeRow(index);
	}
}

void TimelineListModel::onChatRoomStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,linphone::ChatRoom::State state){
	if( state == linphone::ChatRoom::State::Created
			&& !getTimeline(chatRoom, false)){// Create a new Timeline if needed
		std::shared_ptr<TimelineModel> model = std::make_shared<TimelineModel>(chatRoom);
		chatRoom->addListener(model);
		connect(model.get(), SIGNAL(selectedChanged(bool)), this, SLOT(selectedHasChanged(bool)));
		add(model);
	}else if(state == linphone::ChatRoom::State::Deleted){
		updateTimelines();
	}
}
/*
void TimelineListModel::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> &chatRoom, , const std::shared_ptr<const linphone::EventLog> & eventLog){
	remove(getTimeline(chatRoom, false).get());
}*/