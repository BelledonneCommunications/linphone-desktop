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

#include "SipAddressesModel.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

static inline QVariantMap buildVariantMap (const SipAddressesModel::SipAddressEntry &sipAddressEntry) {
	return QVariantMap{
		{ "sipAddress", sipAddressEntry.sipAddress },
		{ "contactModel", QVariant::fromValue(sipAddressEntry.contact.get()) },
		{ "presenceStatus", sipAddressEntry.presenceStatus },
		{ "__localToConferenceEntry", QVariant::fromValue(&sipAddressEntry.localAddressToConferenceEntry) }
	};
}

SipAddressesModel::DisplayNames::DisplayNames(QString address){
	if(!address.isEmpty()){
		auto lAddress = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(address));
		if(lAddress){
			mFromDisplayAddress = Utils::coreStringToAppString(lAddress->getDisplayName());
			mFromUsernameAddress = Utils::coreStringToAppString(lAddress->getUsername());
		}
	}
}

SipAddressesModel::DisplayNames::DisplayNames(const std::shared_ptr<const linphone::Address>& lAddress){
	mFromDisplayAddress = Utils::coreStringToAppString(lAddress->getDisplayName());
	mFromUsernameAddress = Utils::coreStringToAppString(lAddress->getUsername());
}

QString SipAddressesModel::DisplayNames::get(){
	if(!mFromContact.isEmpty())
		return mFromContact;
	else if(!mFromDisplayAddress.isEmpty())
		return mFromDisplayAddress;
	else if(!mFromAccount.isEmpty())
		return mFromAccount;
	else if(!mFromCallLogs.isEmpty())
		return mFromCallLogs;
	else if(!mFromUsernameAddress.isEmpty())
		return mFromUsernameAddress;
	else
		return "";
}

void SipAddressesModel::DisplayNames::updateFromCall(const std::shared_ptr<const linphone::Address>& address){
	auto displayName = address->getDisplayName();
	if(!displayName.empty())
		mFromCallLogs = Utils::coreStringToAppString(displayName);
}

void SipAddressesModel::DisplayNames::updateFromChatMessage(const std::shared_ptr<const linphone::Address>& address){
	// Not used
}

SipAddressesModel::SipAddressesModel (QObject *parent) : QAbstractListModel(parent) {
	initSipAddresses();
	
	CoreManager *coreManager = CoreManager::getInstance();
	
	mCoreHandlers = coreManager->getHandlers();
	
	QObject::connect(coreManager, &CoreManager::chatRoomModelCreated, this, &SipAddressesModel::handleChatRoomModelCreated);
	QObject::connect(coreManager, &CoreManager::historyModelCreated, this, &SipAddressesModel::handleHistoryModelCreated);
//Use blocking in order to apply updates before any use
	ContactsListModel *contacts = CoreManager::getInstance()->getContactsListModel();
	QObject::connect(contacts, &ContactsListModel::contactAdded, this, &SipAddressesModel::handleContactAdded, Qt::DirectConnection);
	QObject::connect(contacts, &ContactsListModel::contactRemoved, this, &SipAddressesModel::handleContactRemoved, Qt::DirectConnection);
	QObject::connect(contacts, &ContactsListModel::contactUpdated, this, &SipAddressesModel::handleContactUpdated, Qt::DirectConnection);
	QObject::connect(contacts, &ContactsListModel::sipAddressAdded, this, &SipAddressesModel::handleSipAddressAdded, Qt::DirectConnection);
	QObject::connect(contacts, &ContactsListModel::sipAddressRemoved, this, &SipAddressesModel::handleSipAddressRemoved, Qt::DirectConnection);
	
	CoreHandlers *coreHandlers = mCoreHandlers.get();
	QObject::connect(coreHandlers, &CoreHandlers::messagesReceived, this, &SipAddressesModel::handleMessagesReceived, Qt::DirectConnection);
	QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &SipAddressesModel::handleCallStateChanged, Qt::DirectConnection);
	QObject::connect(coreHandlers, &CoreHandlers::presenceReceived, this, &SipAddressesModel::handlePresenceReceived, Qt::DirectConnection);
	QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &SipAddressesModel::handleIsComposingChanged);
}

