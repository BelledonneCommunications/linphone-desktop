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

#include <QQmlApplicationEngine>

#include "app/App.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/core/CoreManager.hpp"

#include "ContactsListModel.hpp"

// =============================================================================

using namespace std;

ContactsListModel::ContactsListModel (QObject *parent) : ProxyListModel(parent) {
	mLinphoneFriends = CoreManager::getInstance()->getCore()->getFriendsLists().front();
	// Clean friends.
	{
		list<shared_ptr<linphone::Friend>> toRemove;
		for (const auto &linphoneFriend : mLinphoneFriends->getFriends()) {
			if (!linphoneFriend->getVcard())
				toRemove.push_back(linphoneFriend);
		}
		
		for (const auto &linphoneFriend : toRemove) {
			qWarning() << QStringLiteral("Remove one friend without vcard.");
			mLinphoneFriends->removeFriend(linphoneFriend);
		}
	}
	
	// Init contacts with linphone friends list.
	QQmlEngine *engine = App::getInstance()->getEngine();
	for (const auto &linphoneFriend : mLinphoneFriends->getFriends()) {
		auto contact = QSharedPointer<ContactModel>::create(linphoneFriend);
		
		// See: http://doc.qt.io/qt-5/qtqml-cppintegration-data.html#data-ownership
		// The returned value must have a explicit parent or a QQmlEngine::CppOwnership.
		engine->setObjectOwnership(contact.get(), QQmlEngine::CppOwnership);
		
		addContact(contact);
	}
}

ContactsListModel::~ContactsListModel(){
	if(rowCount()>0) {
		beginResetModel();
		mOptimizedSearch.clear();
		mList.clear();
		mLinphoneFriends = nullptr;
		endResetModel();
	}
}

bool ContactsListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i) {
		QSharedPointer<ContactModel> contact = mList.takeAt(row).objectCast<ContactModel>();
		for(auto address : contact->getVcardModel()->getSipAddresses()){
			mOptimizedSearch.remove(address.toString());
		}
		
		mLinphoneFriends->removeFriend(contact->mLinphoneFriend);
		
		emit contactRemoved(contact);
	}
	
	endRemoveRows();
	
	return true;
}

// -----------------------------------------------------------------------------

QSharedPointer<ContactModel> ContactsListModel::findContactModelFromSipAddress (const QString &sipAddress) const {
	if(mOptimizedSearch.contains(sipAddress))
		return mOptimizedSearch[sipAddress];
	else
		return nullptr;
}

QSharedPointer<ContactModel> ContactsListModel::findContactModelFromUsername (const QString &username) const {
	auto it = find_if(mList.begin(), mList.end(), [&username](QSharedPointer<QObject> contactModel) {
			return qobject_cast<ContactModel*>(contactModel.get())->getVcardModel()->getUsername() == username;
});
	return it != mList.end() ? it->objectCast<ContactModel>() : nullptr;
}

// -----------------------------------------------------------------------------

ContactModel *ContactsListModel::addContact (VcardModel *vcardModel) {
	// Try to merge vcardModel to an existing contact.
	auto contact = findContactModelFromUsername(vcardModel->getUsername());
	if (contact) {
		contact->mergeVcardModel(vcardModel);
		return contact.get();
	}
	
	contact = QSharedPointer<ContactModel>::create(vcardModel);
	App::getInstance()->getEngine()->setObjectOwnership(contact.get(), QQmlEngine::CppOwnership);
	
	if (mLinphoneFriends->addFriend(contact->mLinphoneFriend) != linphone::FriendList::Status::OK) {
		qWarning() << QStringLiteral("Unable to add contact from vcard:") << vcardModel;
		return nullptr;
	}
	
	qInfo() << QStringLiteral("Add contact from vcard:") << contact.get() << vcardModel;
	
	// Make sure new subscribe is issued.
	mLinphoneFriends->updateSubscriptions();
	
	addContact(contact);
	emit layoutChanged();
	
	emit contactAdded(contact);
	
	return contact.get();
}

void ContactsListModel::removeContact (ContactModel *contact){
	remove(contact);
}

// -----------------------------------------------------------------------------

void ContactsListModel::cleanAvatars () {
	qInfo() << QStringLiteral("Delete all avatars.");
	
	for (const auto &item : mList) {
		auto contact = item.objectCast<ContactModel>();
		VcardModel* vcardModel = contact->cloneVcardModel();
		vcardModel->setAvatar(QString(""));
		contact->setVcardModel(vcardModel);
	}
}

// -----------------------------------------------------------------------------

void ContactsListModel::addContact (QSharedPointer<ContactModel> contact) {
	QObject::connect(contact.get(), &ContactModel::contactUpdated, this, [this, contact]() {
		emit contactUpdated(contact);
	});
	QObject::connect(contact.get(), &ContactModel::sipAddressAdded, this, [this, contact](const QString &sipAddress) {
		mOptimizedSearch[sipAddress] = contact;
		emit sipAddressAdded(contact, sipAddress);
	});
	QObject::connect(contact.get(), &ContactModel::sipAddressRemoved, this, [this, contact](const QString &sipAddress) {
		mOptimizedSearch.remove(sipAddress);
		emit sipAddressRemoved(contact, sipAddress);
	});
	add<ContactModel>(contact);
	for(auto address : contact->getVcardModel()->getSipAddresses()){
		mOptimizedSearch[address.toString()] = contact;
	}
}
