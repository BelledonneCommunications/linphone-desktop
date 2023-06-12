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
#include "components/friend/FriendListListener.hpp"

#include "ContactsListModel.hpp"

// =============================================================================
void ContactsListModel::connectTo(FriendListListener * listener){
	connect(listener, &FriendListListener::contactCreated, this, &ContactsListModel::onContactCreated);
	connect(listener, &FriendListListener::contactDeleted, this, &ContactsListModel::onContactDeleted);
	connect(listener, &FriendListListener::contactUpdated, this, &ContactsListModel::onContactUpdated);
	connect(listener, &FriendListListener::syncStatusChanged, this, &ContactsListModel::onSyncStatusChanged);
	connect(listener, &FriendListListener::presenceReceived, this, &ContactsListModel::onPresenceReceived);
}
// =============================================================================

using namespace std;

ContactsListModel::ContactsListModel (QObject *parent) : ProxyListModel(parent) {
	mFriendListListener = std::make_shared<FriendListListener>();
	connectTo(mFriendListListener.get());
	update();
}

ContactsListModel::~ContactsListModel(){
	if(rowCount()>0) {
		beginResetModel();
		mOptimizedSearch.clear();
		mList.clear();
		mLinphoneFriends.clear();
		endResetModel();
	}
}

bool ContactsListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
		
	auto friendsList = CoreManager::getInstance()->getCore()->getFriendsLists();
	emit layoutAboutToBeChanged();
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i) {
		QSharedPointer<ContactModel> contact = mList.takeAt(row).objectCast<ContactModel>();
		for(auto address : contact->getVcardModel()->getSipAddresses()){
			auto addressStr = address.toString();
			mOptimizedSearch.remove(addressStr);
		}
		
		for(auto l : friendsList)
			l->removeFriend(contact->mLinphoneFriend);
		
		emit contactRemoved(contact);
	}
	
	endRemoveRows();
	emit layoutChanged();
	return true;
}

// -----------------------------------------------------------------------------

QSharedPointer<ContactModel> ContactsListModel::findContactModelFromSipAddress (const QString &sipAddress) const {
	auto result = mOptimizedSearch.find(sipAddress);
	if(result != mOptimizedSearch.end())
		return result.value();
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
ContactModel *ContactsListModel::getContactModelFromAddress (const QString& address) const{
	auto contact = findContactModelFromSipAddress(address);
	return contact.get();
}

ContactModel *ContactsListModel::addContact (VcardModel *vcardModel) {
	if(!vcardModel)
		return nullptr;
	
	// Try to merge vcardModel to an existing contact.
	auto contact = findContactModelFromUsername(vcardModel->getUsername());
	if (contact) {
		contact->mergeVcardModel(vcardModel);
		return contact.get();
	}
	
	contact = QSharedPointer<ContactModel>::create(vcardModel);
	App::getInstance()->getEngine()->setObjectOwnership(contact.get(), QQmlEngine::CppOwnership);
	addContact(contact);
	
	if( mLinphoneFriends.size() == 0){
		update();// Friends were not loaded correctly. Update them.
	}
	auto friendsList = CoreManager::getInstance()->getCore()->getDefaultFriendList();
	if( !friendsList){
		qWarning() << "There is no friends list available, cannot add a contact" ;
		return nullptr;
	}
	
	if (friendsList->addFriend(contact->mLinphoneFriend) != linphone::FriendList::Status::OK) {
		qWarning() << QStringLiteral("Unable to add contact from vcard:") << vcardModel;
		return nullptr;
	}
	
	
	qInfo() << QStringLiteral("Add contact from vcard:") << contact.get() << vcardModel;
	
	// Make sure new subscribe is issued.
	friendsList->updateSubscriptions();
	
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
		auto addressStr = address.toString();
		mOptimizedSearch[addressStr] = contact;
	}
}

void ContactsListModel::update(){
	beginResetModel();
	for(auto l : mLinphoneFriends)
		l->removeListener(mFriendListListener);
	mLinphoneFriends.clear();
	mOptimizedSearch.clear();
	mList.clear();
	endResetModel();

	mLinphoneFriends = CoreManager::getInstance()->getCore()->getFriendsLists();
	
	for(auto l : mLinphoneFriends){
		l->addListener(mFriendListListener);
		for (const auto &linphoneFriend : l->getFriends()) {
			onContactCreated(linphoneFriend);
		}
	}
}

//------------------------------------------------------------------------------------------------

void ContactsListModel::onContactCreated(const std::shared_ptr<linphone::Friend> & linphoneFriend){
	if(linphoneFriend){
		QQmlEngine *engine = App::getInstance()->getEngine();
		auto haveContact = std::find_if(mList.begin(), mList.end(), [linphoneFriend] (const QSharedPointer<QObject>& item){		
				return item.objectCast<ContactModel>()->getFriend() == linphoneFriend;
			});
		if(haveContact == mList.end()) {
			auto contact = QSharedPointer<ContactModel>::create(linphoneFriend);
		// See: http://doc.qt.io/qt-5/qtqml-cppintegration-data.html#data-ownership
		// The returned value must have a explicit parent or a QQmlEngine::CppOwnership.
			engine->setObjectOwnership(contact.get(), QQmlEngine::CppOwnership);
			addContact(contact);
		}
	}
}
void ContactsListModel::onContactDeleted(const std::shared_ptr<linphone::Friend> & linphoneFriend){
}
void ContactsListModel::onContactUpdated(const std::shared_ptr<linphone::Friend> & newFriend, const std::shared_ptr<linphone::Friend> & oldFriend){
}
void ContactsListModel::onSyncStatusChanged(linphone::FriendList::SyncStatus status, const std::string & message){
}
void ContactsListModel::onPresenceReceived(const std::list<std::shared_ptr<linphone::Friend>> & friends){
}

