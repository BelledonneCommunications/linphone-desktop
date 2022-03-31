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

#ifndef CONTACTS_LIST_MODEL_H_
#define CONTACTS_LIST_MODEL_H_

#include <memory>

#include "app/proxyModel/ProxyListModel.hpp"

// =============================================================================

namespace linphone {
	class FriendList;
}

class ContactModel;
class VcardModel;

class ContactsListModel : public ProxyListModel {
	friend class SipAddressesModel;
	
	Q_OBJECT;
	
public:
	ContactsListModel (QObject *parent = Q_NULLPTR);
	
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	QSharedPointer<ContactModel> findContactModelFromSipAddress (const QString &sipAddress) const;
	QSharedPointer<ContactModel> findContactModelFromUsername (const QString &username) const;
	
	Q_INVOKABLE ContactModel *addContact (VcardModel *vcardModel);
	Q_INVOKABLE void removeContact (ContactModel *contact);
	
	Q_INVOKABLE void cleanAvatars ();
	
signals:
	void contactAdded (QSharedPointer<ContactModel>);
	void contactRemoved (QSharedPointer<ContactModel>);
	void contactUpdated (QSharedPointer<ContactModel>);
	
	void sipAddressAdded (QSharedPointer<ContactModel>, const QString &sipAddress);
	void sipAddressRemoved (QSharedPointer<ContactModel>, const QString &sipAddress);
	
private:
	void addContact (QSharedPointer<ContactModel> contact);
	
	QMap<QString, QSharedPointer<ContactModel>>	mOptimizedSearch;
	std::shared_ptr<linphone::FriendList> mLinphoneFriends;
};

#endif // CONTACTS_LIST_MODEL_H_
