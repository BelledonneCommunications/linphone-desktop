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

#ifndef SEARCH_RESULT_MODEL_H_
#define SEARCH_RESULT_MODEL_H_

#include <QObject>
#include <linphone++/linphone.hh>

#include <list>
// =============================================================================
class ContactModel;

class SearchResultModel : public QObject{
Q_OBJECT
public:
	SearchResultModel(std::shared_ptr<const linphone::Friend> linphoneFriend, std::shared_ptr<const linphone::Address> address, QObject * parent = nullptr);
	
	Q_PROPERTY(ContactModel * contactModel READ getContactModel CONSTANT)
	Q_PROPERTY(QString sipAddress READ getAddressString CONSTANT)
	
	Q_INVOKABLE QString getAddressString() const;
	Q_INVOKABLE QString getAddressStringUriOnly() const;
	
	
	std::shared_ptr<linphone::Address> getAddress()const;
	ContactModel * getContactModel() const;
	
	std::shared_ptr<linphone::Address> mAddress;
	std::shared_ptr<const linphone::Friend> mFriend;
};

Q_DECLARE_METATYPE(std::shared_ptr<SearchResultModel>)

#endif
