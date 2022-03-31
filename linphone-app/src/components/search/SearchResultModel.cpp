/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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
#include "SearchResultModel.hpp"

#include "components/core/CoreManager.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contacts/ContactsListModel.hpp"

#include "utils/Utils.hpp"

// =============================================================================

SearchResultModel::SearchResultModel(std::shared_ptr<const linphone::Friend> linphoneFriend, std::shared_ptr<const linphone::Address> address, QObject * parent) : QObject(parent){
	mFriend = linphoneFriend;
	if( address)
		mAddress = address->clone();
	else if(linphoneFriend && linphoneFriend->getAddress())
		mAddress = linphoneFriend->getAddress()->clone();
}

QString SearchResultModel::getAddressString() const{
	return Utils::coreStringToAppString(mAddress->asString());
}

QString SearchResultModel::getAddressStringUriOnly() const{
	return Utils::coreStringToAppString(mAddress->asStringUriOnly());
}

std::shared_ptr<linphone::Address> SearchResultModel::getAddress() const{
	return mAddress;
}

ContactModel * SearchResultModel::getContactModel() const{
	return CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(getAddressStringUriOnly()).get();
}