// -----------------------------------------------------------------------------
void SipAddressesModel::reset(){
	mPeerAddressToSipAddressEntry.clear();
	mRefs.clear();
	resetInternalData();
	initSipAddresses();
	emit sipAddressReset();
}
int SipAddressesModel::rowCount (const QModelIndex &) const {
	return mRefs.count();
}

QHash<int, QByteArray> SipAddressesModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	return roles;
}

QVariant SipAddressesModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mRefs.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return buildVariantMap(*mRefs[row]);
	
	return QVariant();
}

// -----------------------------------------------------------------------------

QVariantMap SipAddressesModel::find (const QString &sipAddress) const {
	QString cleanedAddress = Utils::cleanSipAddress(sipAddress);
	auto it = mPeerAddressToSipAddressEntry.find(cleanedAddress);
	if (it == mPeerAddressToSipAddressEntry.end())
		return QVariantMap();
	
	return buildVariantMap(*it);
}

// -----------------------------------------------------------------------------

ContactModel *SipAddressesModel::mapSipAddressToContact (const QString &sipAddress) const {
	QString cleanedAddress = Utils::cleanSipAddress(sipAddress);
	auto it = mPeerAddressToSipAddressEntry.find(cleanedAddress);
	return it == mPeerAddressToSipAddressEntry.end() ? nullptr : it->contact.get();
}

// -----------------------------------------------------------------------------

SipAddressObserver *SipAddressesModel::getSipAddressObserver (const QString &peerAddress, const QString &localAddress) {
	SipAddressObserver *model = new SipAddressObserver(peerAddress, localAddress);
	const QString cleanedPeerAddress = Utils::cleanSipAddress(peerAddress);
	const QString cleanedLocalAddress = Utils::cleanSipAddress(localAddress);
	
	auto it = mPeerAddressToSipAddressEntry.find(cleanedPeerAddress);
	if (it != mPeerAddressToSipAddressEntry.end()) {
		model->setContact(it->contact);
		model->setPresenceStatus(it->presenceStatus);
		model->setPresenceTimestamp(it->presenceTimestamp);
		
		auto it2 = it->localAddressToConferenceEntry.find(cleanedLocalAddress);
		if (it2 != it->localAddressToConferenceEntry.end())
			model->setUnreadMessageCount(it2->unreadMessageCount+it2->missedCallCount);
	}
	
	mObservers.insert(cleanedPeerAddress, model);
	QObject::connect(model, &SipAddressObserver::destroyed, this, [this, model, cleanedPeerAddress, cleanedLocalAddress]() {
		// Do not use `model` methods. `model` is partially destroyed here!
		if (mObservers.remove(cleanedPeerAddress, model) == 0)
			qWarning() << QStringLiteral("Unable to remove (%1, %2) from observers.")
						  .arg(cleanedPeerAddress).arg(cleanedLocalAddress);
	});
	
	return model;
}

// -----------------------------------------------------------------------------

QString SipAddressesModel::getTransportFromSipAddress (const QString &sipAddress) {
	if( sipAddress.toUpper().contains("TRANSPORT="))
	{// Transport has been specified : check for it
		const shared_ptr<const linphone::Address> address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(sipAddress));
		if (!address)
			return QString("TLS");  // Return TLS by default
		
		switch (address->getTransport()) {
			case linphone::TransportType::Udp:
				return QStringLiteral("UDP");
			case linphone::TransportType::Tcp:
				return QStringLiteral("TCP");
			case linphone::TransportType::Tls:
				return QStringLiteral("TLS");
			case linphone::TransportType::Dtls:
				return QStringLiteral("DTLS");
		}
	}
	
	return QString("TLS");
}

