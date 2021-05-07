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

#include "TimelineListModel.hpp"
#include "TimelineModel.hpp"

#include <QDebug>


// =============================================================================

TimelineListModel::TimelineListModel (QObject *parent) : QAbstractListModel(parent) {
  //initTimeline();
	mSelectedCount = 0;
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
			return model;
		}
	}
	return nullptr;
}

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
	CoreManager *coreManager = CoreManager::getInstance();
	auto currentAddress = coreManager->getAccountSettingsModel()->getUsedSipAddress();
			
	std::list<std::shared_ptr<linphone::ChatRoom>> allChatRooms = coreManager->getCore()->getChatRooms();
	QList<std::shared_ptr<TimelineModel> > models;
	for(auto itAllChatRooms = allChatRooms.begin() ; itAllChatRooms != allChatRooms.end() ; ++itAllChatRooms){
		if((*itAllChatRooms)->getMe()->getAddress()->weakEqual(currentAddress)){
			models << getTimeline(*itAllChatRooms, true);
			//models << new TimelineModel(*itAllChatRooms);
		}
	}
	//beginInsertRows(QModelIndex(), 0, models.count()-1);
	
	mTimelines = models;
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
void TimelineListModel::remove (TimelineModel *model) {
	/*
	int index = mTimelines.indexOf(ldap);
	if (index >=0){
		ldap->unsave();
		removeRow(index);
	}*/
}
