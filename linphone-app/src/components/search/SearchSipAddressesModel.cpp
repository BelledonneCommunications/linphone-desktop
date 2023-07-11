/*
 * Copyright (c) 2010-2022 Belledonne Communications SARL.
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

#include "SearchSipAddressesModel.hpp"

#include <QDateTime>
#include <QElapsedTimer>
#include <QUrl>
#include <QtDebug>

#include "components/call/CallModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/history/HistoryModel.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

#include "SearchResultModel.hpp"



// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

SearchSipAddressesModel::SearchSipAddressesModel (QObject *parent) : ProxyListModel(parent) {
	
	mMagicSearch = CoreManager::getInstance()->getCore()->createMagicSearch();
	mSearch = std::make_shared<SearchListener>();
	QObject::connect(mSearch.get(), &SearchListener::searchReceived, this, &SearchSipAddressesModel::searchReceived, Qt::QueuedConnection);
	mMagicSearch->addListener(mSearch);
	
}

SearchSipAddressesModel::~SearchSipAddressesModel(){
	mMagicSearch->removeListener(mSearch);
}

// -----------------------------------------------------------------------------

void SearchSipAddressesModel::setFilter(const QString& filter){
	if(!filter.isEmpty()){
		mMagicSearch->setSearchLimit((int)CoreManager::getInstance()->getSettingsModel()->getMagicSearchMaxResults());
		mMagicSearch->getContactsListAsync(filter.toStdString(),"", (int)linphone::MagicSearch::Source::All, linphone::MagicSearch::Aggregation::None);
	}else{
		beginResetModel();
		mList.clear();
		endResetModel();
	}
	//searchReceived(mMagicSearch->getContactListFromFilter(Utils::appStringToCoreString(filter),""));	// Just to show how to use sync method
}

void SearchSipAddressesModel::searchReceived(std::list<std::shared_ptr<linphone::SearchResult>> results){
	QList<QSharedPointer<QObject> > addresses;
	for(auto it = results.begin() ; it != results.end() ; ++it){
		auto linphoneFriend = (*it)->getFriend();
		auto address = (*it)->getAddress();
		if( linphoneFriend || address)
			addresses << QSharedPointer<SearchResultModel>::create(linphoneFriend,address );
	}
	beginResetModel();
	mList.clear();
	mList = addresses;
	if(mList.size() > 0 )// remove self
		mList.pop_back();
	endResetModel();
}