QString SipAddressesModel::addTransportToSipAddress (const QString &sipAddress, const QString &transport) {
	shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(sipAddress));
	
	if (!address)
		return QString("");
	LinphoneEnums::TransportType transportType;
	LinphoneEnums::fromString(transport, &transportType);
	address->setTransport(LinphoneEnums::toLinphone(transportType));
	
	return Utils::coreStringToAppString(address->asString());
}

QString SipAddressesModel::getDisplayName(const std::shared_ptr<const linphone::Address>& address){
	std::shared_ptr<linphone::Address> cleanAddress = address->clone();
	cleanAddress->clean();
	QString qtAddress = Utils::coreStringToAppString(cleanAddress->asStringUriOnly());
	auto sipAddressEntry = getSipAddressEntry(qtAddress, cleanAddress);
	return sipAddressEntry->displayNames.get();
}

// -----------------------------------------------------------------------------

QString SipAddressesModel::interpretSipAddress (const QString &sipAddress, bool checkUsername) {
	shared_ptr<linphone::Address> lAddress = Utils::interpretUrl(sipAddress);
	
	if (lAddress && (!checkUsername || !lAddress->getUsername().empty()))
		return Utils::coreStringToAppString(lAddress->asStringUriOnly());
	return QString("");
}
QString SipAddressesModel::interpretSipAddress (const QString &sipAddress, const QString &domain) {
	auto core = CoreManager::getInstance()->getCore();
	if(!core){
		qWarning() << "No core to interpret address";
	}else{
		auto accountParams = CoreManager::getInstance()->getCore()->createAccountParams();
		shared_ptr<linphone::Address> lAddressTemp = core->createPrimaryContactParsed();// Create an address
		if( lAddressTemp ){
			lAddressTemp->setDomain(Utils::appStringToCoreString(domain));    // Set the domain and use the address into account
			accountParams->setIdentityAddress(lAddressTemp);
			auto account = CoreManager::getInstance()->getCore()->createAccount(accountParams);
			if( account){
				shared_ptr<linphone::Address> lAddress = account->normalizeSipUri(Utils::appStringToCoreString(sipAddress));
				if (lAddress) {
					return Utils::coreStringToAppString(lAddress->asStringUriOnly());
				} else {
					qWarning() << "Cannot normalize Sip Uri : " << sipAddress << " / " << domain;
					return QString("");
				}
			}else{
				qWarning() << "Cannot create an account to interpret parse address : " << sipAddress;
			}
		}else{
			qWarning() << "Cannot create a Primary Contact Parsed";
		}
	}
	return QString("");
}

QString SipAddressesModel::interpretSipAddress (const QUrl &sipAddress) {
	return sipAddress.toString();
}

bool SipAddressesModel::addressIsValid (const QString &address) {
	return !!linphone::Factory::get()->createAddress(Utils::appStringToCoreString(address));
}

bool SipAddressesModel::sipAddressIsValid (const QString &sipAddress) {
	shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(sipAddress));
	return address && !address->getUsername().empty();
}

// Return at most : sip:username@domain
QString SipAddressesModel::cleanSipAddress (const QString &sipAddress) {
	return Utils::cleanSipAddress(sipAddress);
}

// -----------------------------------------------------------------------------

bool SipAddressesModel::removeRow (int row, const QModelIndex &parent) {
	return removeRows(row, 1, parent);
}

bool SipAddressesModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mRefs.count())
		return false;
	emit layoutAboutToBeChanged();
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mPeerAddressToSipAddressEntry.remove(mRefs.takeAt(row)->sipAddress);
	
	endRemoveRows();
	emit layoutChanged();
	return true;
}

// -----------------------------------------------------------------------------

