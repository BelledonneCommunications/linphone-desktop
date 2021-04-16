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

#include <QDateTime>
#include <QElapsedTimer>
#include <QUrl>
#include <QtDebug>

#include "components/call/CallModel.hpp"
#include "components/chat/ChatModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/history/HistoryModel.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "utils/LinphoneUtils.hpp"
#include "utils/Utils.hpp"

#include "SearchSipAddressesModel.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

SearchSipAddressesModel::SearchSipAddressesModel (QObject *parent) : QAbstractListModel(parent) {
	
	mMagicSearch = CoreManager::getInstance()->getCore()->createMagicSearch();
	mSearch = std::make_shared<SearchHandler>(this);
	QObject::connect(mSearch.get(), SIGNAL(searchReceived(std::list<std::shared_ptr<linphone::SearchResult>> )), this, SLOT(searchReceived(std::list<std::shared_ptr<linphone::SearchResult>>)));
	mMagicSearch->addListener(mSearch);
	
}

SearchSipAddressesModel::~SearchSipAddressesModel(){
	mMagicSearch->removeListener(mSearch);
}

// -----------------------------------------------------------------------------

int SearchSipAddressesModel::rowCount (const QModelIndex &) const {
	return mAddresses.count()-1;
}

QHash<int, QByteArray> SearchSipAddressesModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$sipAddress";
	return roles;
}

QVariant SearchSipAddressesModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mAddresses.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariantMap{{"sipAddress", mAddresses[row]}};
	
	return QVariant();
}

// -----------------------------------------------------------------------------

bool SearchSipAddressesModel::removeRow (int row, const QModelIndex &parent) {
	return removeRows(row, 1, parent);
}

bool SearchSipAddressesModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mAddresses.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mAddresses.removeAt(row);
	
	endRemoveRows();
	
	return true;
}

void SearchSipAddressesModel::setFilter(const QString& filter){
	mMagicSearch->getContactListFromFilterAsync(filter.toStdString(),"");
	//searchReceived(mMagicSearch->getContactListFromFilter(filter.toStdString(),""));	// Just to show how to use sync method
}

void SearchSipAddressesModel::searchReceived(std::list<std::shared_ptr<linphone::SearchResult>> results){
	beginResetModel();
	mAddresses.clear();
	for(auto it = results.begin() ; it != results.end() ; ++it){
		if((*it)->getFriend()){
			mAddresses << QString::fromStdString((*it)->getFriend()->getAddress()->asString());
		}else{
			mAddresses << QString::fromStdString((*it)->getAddress()->asString());
		}
	}
	endResetModel();
}