void SipAddressesModel::handleChatRoomModelCreated (const QSharedPointer<ChatRoomModel> &chatRoomModel) {
	ChatRoomModel *ptr = chatRoomModel.get();
	
	QObject::connect(ptr, &ChatRoomModel::allEntriesRemoved, this, [this, ptr] {
		handleAllEntriesRemoved(ptr);
	});
	QObject::connect(ptr, &ChatRoomModel::lastEntryRemoved, this, [this, ptr] {
		handleLastEntryRemoved(ptr);
	});
	QObject::connect(ptr, &ChatRoomModel::messageCountReset, this, [this, ptr] {
		handleMessageCountReset(ptr);
	});
	
	QObject::connect(ptr, &ChatRoomModel::messageSent, this, &SipAddressesModel::handleMessageSent);
}

void SipAddressesModel::handleHistoryModelCreated (HistoryModel *historyModel) {
	QObject::connect(historyModel, &HistoryModel::callCountReset, this, [this] {
		handleAllCallCountReset();
	});
}

void SipAddressesModel::handleContactAdded (QSharedPointer<ContactModel> contact) {
	for (const auto &sipAddress : contact->getVcardModel()->getLinphoneSipAddresses()) {
		addOrUpdateSipAddress(Utils::coreStringToAppString(sipAddress->asStringUriOnly()), sipAddress, contact);
	}
}

void SipAddressesModel::handleContactRemoved (QSharedPointer<ContactModel> contact) {
	for (const auto &sipAddress : contact->getVcardModel()->getSipAddresses())
		removeContactOfSipAddress(sipAddress.toString());
}

void SipAddressesModel::handleContactUpdated (QSharedPointer<ContactModel> contact) {
	if(contact){
		for(auto entry : mPeerAddressToSipAddressEntry){
			if(entry.contact == contact)
				entry.contact = nullptr;
		}
		for (const auto &sipAddress : contact->getVcardModel()->getLinphoneSipAddresses()) {
			addOrUpdateSipAddress(Utils::coreStringToAppString(sipAddress->asStringUriOnly()), sipAddress, contact);
		}
	}
}

void SipAddressesModel::handleSipAddressAdded (QSharedPointer<ContactModel> contact, const QString &sipAddress) {
	ContactModel *mappedContact = mapSipAddressToContact(sipAddress);
	if (mappedContact) {
		qWarning() << "Unable to map sip address" << sipAddress << "to" << contact.get() << "- already used by" << mappedContact;
		return;
	}
	QString cleanedAddress = Utils::cleanSipAddress(sipAddress);
	addOrUpdateSipAddress(cleanedAddress, linphone::Factory::get()->createAddress(sipAddress.toStdString()), contact);
}

void SipAddressesModel::handleSipAddressRemoved (QSharedPointer<ContactModel> contact, const QString &sipAddress) {
	ContactModel *mappedContact = mapSipAddressToContact(sipAddress);
	if (contact.get() != mappedContact) {
		qWarning() << "Unable to remove sip address" << sipAddress << "of" << contact.get() << "- already used by" << mappedContact;
		return;
	}
	QString cleanedAddress = Utils::cleanSipAddress(sipAddress);
	removeContactOfSipAddress(cleanedAddress);
}

void SipAddressesModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &message) {
	auto lPeerAddress = message->getChatRoom()->getPeerAddress();
	const QString peerAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly()));
	addOrUpdateSipAddress(peerAddress, lPeerAddress, message);
}

void SipAddressesModel::handleMessagesReceived (const std::list<shared_ptr<linphone::ChatMessage>> &messages) {
	for(auto message: messages){
		auto lPeerAddress = message->getChatRoom()->getPeerAddress();
		const QString peerAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly()));
		addOrUpdateSipAddress(peerAddress, lPeerAddress, message);
	}
}

void SipAddressesModel::handleCallStateChanged (
		const shared_ptr<linphone::Call> &call,
		linphone::Call::State state
		) {
	auto lPeerAddress = call->getRemoteAddress();
	addOrUpdateSipAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly()), lPeerAddress, call);
}

void SipAddressesModel::handlePresenceReceived (
		const QString &sipAddress,
		const shared_ptr<const linphone::PresenceModel> &presenceModel
		) {
	Presence::PresenceStatus status;
	
	switch (presenceModel->getConsolidatedPresence()) {
		case linphone::ConsolidatedPresence::Online:
			status = Presence::PresenceStatus::Online;
			break;
		case linphone::ConsolidatedPresence::Busy:
			status = Presence::PresenceStatus::Busy;
			break;
		case linphone::ConsolidatedPresence::DoNotDisturb:
			status = Presence::PresenceStatus::DoNotDisturb;
			break;
		case linphone::ConsolidatedPresence::Offline:
			status = Presence::PresenceStatus::Offline;
			break;
	}
	QDateTime presenceTimestamp = QDateTime::fromMSecsSinceEpoch(presenceModel->getTimestamp()*1000);
	auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
	if (it != mPeerAddressToSipAddressEntry.end()) {
		qInfo() << QStringLiteral("Update presence of `%1`: %2.").arg(sipAddress).arg(status);
		it->presenceStatus = status;
		it->presenceTimestamp = presenceTimestamp;
		
		int row = mRefs.indexOf(&(*it));
		Q_ASSERT(row != -1);
		emit dataChanged(index(row, 0), index(row, 0));
	}
	
	updateObservers(sipAddress, status, presenceTimestamp);
}

void SipAddressesModel::handleAllEntriesRemoved (ChatRoomModel *chatRoomModel) {
	auto it = mPeerAddressToSipAddressEntry.find(chatRoomModel->getPeerAddress());
	if (it == mPeerAddressToSipAddressEntry.end())
		return;
	
	auto it2 = it->localAddressToConferenceEntry.find(Utils::cleanSipAddress(chatRoomModel->getLocalAddress()));
	if (it2 == it->localAddressToConferenceEntry.end())
		return;
	it->localAddressToConferenceEntry.erase(it2);
	
	int row = mRefs.indexOf(&(*it));
	Q_ASSERT(row != -1);
	
	// No history, no contact => Remove sip address from list.
	if (!it->contact && it->localAddressToConferenceEntry.empty()) {
		removeRow(row);
		return;
	}
	
	emit dataChanged(index(row, 0), index(row, 0));
}

void SipAddressesModel::handleLastEntryRemoved (ChatRoomModel *chatRoomModel) {
	auto it = mPeerAddressToSipAddressEntry.find(chatRoomModel->getPeerAddress());
	if (it == mPeerAddressToSipAddressEntry.end())
		return;
	
	auto it2 = it->localAddressToConferenceEntry.find(Utils::cleanSipAddress(chatRoomModel->getLocalAddress()));
	if (it2 == it->localAddressToConferenceEntry.end())
		return;
	
	int row = mRefs.indexOf(&(*it));
	Q_ASSERT(row != -1);
	
	Q_ASSERT(chatRoomModel->rowCount() > 0);
	const QVariantMap map = chatRoomModel->data(
				chatRoomModel->index(chatRoomModel->rowCount() - 1, 0),
				ChatRoomModel::ChatEntry
				).toMap();
	
	// Update the timestamp with the new last chat message timestamp.
	it2->timestamp = map["receivedTimestamp"].toDateTime();
	emit dataChanged(index(row, 0), index(row, 0));
}

void SipAddressesModel::handleAllCallCountReset () {
	for( auto peer = mPeerAddressToSipAddressEntry.begin() ; peer != mPeerAddressToSipAddressEntry.end() ; ++peer){
		for( auto local = peer->localAddressToConferenceEntry.begin() ; local != peer->localAddressToConferenceEntry.end() ; ++local){
			local->missedCallCount = 0;
			updateObservers(peer.key(), local.key(), local->unreadMessageCount, local->missedCallCount);
		}
		int row = mRefs.indexOf(&(*peer));
		emit dataChanged(index(row, 0), index(row, 0));
	}
}

void SipAddressesModel::handleMessageCountReset (ChatRoomModel *chatRoomModel) {
	const QString &peerAddress = Utils::cleanSipAddress(chatRoomModel->getPeerAddress());
	auto it = mPeerAddressToSipAddressEntry.find(peerAddress);
	if (it == mPeerAddressToSipAddressEntry.end())
		return;
	
	const QString &localAddress = Utils::cleanSipAddress(chatRoomModel->getLocalAddress());
	auto it2 = it->localAddressToConferenceEntry.find(localAddress);
	if (it2 == it->localAddressToConferenceEntry.end())
		return;
	
	it2->unreadMessageCount = 0;
	it2->missedCallCount = 0;
	
	int row = mRefs.indexOf(&(*it));
	Q_ASSERT(row != -1);
	emit dataChanged(index(row, 0), index(row, 0));
	
	updateObservers(peerAddress, localAddress, 0, 0);
}

void SipAddressesModel::handleMessageSent (const shared_ptr<linphone::ChatMessage> &message) {
	if(message->getChatRoom() && message->getChatRoom()->getPeerAddress()){
		auto lPeerAddress = message->getChatRoom()->getPeerAddress();
		const QString peerAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly()));
		addOrUpdateSipAddress(peerAddress, lPeerAddress, message);
	}
}

void SipAddressesModel::handleIsComposingChanged (const shared_ptr<linphone::ChatRoom> &chatRoom) {
	auto it = mPeerAddressToSipAddressEntry.find(Utils::cleanSipAddress(Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly())));
	if (it == mPeerAddressToSipAddressEntry.end())
		return;
	
	auto it2 = it->localAddressToConferenceEntry.find(
				Utils::cleanSipAddress(Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly()))
				);
	if (it2 == it->localAddressToConferenceEntry.end())
		return;
	
	it2->isComposing = chatRoom->isRemoteComposing();
	
	int row = mRefs.indexOf(&(*it));
	Q_ASSERT(row != -1);
	emit dataChanged(index(row, 0), index(row, 0));
}
// -----------------------------------------------------------------------------

void SipAddressesModel::addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, QSharedPointer<ContactModel> contact) {
	const QString &sipAddress = sipAddressEntry.sipAddress;
	
	sipAddressEntry.contact = contact;
	if (!sipAddressEntry.contact) {
		qDebug() << QStringLiteral("`contact` field is empty on sip address: `%1`.").arg(sipAddress);
		sipAddressEntry.displayNames.mFromContact = "";
	}else if(contact->getVcardModel())
		sipAddressEntry.displayNames.mFromContact = contact->getVcardModel()->getUsername();
	else
		sipAddressEntry.displayNames.mFromContact = "";
	
	updateObservers(sipAddress, contact);
}

void SipAddressesModel::addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, const shared_ptr<linphone::Call> &call) {
	const shared_ptr<linphone::CallLog> callLog = call->getCallLog();
	auto lPeerAddress = callLog->getRemoteAddress();
	QString localAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(callLog->getLocalAddress()->asStringUriOnly())));
	QString peerAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly())));
	ConferenceEntry &conferenceEntry = sipAddressEntry.localAddressToConferenceEntry[
			localAddress
			];
	
	qInfo() << QStringLiteral("Update (`%1`, `%2`) from chat call.").arg(sipAddressEntry.sipAddress, localAddress);
	
	conferenceEntry.timestamp = callLog->getStatus() == linphone::Call::Status::Success
			? QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000)
			: QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
	conferenceEntry.missedCallCount = CoreManager::getInstance()->getMissedCallCount(peerAddress, localAddress);
	QString oldDisplayName = sipAddressEntry.displayNames.get();
	sipAddressEntry.displayNames.updateFromCall(lPeerAddress);
	if(oldDisplayName != sipAddressEntry.displayNames.get())
		emit CoreManager::getInstance()->getContactsListModel()->contactUpdated(nullptr);
	updateObservers(sipAddressEntry.sipAddress, localAddress, conferenceEntry.unreadMessageCount,conferenceEntry.missedCallCount);
}

void SipAddressesModel::addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, const shared_ptr<linphone::ChatMessage> &message) {
	shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
	auto settingsModel = CoreManager::getInstance()->getSettingsModel();
	int count = 0;
	if (chatRoom->getCurrentParams()->getEncryptionBackend() == linphone::ChatRoom::EncryptionBackend::None && !settingsModel->getStandardChatEnabled()
			|| chatRoom->getCurrentParams()->getEncryptionBackend() != linphone::ChatRoom::EncryptionBackend::None && !settingsModel->getSecureChatEnabled())	
		count = chatRoom->getUnreadMessagesCount();
	auto lPeerAddress = chatRoom->getPeerAddress();
	QString localAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly())));
	QString peerAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly())));
	qInfo() << QStringLiteral("Update (`%1`, `%2`) from chat message.").arg(sipAddressEntry.sipAddress, localAddress);
	
	ConferenceEntry &conferenceEntry = sipAddressEntry.localAddressToConferenceEntry[localAddress];
	conferenceEntry.timestamp = QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000);
	conferenceEntry.unreadMessageCount = count ;
	conferenceEntry.missedCallCount = CoreManager::getInstance()->getMissedCallCount(peerAddress, localAddress);
	sipAddressEntry.displayNames.updateFromChatMessage(lPeerAddress);
	updateObservers(sipAddressEntry.sipAddress, localAddress, count,conferenceEntry.missedCallCount);
}

template<typename T>
void SipAddressesModel::addOrUpdateSipAddress (const QString &sipAddress, const std::shared_ptr<const linphone::Address> peerAddress, T data) {
	auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
	if (it != mPeerAddressToSipAddressEntry.end()) {
		addOrUpdateSipAddress(*it, data);
		
		int row = mRefs.indexOf(&(*it));
		Q_ASSERT(row != -1);
		emit dataChanged(index(row, 0), index(row, 0));
		
		return;
	}
	
	SipAddressEntry sipAddressEntry{ sipAddress, nullptr, Presence::Offline, {}, {}, DisplayNames(peerAddress) };
	addOrUpdateSipAddress(sipAddressEntry, data);
	
	int row = mRefs.count();
	beginInsertRows(QModelIndex(), row, row);
	
	mPeerAddressToSipAddressEntry[sipAddress] = move(sipAddressEntry);
	mRefs << &mPeerAddressToSipAddressEntry[sipAddress];
	
	endInsertRows();
	emit dataChanged(QModelIndex(), index(row,0));
}

// -----------------------------------------------------------------------------

void SipAddressesModel::removeContactOfSipAddress (const QString &sipAddress) {
	auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
	if (it == mPeerAddressToSipAddressEntry.end()) {
		qWarning() << QStringLiteral("Unable to remove unavailable sip address: `%1`.").arg(sipAddress);
		return;
	}
	
	// Try to map other contact on this sip address.
	auto contactModel = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(sipAddress);
	updateObservers(sipAddress, contactModel);
	
	qInfo() << QStringLiteral("Map new contact on sip address: `%1`.").arg(sipAddress) << contactModel.get();
	addOrUpdateSipAddress(*it, contactModel);
	
	int row = mRefs.indexOf(&(*it));
	Q_ASSERT(row != -1);
	
	// History or contact exists, signal changes.
	if (!it->localAddressToConferenceEntry.empty() || contactModel) {
		emit dataChanged(index(row, 0), index(row, 0));
		return;
	}
	
	// Remove sip address if no history.
	removeRow(row);
}

// -----------------------------------------------------------------------------

void SipAddressesModel::initSipAddresses () {
	QElapsedTimer timer, stepsTimer;
	timer.start();
	
	stepsTimer.start();
	initSipAddressesFromChat();
	qInfo() << "Sip addresses model from Chats :" << stepsTimer.restart() << "ms.";
	initSipAddressesFromCalls();
	qInfo() << "Sip addresses model from Calls :" << stepsTimer.restart() << "ms.";
	initSipAddressesFromContacts();
	qInfo() << "Sip addresses model from Contacts :" << stepsTimer.restart() << "ms.";
	mRefs.clear();
	initRefs();
	qInfo() << "Sip addresses model init Refs :" << stepsTimer.restart() << "ms.";
	qInfo() << "Sip addresses model initialized in:" << timer.elapsed() << "ms.";
}

void SipAddressesModel::initSipAddressesFromChat () {
	for (const auto &chatRoom : CoreManager::getInstance()->getCore()->getChatRooms()) {
		auto lastMessage = chatRoom->getLastMessageInHistory();
		if( !lastMessage)
			continue;
		auto lPeerAddress = chatRoom->getPeerAddress();
		QString peerAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly())));
		QString localAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly())));
		
		getSipAddressEntry(peerAddress, lPeerAddress)->localAddressToConferenceEntry[localAddress] = {
			chatRoom->getUnreadMessagesCount(),
			CoreManager::getInstance()->getMissedCallCount(peerAddress, localAddress),
			false,
			QDateTime::fromMSecsSinceEpoch(lastMessage->getTime() * 1000)
		};
	}
}

void SipAddressesModel::initSipAddressesFromCalls () {
	using ConferenceId = QPair<QString, QString>;
	QSet<ConferenceId> conferenceDone;
	for (const auto &callLog : CoreManager::getInstance()->getCore()->getCallLogs()) {
		auto lPeerAddress = callLog->getRemoteAddress();
		const QString peerAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(lPeerAddress->asStringUriOnly())));
		const QString localAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(callLog->getLocalAddress()->asStringUriOnly())));
		
		
		ConferenceId conferenceId{ peerAddress, localAddress };
		if (conferenceDone.contains(conferenceId))
			continue; // Already used.
		conferenceDone << conferenceId;
		
		// The duration can be wrong if status is not success.
		QDateTime timestamp(callLog->getStatus() == linphone::Call::Status::Success
							? QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000)
							: QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000));
		
		auto sipAddressEntry = getSipAddressEntry(peerAddress, lPeerAddress);
		auto &localToConferenceEntry = sipAddressEntry->localAddressToConferenceEntry;
		auto it = localToConferenceEntry.find(localAddress);
		if (it == localToConferenceEntry.end()) {
			localToConferenceEntry[localAddress] = { 0,0, false, move(timestamp) };
			sipAddressEntry->displayNames.mFromCallLogs = QString::fromStdString(callLog->getRemoteAddress()->getDisplayName());
		}else if (it->timestamp.isNull() || timestamp > it->timestamp){
			it->timestamp = move(timestamp);
			sipAddressEntry->displayNames.mFromCallLogs = QString::fromStdString(callLog->getRemoteAddress()->getDisplayName());
		}
	}
}

void SipAddressesModel::initSipAddressesFromContacts () {
	for (auto &contact : CoreManager::getInstance()->getContactsListModel()->mList)
		handleContactAdded(contact.objectCast<ContactModel>());
}

void SipAddressesModel::initRefs () {
	for (const auto &sipAddressEntry : mPeerAddressToSipAddressEntry)
		mRefs << &sipAddressEntry;
}

// -----------------------------------------------------------------------------

void SipAddressesModel::updateObservers (const QString &sipAddress, QSharedPointer<ContactModel> contact) {
	for (auto &observer : mObservers.values(sipAddress))
		observer->setContact(contact);
}

void SipAddressesModel::updateObservers (const QString &sipAddress, const Presence::PresenceStatus &presenceStatus, const QDateTime &presenceTimestamp) {
	for (auto &observer : mObservers.values(sipAddress)){
		observer->setPresenceStatus(presenceStatus);
		observer->setPresenceTimestamp(presenceTimestamp);
	}
}

void SipAddressesModel::updateObservers (const QString &peerAddress, const QString &localAddress, int messageCount, int missedCallCount) {
	for (auto &observer : mObservers.values(peerAddress)) {
		if (observer->getLocalAddress() == localAddress) {
			observer->setUnreadMessageCount(messageCount+missedCallCount);
			return;
		}
	}
}
