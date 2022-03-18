﻿/*
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

#include "ChatRoomModel.hpp"

#include <algorithm>

#include <QDateTime>
#include <QDesktopServices>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QTimer>
#include <QUuid>
#include <QMessageBox>
#include <QUrlQuery>
#include <QImageReader>
#include <qqmlapplicationengine.h>

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "app/providers/ThumbnailProvider.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/chat/ChatModel.hpp"
#include "components/chat-events/ChatCallModel.hpp"
#include "components/chat-events/ChatEvent.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/chat-events/ChatNoticeModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/content/ContentListModel.hpp"
#include "components/content/ContentModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/participant/ParticipantModel.hpp"
#include "components/participant/ParticipantListModel.hpp"
#include "components/presence/Presence.hpp"
#include "components/recorder/RecorderManager.hpp"
#include "components/recorder/RecorderModel.hpp"
#include "components/timeline/TimelineModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "components/core/event-count-notifier/AbstractEventCountNotifier.hpp"
#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "utils/LinphoneEnums.hpp"



// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------


ChatRoomModelListener::ChatRoomModelListener(ChatRoomModel * model, QObject* parent) : QObject(parent){
	connect(this, &ChatRoomModelListener::isComposingReceived, model, &ChatRoomModel::onIsComposingReceived);
	connect(this, &ChatRoomModelListener::messageReceived, model, &ChatRoomModel::onMessageReceived);
	connect(this, &ChatRoomModelListener::newEvent, model, &ChatRoomModel::onNewEvent);
	connect(this, &ChatRoomModelListener::chatMessageReceived, model, &ChatRoomModel::onChatMessageReceived);
	connect(this, &ChatRoomModelListener::chatMessageSending, model, &ChatRoomModel::onChatMessageSending);
	connect(this, &ChatRoomModelListener::chatMessageSent, model, &ChatRoomModel::onChatMessageSent);
	connect(this, &ChatRoomModelListener::participantAdded, model, &ChatRoomModel::onParticipantAdded);
	connect(this, &ChatRoomModelListener::participantRemoved, model, &ChatRoomModel::onParticipantRemoved);
	connect(this, &ChatRoomModelListener::participantAdminStatusChanged, model, &ChatRoomModel::onParticipantAdminStatusChanged);
	connect(this, &ChatRoomModelListener::stateChanged, model, &ChatRoomModel::onStateChanged);
	connect(this, &ChatRoomModelListener::securityEvent, model, &ChatRoomModel::onSecurityEvent);
	connect(this, &ChatRoomModelListener::subjectChanged, model, &ChatRoomModel::onSubjectChanged);
	connect(this, &ChatRoomModelListener::undecryptableMessageReceived, model, &ChatRoomModel::onUndecryptableMessageReceived);
	connect(this, &ChatRoomModelListener::participantDeviceAdded, model, &ChatRoomModel::onParticipantDeviceAdded);
	connect(this, &ChatRoomModelListener::participantDeviceRemoved, model, &ChatRoomModel::onParticipantDeviceRemoved);
	connect(this, &ChatRoomModelListener::conferenceJoined, model, &ChatRoomModel::onConferenceJoined);
	connect(this, &ChatRoomModelListener::conferenceLeft, model, &ChatRoomModel::onConferenceLeft);
	connect(this, &ChatRoomModelListener::ephemeralEvent, model, &ChatRoomModel::onEphemeralEvent);
	connect(this, &ChatRoomModelListener::ephemeralMessageTimerStarted, model, &ChatRoomModel::onEphemeralMessageTimerStarted);
	connect(this, &ChatRoomModelListener::ephemeralMessageDeleted, model, &ChatRoomModel::onEphemeralMessageDeleted);
	connect(this, &ChatRoomModelListener::conferenceAddressGeneration, model, &ChatRoomModel::onConferenceAddressGeneration);
	connect(this, &ChatRoomModelListener::participantRegistrationSubscriptionRequested, model, &ChatRoomModel::onParticipantRegistrationSubscriptionRequested);
	connect(this, &ChatRoomModelListener::participantRegistrationUnsubscriptionRequested, model, &ChatRoomModel::onParticipantRegistrationUnsubscriptionRequested);
	connect(this, &ChatRoomModelListener::chatMessageShouldBeStored, model, &ChatRoomModel::onChatMessageShouldBeStored);
	connect(this, &ChatRoomModelListener::chatMessageParticipantImdnStateChanged, model, &ChatRoomModel::onChatMessageParticipantImdnStateChanged);
}

void ChatRoomModelListener::onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing){
	emit isComposingReceived(chatRoom, remoteAddress, isComposing);
}
void ChatRoomModelListener::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	emit messageReceived(chatRoom, message);
}
void ChatRoomModelListener::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit newEvent(chatRoom, eventLog);
}
void ChatRoomModelListener::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit chatMessageReceived(chatRoom, eventLog);
}
void ChatRoomModelListener::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit chatMessageSending(chatRoom, eventLog);
}
void ChatRoomModelListener::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit chatMessageSent(chatRoom, eventLog);
}
void ChatRoomModelListener::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantAdded(chatRoom, eventLog);
}
void ChatRoomModelListener::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantRemoved(chatRoom, eventLog);
}
void ChatRoomModelListener::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantAdminStatusChanged(chatRoom, eventLog);
}
void ChatRoomModelListener::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){
	emit stateChanged(chatRoom, newState);
}
void ChatRoomModelListener::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit securityEvent(chatRoom, eventLog);
}
void ChatRoomModelListener::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit subjectChanged(chatRoom, eventLog);
}
void ChatRoomModelListener::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	emit undecryptableMessageReceived(chatRoom, message);
}
void ChatRoomModelListener::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantDeviceAdded(chatRoom, eventLog);
}
void ChatRoomModelListener::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantDeviceRemoved(chatRoom, eventLog);
}
void ChatRoomModelListener::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit conferenceJoined(chatRoom, eventLog);
}
void ChatRoomModelListener::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit conferenceLeft(chatRoom, eventLog);
}
void ChatRoomModelListener::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit ephemeralEvent(chatRoom, eventLog);
}
void ChatRoomModelListener::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit ephemeralMessageTimerStarted(chatRoom, eventLog);
}
void ChatRoomModelListener::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit ephemeralMessageDeleted(chatRoom, eventLog);
}
void ChatRoomModelListener::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom){
	emit conferenceAddressGeneration(chatRoom);
}
void ChatRoomModelListener::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationSubscriptionRequested(chatRoom, participantAddress);
}
void ChatRoomModelListener::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationUnsubscriptionRequested(chatRoom, participantAddress);
}
void ChatRoomModelListener::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	emit chatMessageShouldBeStored(chatRoom, message);
}
void ChatRoomModelListener::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	emit chatMessageParticipantImdnStateChanged(chatRoom, message, state);
}

// -----------------------------------------------------------------------------
std::shared_ptr<ChatRoomModel> ChatRoomModel::create(std::shared_ptr<linphone::ChatRoom> chatRoom){
	std::shared_ptr<ChatRoomModel> model = std::make_shared<ChatRoomModel>(chatRoom);
	if(model){
		model->mSelf = model;
		 //chatRoom->addListener(model);
		return model;
	}else
		return nullptr;
}

ChatRoomModel::ChatRoomModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject * parent) : QAbstractListModel(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	CoreManager *coreManager = CoreManager::getInstance();
	mCoreHandlers = coreManager->getHandlers();
	
	mChatRoom = chatRoom;
	mChatRoomModelListener = std::make_shared<ChatRoomModelListener>(this, parent);
	mChatRoom->addListener(mChatRoomModelListener);	
	
	// Get messages.
	mEntries.clear();
	
	setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
	setMissedCallsCount(0);
	
	QElapsedTimer timer;
	timer.start();
	CoreHandlers *coreHandlers = mCoreHandlers.get();
	QObject::connect(this, &ChatRoomModel::messageSent, this, &ChatRoomModel::resetMessageCount);
	//QObject::connect(coreHandlers, &CoreHandlers::messageReceived, this, &ChatRoomModel::handleMessageReceived);
	QObject::connect(coreHandlers, &CoreHandlers::callCreated, this, &ChatRoomModel::handleCallCreated);
	QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &ChatRoomModel::handleCallStateChanged);
	QObject::connect(coreHandlers, &CoreHandlers::presenceStatusReceived, this, &ChatRoomModel::handlePresenceStatusReceived);
		//QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &ChatRoomModel::handleIsComposingChanged);

	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactAdded, this, &ChatRoomModel::fullPeerAddressChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactAdded, this, &ChatRoomModel::avatarChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactRemoved, this, &ChatRoomModel::fullPeerAddressChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactRemoved, this, &ChatRoomModel::avatarChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactUpdated, this, &ChatRoomModel::fullPeerAddressChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactUpdated, this, &ChatRoomModel::avatarChanged);

	connect(this, &ChatRoomModel::fullPeerAddressChanged, this, &ChatRoomModel::usernameChanged);
	

	//QObject::connect(this, &ChatRoomModel::messageCountReset, coreManager, &CoreManager::eventCountChanged  );
	if(mChatRoom){
		mParticipantListModel = std::make_shared<ParticipantListModel>(this);
		connect(mParticipantListModel.get(), &ParticipantListModel::participantsChanged, this, &ChatRoomModel::fullPeerAddressChanged);
		auto participants = mChatRoom->getParticipants();	
		for(auto participant : participants){
			auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((participant)->getAddress()->asString()));
			if(contact) {
				connect(contact, &ContactModel::contactUpdated, this, &ChatRoomModel::fullPeerAddressChanged);
			}
		}
		
	}else
		mParticipantListModel = nullptr;
	
}

ChatRoomModel::~ChatRoomModel () {
	mParticipantListModel = nullptr;
	if(mChatRoom ){
		mChatRoom->removeListener(mChatRoomModelListener);
		if(mDeleteChatRoom){
			mDeleteChatRoom = false;
			if(CoreManager::getInstance()->getCore() ){
				auto participants = mChatRoom->getParticipants();
				std::list<std::shared_ptr<linphone::Address>> participantsAddress;
				for(auto p : participants)
					participantsAddress.push_back(p->getAddress()->clone());
				auto internalChatRoom = CoreManager::getInstance()->getCore()->searchChatRoom(mChatRoom->getCurrentParams(), mChatRoom->getLocalAddress(), mChatRoom->getPeerAddress(), participantsAddress);
				if( internalChatRoom)
					CoreManager::getInstance()->getCore()->deleteChatRoom(internalChatRoom);
			}
		}
	}
	mChatRoom = nullptr;
}

QHash<int, QByteArray> ChatRoomModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Roles::ChatEntry] = "$chatEntry";
	roles[Roles::SectionDate] = "$sectionDate";
	return roles;
}

int ChatRoomModel::rowCount (const QModelIndex &) const {
	return mEntries.count();
}

QVariant ChatRoomModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mEntries.count())
		return QVariant();
	
	switch (role) {
		case Roles::ChatEntry: {
			ChatEvent * ce = mEntries[row].get();
			if( ce->mType == EntryType::MessageEntry)
				return QVariant::fromValue(dynamic_cast<ChatMessageModel*>(ce));
			else if( ce->mType == EntryType::NoticeEntry)
				return QVariant::fromValue(dynamic_cast<ChatNoticeModel*>(ce));
			else if( ce->mType == EntryType::CallEntry)
				return QVariant::fromValue(dynamic_cast<ChatCallModel*>(ce));
			else
				return QVariant();
		}
		case Roles::SectionDate:
			return QVariant::fromValue(mEntries[row]->getTimestamp().date());
	}
	
	return QVariant();
}

bool ChatRoomModel::removeRow (int row, const QModelIndex &) {
	return removeRows(row, 1);
}

bool ChatRoomModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mEntries.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i) {
		mEntries[row]->deleteEvent();
		mEntries.removeAt(row);
	}
	
	endRemoveRows();
	
	if (mEntries.count() == 0)
		emit allEntriesRemoved(mSelf.lock());
	else if (limit == mEntries.count())
		emit lastEntryRemoved();
	emit focused();// Removing rows is like having focus. Don't wait asynchronous events.
	return true;
}

void ChatRoomModel::removeAllEntries () {
	qInfo() << QStringLiteral("Removing all entries of: (%1, %2).")
			   .arg(getPeerAddress()).arg(getLocalAddress());
	auto core = CoreManager::getInstance()->getCore();
	bool standardChatEnabled = CoreManager::getInstance()->getSettingsModel()->getStandardChatEnabled();
	beginResetModel();
	mEntries.clear();
	mChatRoom->deleteHistory();
	if( isOneToOne() && // Remove calls only if chat room is one-one and not secure (if available)
		( !standardChatEnabled || !isSecure())
		) {
		auto callLogs = CallsListModel::getCallHistory(getParticipantAddress(), Utils::coreStringToAppString(mChatRoom->getLocalAddress()->asStringUriOnly()));
		bool haveLogs = callLogs.size() > 0;
		for(auto callLog : callLogs)
			core->removeCallLog(callLog);
		if(haveLogs)
			emit CoreManager::getInstance()->callLogsCountChanged();
	}
	endResetModel();
	emit allEntriesRemoved(mSelf.lock());
	emit focused();// Removing all entries is like having focus. Don't wait asynchronous events.
}

void ChatRoomModel::removeEntry(ChatEvent* entry){
	auto it = mEntries.begin();
	while(it != mEntries.end() && (*it).get() != entry)
		++it;
	if( it != mEntries.end() ){
		int row = it - mEntries.begin();
		 //mEntries.indexOf(entry);
		if(row >=0)
			removeRow(row);
	}
}

void ChatRoomModel::emitFullPeerAddressChanged(){
	emit fullPeerAddressChanged();
}
//--------------------------------------------------------------------------------------------

QString ChatRoomModel::getPeerAddress () const {
	return mChatRoom && mChatRoom->getPeerAddress() ? Utils::coreStringToAppString(mChatRoom->getPeerAddress()->asStringUriOnly()) : "";
}

QString ChatRoomModel::getLocalAddress () const {
	if(!mChatRoom)
		return "";
		else {
	
		auto localAddress = mChatRoom->getLocalAddress()->clone();
		localAddress->clean();
		return Utils::coreStringToAppString(
					localAddress->asStringUriOnly()
					);
		}
}

QString ChatRoomModel::getFullPeerAddress () const {
	return mChatRoom ? Utils::coreStringToAppString(mChatRoom->getPeerAddress()->asString()) : "";
}

QString ChatRoomModel::getFullLocalAddress () const {
	return mChatRoom ? Utils::coreStringToAppString(mChatRoom->getLocalAddress()->asString()) : "";
}

QString ChatRoomModel::getConferenceAddress () const {
	if(!mChatRoom)
		return "";
	else {
		auto address = mChatRoom->getConferenceAddress();
		return address?Utils::coreStringToAppString(address->asString()):"";
	}
}

QString ChatRoomModel::getSubject () const {
	return mChatRoom ? QString::fromStdString(mChatRoom->getSubject()) : "";	// in UTF8
}

QString ChatRoomModel::getUsername () const {
	QString username;
	if( !mChatRoom)
		return "";
	if( !isOneToOne())
		username = QString::fromStdString(mChatRoom->getSubject());
	
	if(username != "")
		return username;
	if(  mChatRoom->getNbParticipants() == 1 ) {
		auto call = mChatRoom->getCall();
		if(call)
			username = Utils::getDisplayName(call->getRemoteAddress());
		if(username != "")
			return username;
	}
	if(  mChatRoom->getNbParticipants() >= 1)
		username = mParticipantListModel->displayNamesToString();
	if(username != "")
		return username;
	if(haveEncryption() || isGroupEnabled())
		return "";// Wait for more info
	username = Utils::getDisplayName(mChatRoom->getPeerAddress());
	if(username != "")
		return username;
	auto addr = mChatRoom->getPeerAddress();
	if( addr)
		return Utils::coreStringToAppString(addr->asStringUriOnly());
	else {
		qWarning() << "ChatRoom has no peer address or address is invalid : Subject=" << mChatRoom->getSubject().c_str() 
			<< ", created at " << QDateTime::fromSecsSinceEpoch(mChatRoom->getCreationTime())
			<< " (" << mChatRoom.get() << ")";
		return "";
	}
}

QString ChatRoomModel::getAvatar () const {
	if( mChatRoom && mChatRoom->getNbParticipants() == 1){
		auto participants = mChatRoom->getParticipants();	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((*participants.begin())->getAddress()->asString()));
		if(contact)
			return contact->getVcardModel()->getAvatar();
	}
	return "";
}

int ChatRoomModel::getPresenceStatus() const {
	if( mChatRoom && mChatRoom->getNbParticipants() == 1 && !isGroupEnabled()){
		auto participants = mChatRoom->getParticipants();	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((*participants.begin())->getAddress()->asString()));
		if(contact) {
			return contact->getPresenceLevel();
		}
		else
			return -1;
	}else
		return -1;
}

ParticipantListModel* ChatRoomModel::getParticipants() const{
	return mParticipantListModel.get();
}

int ChatRoomModel::getState() const {
	return mChatRoom ? (int)mChatRoom->getState() : 0;	
}

bool ChatRoomModel::isReadOnly() const{
	return mChatRoom && mChatRoom->isReadOnly();	
}

bool ChatRoomModel::isEphemeralEnabled() const{
	return mChatRoom && mChatRoom->ephemeralEnabled();
}

long ChatRoomModel::getEphemeralLifetime() const{
	return mChatRoom ? mChatRoom->getEphemeralLifetime() : 0;
}

bool ChatRoomModel::canBeEphemeral(){
	return isConference();
}

bool ChatRoomModel::haveEncryption() const{
	return mChatRoom && mChatRoom->getCurrentParams()->getEncryptionBackend() != linphone::ChatRoomEncryptionBackend::None;
}

bool ChatRoomModel::markAsReadEnabled() const{
	return mMarkAsReadEnabled;
}

bool ChatRoomModel::isSecure() const{
	return mChatRoom && (mChatRoom->getSecurityLevel() == linphone::ChatRoomSecurityLevel::Encrypted
			|| mChatRoom->getSecurityLevel() == linphone::ChatRoomSecurityLevel::Safe);
}

int ChatRoomModel::getSecurityLevel() const{
	return mChatRoom ? (int)mChatRoom->getSecurityLevel() : 0;
}

bool ChatRoomModel::isGroupEnabled() const{
	return mChatRoom && mChatRoom->getCurrentParams()->groupEnabled(); 
}

bool ChatRoomModel::isConference() const{
	return mChatRoom && mChatRoom->hasCapability((int)linphone::ChatRoomCapabilities::Conference);
}

bool ChatRoomModel::isOneToOne() const{
	return mChatRoom && mChatRoom->hasCapability((int)linphone::ChatRoomCapabilities::OneToOne);
}

bool ChatRoomModel::isMeAdmin() const{
	return mChatRoom->getMe()->isAdmin();
}

bool ChatRoomModel::isCurrentProxy() const{
	return mChatRoom->getLocalAddress()->weakEqual(CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddress());
}

bool ChatRoomModel::canHandleParticipants() const{
	return mChatRoom->canHandleParticipants();
}

bool ChatRoomModel::getIsRemoteComposing () const {
	return mComposers.size() > 0;
}

bool ChatRoomModel::isEntriesLoading() const{
	return mEntriesLoading;
}

bool ChatRoomModel::isBasic() const{
	return mChatRoom && mChatRoom->hasCapability((int)linphone::ChatRoomCapabilities::Basic);
}

std::shared_ptr<linphone::ChatRoom> ChatRoomModel::getChatRoom(){
	return mChatRoom;
}

QList<QString> ChatRoomModel::getComposers(){
	return mComposers.values();
}

QString ChatRoomModel::getParticipantAddress(){
	if(!isSecure()){
		auto peerAddress = mChatRoom->getPeerAddress();
		if( peerAddress)
			return Utils::coreStringToAppString(peerAddress->asString());
		else if(isConference()){
			auto conferenceAddress = mChatRoom->getConferenceAddress();
			if( conferenceAddress)
				return Utils::coreStringToAppString(conferenceAddress->asString());
			else{
				qWarning() << "ConferenceAddress is NULL when requesting it from not secure and conference ChatRoomModel. Subject=" << mChatRoom->getSubject().c_str() 
					<< ", created at " << QDateTime::fromSecsSinceEpoch(mChatRoom->getCreationTime())
					<< " (" << mChatRoom.get() << ")";
				return "";
			}
		}else {
			qWarning() << "PeerAddress is NULL when requesting it from not secure ChatRoomModel. Subject=" << mChatRoom->getSubject().c_str()
				<< ", created at " << QDateTime::fromSecsSinceEpoch(mChatRoom->getCreationTime())
				<< " (" << mChatRoom.get() << ")";
			return "";
		}
	}else{
		auto participants = getParticipants();
		if(participants->getCount() > 1)
			return participants->getAt(1)->getSipAddress();
		else
			return "";
	}	
}

int ChatRoomModel::getAllUnreadCount(){
	return mUnreadMessagesCount + mMissedCallsCount;
}

//------------------------------------------------------------------------------------------------

void ChatRoomModel::setSubject(QString& subject){
	if(mChatRoom && getSubject() != subject){
		mChatRoom->setSubject(subject.toUtf8().toStdString());	// in UTF8
		emit subjectChanged(subject);
	}
}

void ChatRoomModel::setLastUpdateTime(const QDateTime& lastUpdateDate) {
	if(mLastUpdateTime != lastUpdateDate ) {
		mLastUpdateTime = lastUpdateDate;
		emit lastUpdateTimeChanged();
	}	
}

void ChatRoomModel::updateLastUpdateTime(){
	if( mChatRoom ){
		QDateTime lastDateTime = QDateTime::fromMSecsSinceEpoch(mChatRoom->getLastUpdateTime()*1000);
		QDateTime lastCallTime = lastDateTime;
		for(auto e : mEntries){
			if(e->mType == CallEntry && e->getTimestamp() > lastCallTime)
				lastCallTime = e->getTimestamp();
		}	
		setLastUpdateTime(lastCallTime);
	}
}

void ChatRoomModel::setUnreadMessagesCount(const int& count){
	updateNewMessageNotice(count);
	if(count != mUnreadMessagesCount){
		mUnreadMessagesCount = count;
		emit unreadMessagesCountChanged();
	}
}

void ChatRoomModel::setMissedCallsCount(const int& count){
	if(count != mMissedCallsCount){
		mMissedCallsCount = count;
		emit missedCallsCountChanged();
	}
}

void ChatRoomModel::addMissedCallsCount(std::shared_ptr<linphone::Call> call){
	insertCall(call->getCallLog());
	auto timeline = CoreManager::getInstance()->getTimelineListModel()->getTimeline(mChatRoom, false);
	if(!timeline || !timeline->mSelected){
		setMissedCallsCount(mMissedCallsCount+1);
		CoreManager::getInstance()->getEventCountNotifier()->handleCallMissed(&call->getData<CallModel>("call-model"));
	}
}

void ChatRoomModel::setEphemeralEnabled(bool enabled){
	if(isEphemeralEnabled() != enabled){
		mChatRoom->enableEphemeral(enabled);
		emit ephemeralEnabledChanged();
	}
}

void ChatRoomModel::setEphemeralLifetime(long lifetime){
	if(getEphemeralLifetime() != lifetime){
		mChatRoom->setEphemeralLifetime(lifetime);
		emit ephemeralLifetimeChanged();
	}
}

void ChatRoomModel::enableMarkAsRead(const bool& enable){
	if( mMarkAsReadEnabled != enable){
		mMarkAsReadEnabled = enable;
		emit markAsReadEnabledChanged();
	}
}

void ChatRoomModel::setReply(ChatMessageModel * model){
	if(model != mReplyModel.get()){
		if( model && model->getChatMessage() )
			mReplyModel = ChatMessageModel::create(model->getChatMessage(), this);
		else
			mReplyModel = nullptr;
		emit replyChanged();
	}
}

ChatMessageModel * ChatRoomModel::getReply()const{
	return mReplyModel.get();
}

//------------------------------------------------------------------------------------------------

void ChatRoomModel::deleteChatRoom(){
	mDeleteChatRoom = true;
}

void ChatRoomModel::leaveChatRoom (){
	if(mChatRoom)
		mChatRoom->leave();
}


void ChatRoomModel::updateParticipants(const QVariantList& participants){
	/*
	std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
	std::list <shared_ptr<linphone::Address> > chatRoomParticipants;
	std::shared_ptr<const linphone::Address> localAddress;
	for(auto p : participants){
		ParticipantModel* participant = p.value<ParticipantModel*>();
		auto address = Utils::interpretUrl(participant->getSipAddress());
		if( address)
			chatRoomParticipants.push_back( address );
	}
	if(mChatRoom->canHandleParticipants()) {
		mChatRoom->addParticipants(newParticipants);
		mChatRoom->removeParticipants(removeParticipants);
	}
	
	linphone::ChatRoom;*/
}

// -----------------------------------------------------------------------------



// -----------------------------------------------------------------------------

void ChatRoomModel::sendMessage (const QString &message) {
	std::list<shared_ptr<linphone::ChatMessage> > _messages;
	bool isBasicChatRoom = isBasic();
	if(mReplyModel && mReplyModel->getChatMessage()) {
		_messages.push_back(mChatRoom->createReplyMessage(mReplyModel->getChatMessage()));
	}else
		 _messages.push_back(mChatRoom->createEmptyMessage());
	auto recorder = CoreManager::getInstance()->getRecorderManager();
	if(recorder->haveVocalRecorder()) {
		recorder->getVocalRecorder()->stop();
		auto content = recorder->getVocalRecorder()->getRecorder()->createContent();
		if(content) {
			_messages.back()->addContent(content);
		}
	}
	auto fileContents = CoreManager::getInstance()->getChatModel()->getContentListModel()->getContents();
	for(auto content : fileContents){
		if(isBasicChatRoom && _messages.back()->getContents().size() > 0)	// Basic chat rooms don't support multipart
			_messages.push_back(mChatRoom->createEmptyMessage());
		_messages.back()->addFileContent(content->getContent());
	}
	if(!message.isEmpty()) {
		if(isBasicChatRoom && _messages.back()->getContents().size() > 0)	// Basic chat rooms don't support multipart
			_messages.push_back(mChatRoom->createEmptyMessage());
		_messages.back()->addUtf8TextContent(message.toUtf8().toStdString());
	}
	bool sent = false;
	for(auto itMessage = _messages.begin() ; itMessage != _messages.end() ; ++itMessage) {
		if((*itMessage)->getContents().size() > 0){// Have something to send
			(*itMessage)->send();
			emit messageSent((*itMessage));
			sent = true;
		}
	}
	if(sent){
		setReply(nullptr);
		if(recorder->haveVocalRecorder())
			recorder->clearVocalRecorder();
		CoreManager::getInstance()->getChatModel()->clear();
	}
}

void ChatRoomModel::forwardMessage(ChatMessageModel * model){
	if(model){
		shared_ptr<linphone::ChatMessage> _message;
		_message = mChatRoom->createForwardMessage(model->getChatMessage());
		auto recorder = CoreManager::getInstance()->getRecorderManager();
		if(recorder->haveVocalRecorder()) {
			auto content = recorder->getVocalRecorder()->getRecorder()->createContent();
			if(content)
				_message->addContent(content);
		}
		_message->send();
		emit messageSent(_message);
	}
}
// -----------------------------------------------------------------------------

void ChatRoomModel::compose () {
	if( mChatRoom)
		mChatRoom->compose();
}

void ChatRoomModel::resetMessageCount () {
	if(mChatRoom && !mDeleteChatRoom && markAsReadEnabled()){
		if (mChatRoom->getUnreadMessagesCount() > 0){
			mChatRoom->markAsRead();// Marking as read is only for messages. Not for calls.
		}
		setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
		setMissedCallsCount(0);
		emit messageCountReset();
		CoreManager::getInstance()->updateUnreadMessageCount();
	}
}
//-------------------------------------------------
// Entries Loading managment
//-------------------------------------------------
//	For each type of events, a part of entries are loaded with a minimal count (=mLastEntriesStep). Like that, we have from 0 to 3*mLastEntriesStep events.
//	We store them in a list that will be sorted from oldest to newest.
//	From the oldest, we loop till having at least one type of event or if we hit the minimum limit.
//		As it was a request for each events, we ensure to get all available events after it.
//	Notations : M0 is the first Message event; N0, the first EventLog; C0, the first Call event. After '|', there are mLastEntriesStep events.
// Available cases examples :
//	'M0...N0....|...C0....' =>  '|...C0....'
//	'M0C0N0|...' == 'C0N0|...' == '|N0....C0....' == '|N0....C0....' == '|.......'  We suppose that we got all available events for the current scope.
//	'N0...M0....C0...|...' => '|C0...'
//
//	-------------------
//
//	When requesting more entries, we count the number of events we got. Each numbers represent the index from what we can retrieve next events from linphone database.
//	Like that, we avoid to load all database. A bad point is about loading call events : There are no range to retrieve and we don't want to load the entire database. So for this case, this is not fully optimized (optimization is only about GUI and connections)
//
//	Request more entries are coming from GUI. Like that, we don't have to manage if events are filtered or not (only messages, call, events).

class EntrySorterHelper{
public:
	EntrySorterHelper(time_t pTime, ChatRoomModel::EntryType pType,std::shared_ptr<linphone::Object> obj) : mTime(pTime), mType(pType), mObject(obj) {}
	time_t mTime;
	ChatRoomModel::EntryType mType;
	std::shared_ptr<linphone::Object> mObject;
	
	static void getLimitedSelection(QList<std::shared_ptr<ChatEvent> > *resultEntries, QList<EntrySorterHelper>& entries, const int& minEntries, ChatRoomModel * chatRoomModel) {// Sort and return a selection with at least 'minEntries'
	// Sort list
		std::sort(entries.begin(), entries.end(), [](const EntrySorterHelper& a, const EntrySorterHelper& b) {
			return a.mTime < b.mTime;
		});
	// Keep max( minEntries, last(messages, events, calls) )
		QList<EntrySorterHelper>::iterator itEntries = entries.begin();
		int spotted = 0;
		auto lastEntry = itEntries;
		while(itEntries != entries.end() && (spotted != 7 && (entries.end()-itEntries > minEntries)) ) {
			if( itEntries->mType == ChatRoomModel::EntryType::MessageEntry) {
				if( (spotted & 1) == 0) {
					lastEntry = itEntries;
					spotted |= 1;
				}
			}else if( itEntries->mType == ChatRoomModel::EntryType::CallEntry){
				if( (spotted & 2) == 0){
					lastEntry = itEntries;
					spotted |= 2;
				}
			}else {
				if( (spotted & 4) == 0){
					lastEntry = itEntries;
					spotted |= 4;
				}
			}
			++itEntries;
		}
		itEntries = lastEntry;
		if(itEntries - entries.begin() < 3)
			itEntries = entries.begin();
		for(; itEntries !=  entries.end() ; ++itEntries){
			if( (*itEntries).mType== ChatRoomModel::EntryType::MessageEntry)
				*resultEntries << ChatMessageModel::create(std::dynamic_pointer_cast<linphone::ChatMessage>(itEntries->mObject), chatRoomModel);
			else if( (*itEntries).mType == ChatRoomModel::EntryType::CallEntry) {
				auto entry = ChatCallModel::create(std::dynamic_pointer_cast<linphone::CallLog>(itEntries->mObject), true, chatRoomModel);
				if(entry) {
					*resultEntries << entry;
					if (entry->mStatus == LinphoneEnums::CallStatusSuccess) {
						entry = ChatCallModel::create(entry->getCallLog(), false, chatRoomModel);
						if(entry)
							*resultEntries << entry;
					}
				}
			}else{
				auto entry = ChatNoticeModel::create(std::dynamic_pointer_cast<linphone::EventLog>(itEntries->mObject), chatRoomModel);
				if(entry) {
					*resultEntries << entry;
				}
			}	
		}
	}
};

void ChatRoomModel::updateNewMessageNotice(const int& count){
	if( mChatRoom ) {
		if(mUnreadMessageNotice ) {
				removeEntry(mUnreadMessageNotice.get());
				mUnreadMessageNotice = nullptr;
		}
		if(count > 0){
			QDateTime lastUnreadMessage = QDateTime::currentDateTime();
			enableMarkAsRead(false);
// Get chat messages
			for (auto &message : mChatRoom->getHistory(mLastEntriesStep)) {
				if( !message->isRead()) {
					lastUnreadMessage = min(lastUnreadMessage, QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000 - 1 ));	//-1 to be sure that event will be before the message
				}
			}			
			mUnreadMessageNotice = ChatNoticeModel::create(ChatNoticeModel::NoticeType::NoticeUnreadMessages, lastUnreadMessage, QString::number(count));
			beginInsertRows(QModelIndex(), 0, 0);
			mEntries.prepend(mUnreadMessageNotice);
			endInsertRows();
			qDebug() << "New message notice timestamp to :" << lastUnreadMessage.toString();
		}
		//emit layoutChanged();
	}
}

int ChatRoomModel::loadTillMessage(ChatMessageModel * message){
	if( message){
		qDebug() << "Load history till message : " << message->getChatMessage()->getMessageId().c_str();
		auto linphoneMessage = message->getChatMessage();
	// First find on current list
		auto entry = std::find_if(mEntries.begin(), mEntries.end(), [linphoneMessage](const std::shared_ptr<ChatEvent>& entry ){
			return entry->mType == ChatRoomModel::EntryType::MessageEntry && dynamic_cast<ChatMessageModel*>(entry.get())->getChatMessage() == linphoneMessage;
		});
	// if not find, load more entries and find it in new entries.
		if( entry == mEntries.end()){
			int newEntries = loadMoreEntries();
			while( newEntries > 0){// no more new entries
				int entryCount = 0;
				entry = mEntries.begin();
				while(entryCount < newEntries && 
					((*entry)->mType != ChatRoomModel::EntryType::MessageEntry || dynamic_cast<ChatMessageModel*>(entry->get())->getChatMessage() != linphoneMessage)
				){
					++entryCount;
					++entry;
				}
				if( entryCount < newEntries){// We got it
					qDebug() << "Find message at " << entryCount << " after loading new entries";
					return entryCount;
				}else
					newEntries = loadMoreEntries();// continue
			}
		}else{
			int entryCount = entry - mEntries.begin();
			qDebug() << "Find message at " << entryCount;
			return entryCount;
		}
		qWarning() << "Message has not been found in history";
	}
	return -1;
}

void ChatRoomModel::initEntries(){
	qDebug() << "Internal Entries : Init";
// On call : reinitialize all entries. This allow to free up memory
	QList<std::shared_ptr<ChatEvent> > entries;
	QList<EntrySorterHelper> prepareEntries;
// Get chat messages
	for (auto &message : mChatRoom->getHistory(mFirstLastEntriesStep)) {
		prepareEntries << EntrySorterHelper(message->getTime() ,MessageEntry, message);
	}
// Get events
	for(auto &eventLog : mChatRoom->getHistoryEvents(mFirstLastEntriesStep))
		prepareEntries << EntrySorterHelper(eventLog->getCreationTime() , NoticeEntry, eventLog);
// Get calls.
	bool secureChatEnabled = CoreManager::getInstance()->getSettingsModel()->getSecureChatEnabled();
	bool standardChatEnabled = CoreManager::getInstance()->getSettingsModel()->getStandardChatEnabled();

	if( isOneToOne() && (secureChatEnabled && !standardChatEnabled && isSecure()
		|| standardChatEnabled && !isSecure()) ) {
		auto callHistory = CallsListModel::getCallHistory(getParticipantAddress(), Utils::coreStringToAppString(mChatRoom->getLocalAddress()->asStringUriOnly()));
		// callhistory is sorted from newest to oldest
		int count = 0;
		for (auto callLog = callHistory.begin() ; count < mFirstLastEntriesStep && callLog != callHistory.end() ; ++callLog, ++count ){
			prepareEntries << EntrySorterHelper((*callLog)->getStartDate(), CallEntry, *callLog);
		}
	}
	EntrySorterHelper::getLimitedSelection(&entries, prepareEntries, mFirstLastEntriesStep, this);
	qDebug() << "Internal Entries : Built";
	mIsInitialized = true;
	if(entries.size() >0){
		beginResetModel();
		mEntries = entries;
		updateNewMessageNotice(mChatRoom->getUnreadMessagesCount());
		endResetModel();
	}
	qDebug() << "Internal Entries : End";
}
void ChatRoomModel::setEntriesLoading(const bool& loading){
	if( mEntriesLoading != loading){
		mEntriesLoading = loading;
		emit entriesLoadingChanged(mEntriesLoading);
		qApp->processEvents();
	}
}

int ChatRoomModel::loadMoreEntries(){
	setEntriesLoading(true);
	int currentRowCount = rowCount();
	int newEntries = 0;
	do{
		QList<std::shared_ptr<ChatEvent> > entries;
		QList<EntrySorterHelper> prepareEntries;
	// Get current event count for each type
		QVector<int> entriesCounts;
		entriesCounts.resize(3);
		for(auto itEntries = mEntries.begin() ; itEntries != mEntries.end() ; ++itEntries){
			if( (*itEntries)->mType == MessageEntry)
				++entriesCounts[0];
			else if( (*itEntries)->mType == CallEntry){
				if(dynamic_cast<ChatCallModel*>((*itEntries).get())->mIsStart)
					++entriesCounts[1];
			} else
				++entriesCounts[2];
		}
		
	// Messages
		for (auto &message : mChatRoom->getHistoryRange(entriesCounts[0], entriesCounts[0]+mLastEntriesStep)){
			auto itEntries = mEntries.begin();
			bool haveEntry = false;
			while(!haveEntry && itEntries != mEntries.end()){
				auto entry = dynamic_cast<ChatMessageModel*>(itEntries->get());
				haveEntry = (entry && entry->getChatMessage() == message);
				++itEntries;
			}
			if(!haveEntry)
				prepareEntries << EntrySorterHelper(message->getTime() ,MessageEntry, message);
		}
	
	// Calls
		bool secureChatEnabled = CoreManager::getInstance()->getSettingsModel()->getSecureChatEnabled();
		bool standardChatEnabled = CoreManager::getInstance()->getSettingsModel()->getStandardChatEnabled();
	
		if( isOneToOne() && (secureChatEnabled && !standardChatEnabled && isSecure()
			|| standardChatEnabled && !isSecure()) ) {
			auto callHistory = CallsListModel::getCallHistory(getParticipantAddress(), Utils::coreStringToAppString(mChatRoom->getLocalAddress()->asStringUriOnly()));
			int count = 0;
			auto itCallHistory = callHistory.begin();
			while(count < entriesCounts[1] && itCallHistory != callHistory.end()){
				++itCallHistory;
				++count;
			}
			count = 0;
			while( count < mLastEntriesStep && itCallHistory != callHistory.end()){
				prepareEntries << EntrySorterHelper((*itCallHistory)->getStartDate(), CallEntry, *itCallHistory);
				++itCallHistory;
			}
		}
	// Notices
		for (auto &eventLog : mChatRoom->getHistoryRangeEvents(entriesCounts[2], entriesCounts[2]+mLastEntriesStep)){
			auto itEntries = mEntries.begin();
			bool haveEntry = false;
			while(!haveEntry && itEntries != mEntries.end()){
				auto entry = dynamic_cast<ChatNoticeModel*>(itEntries->get());
				haveEntry = (entry && entry->getEventLog() && entry->getEventLog() == eventLog);
				++itEntries;
			}
			if(!haveEntry)
				prepareEntries << EntrySorterHelper(eventLog->getCreationTime() , NoticeEntry, eventLog);
		}
		EntrySorterHelper::getLimitedSelection(&entries, prepareEntries, mLastEntriesStep, this);
		if(entries.size() >0){
			beginInsertRows(QModelIndex(), 0, entries.size()-1);
			for(auto entry : entries)
				mEntries.prepend(entry);
			endInsertRows();
			//emit layoutChanged();
			updateLastUpdateTime();
		}
		newEntries = entries.size();
	}while( newEntries>0 && currentRowCount == rowCount());
	currentRowCount = rowCount() - currentRowCount + 1;
	setEntriesLoading(false);
	emit moreEntriesLoaded(currentRowCount);
	return currentRowCount;
}

//-------------------------------------------------
//-------------------------------------------------

void ChatRoomModel::callEnded(std::shared_ptr<linphone::Call> call){
	if( call->getCallLog()->getStatus() == linphone::Call::Status::Missed)
		addMissedCallsCount(call);
	else{
		insertCall(call->getCallLog());
	}
	// When a call is end, a new log WILL be written in database. It may have information on display name.
	QTimer::singleShot(100, this, &ChatRoomModel::fullPeerAddressChanged);
}

// -----------------------------------------------------------------------------

void ChatRoomModel::insertCall (const std::shared_ptr<linphone::CallLog> &callLog) {
	if(mIsInitialized){
		std::shared_ptr<ChatCallModel> model = ChatCallModel::create(callLog, true, this);
		if(model){
			int row = mEntries.count();
			beginInsertRows(QModelIndex(), row, row);
			mEntries << model;
			endInsertRows();
			if (callLog->getStatus() == linphone::Call::Status::Success) {
				model = ChatCallModel::create(callLog, false, this);
				if(model){
					int row = mEntries.count();
					beginInsertRows(QModelIndex(), row, row);
					mEntries << model;
					endInsertRows();
				}
			}
			updateLastUpdateTime();
		}
	}
}

void ChatRoomModel::insertCalls (const QList<std::shared_ptr<linphone::CallLog> > &calls) {
	if(mIsInitialized){
		QList<std::shared_ptr<ChatEvent> > entries;
		for(auto callLog : calls) {
			std::shared_ptr<ChatCallModel> model = ChatCallModel::create(callLog, true, this);
			if(model){
				entries << model;
				if (callLog->getStatus() == linphone::Call::Status::Success) {
					model = ChatCallModel::create(callLog, false, this);
					if(model){
						entries << model;
					}
				}
			}
		}
		if(entries.size() > 0){
			beginInsertRows(QModelIndex(), 0, entries.size()-1);
			entries << mEntries;
			mEntries = entries;
			endInsertRows();
			emit layoutChanged();
		}
	}
}

void ChatRoomModel::insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message) {
	if(mIsInitialized){
		std::shared_ptr<ChatMessageModel> model = ChatMessageModel::create(message, this);
		if(model){
			setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
			int row = mEntries.count();
			beginInsertRows(QModelIndex(), row, row);
			mEntries << model;
			endInsertRows();
		}
	}
}

void ChatRoomModel::insertMessages (const QList<std::shared_ptr<linphone::ChatMessage> > &messages) {
	if(mIsInitialized){
		QList<std::shared_ptr<ChatEvent> > entries;
		for(auto message : messages) {
			std::shared_ptr<ChatMessageModel> model = ChatMessageModel::create(message, this);
			if(model)
				entries << model;
		}
		if(entries.size() > 0){
			beginInsertRows(QModelIndex(), 0, entries.size()-1);
			entries << mEntries;
			mEntries = entries;
			endInsertRows();
			setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
			emit layoutChanged();
		}
	}
}

void ChatRoomModel::insertNotice (const std::shared_ptr<linphone::EventLog> &eventLog) {
	if(mIsInitialized){
		std::shared_ptr<ChatNoticeModel> model = ChatNoticeModel::create(eventLog, this);
		if(model){
			int row = mEntries.count();
			beginInsertRows(QModelIndex(), row, row);
			mEntries << model;
			endInsertRows();
		}
	}
}

void ChatRoomModel::insertNotices (const QList<std::shared_ptr<linphone::EventLog>> &eventLogs) {
	if(mIsInitialized){
		QList<std::shared_ptr<ChatEvent> > entries;
		
		for(auto eventLog : eventLogs) {
			std::shared_ptr<ChatNoticeModel> model = ChatNoticeModel::create(eventLog, this);
			if(model) {
				entries << model;
			}
		}
		
		if(entries.size() > 0){
			beginInsertRows(QModelIndex(), 0, entries.size()-1);
			entries << mEntries;
			mEntries = entries;
			endInsertRows();
			emit layoutChanged();
		}
	}
}

// -----------------------------------------------------------------------------
/*
void ChatRoomModel::removeUnreadMessagesNotice() {
	
}*/
// -----------------------------------------------------------------------------

void ChatRoomModel::handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) {

/*
	if (state == linphone::Call::State::End || state == linphone::Call::State::Error){
		shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
		std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
		std::list<std::shared_ptr<linphone::Address>> participants;
		
		auto chatRoom = core->searchChatRoom(params, mChatRoom->getLocalAddress()
											 , call->getRemoteAddress()
											 , participants);
		if( mChatRoom == chatRoom){
			insertCall(call->getCallLog());
			setMissedCallsCount(mMissedCallsCount+1);
		}
	}
	*/
}

void ChatRoomModel::handleCallCreated(const shared_ptr<linphone::Call> &call){
	
}

void ChatRoomModel::handlePresenceStatusReceived(std::shared_ptr<linphone::Friend> contact){
	if(!mDeleteChatRoom && contact){
		bool canUpdatePresence = false;
		auto contactAddresses = contact->getAddresses();
		for( auto itContactAddress = contactAddresses.begin() ; !canUpdatePresence && itContactAddress != contactAddresses.end() ; ++itContactAddress){
			//auto cleanContactAddress = (*itContactAddress)->clone();
			//cleanContactAddress->clean();
			canUpdatePresence = mChatRoom->getLocalAddress()->weakEqual(*itContactAddress);
			if(!canUpdatePresence && !isGroupEnabled() && mChatRoom->getNbParticipants() == 1){
				auto participants = mChatRoom->getParticipants();	
				auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((*participants.begin())->getAddress()->asString()));
				if(contact){
					auto friendsAddresses = contact->getVcardModel()->getSipAddresses();
					for(auto friendAddress = friendsAddresses.begin() ; !canUpdatePresence && friendAddress != friendsAddresses.end() ; ++friendAddress){
						shared_ptr<linphone::Address> lAddress = CoreManager::getInstance()->getCore()->interpretUrl(
									Utils::appStringToCoreString(friendAddress->toString())
									);
						canUpdatePresence = lAddress->weakEqual(*itContactAddress);
					}	
				}
			}
		}
		if(canUpdatePresence) {
			//emit presenceStatusChanged((int)contact->getPresenceModel()->getConsolidatedPresence());
			emit presenceStatusChanged();
		}
	}
}

//----------------------------------------------------------
//------				CHAT ROOM HANDLERS
//----------------------------------------------------------

void ChatRoomModel::onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing){
	auto it = mComposers.begin();
	while(it != mComposers.end() && !it.key()->weakEqual(remoteAddress))
		++it;
	if(it != mComposers.end())
		mComposers.erase(it);
	if(isComposing)
		mComposers[remoteAddress] = Utils::getDisplayName(remoteAddress);
	emit isRemoteComposingChanged();
	updateLastUpdateTime();
}

void ChatRoomModel::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	setUnreadMessagesCount(chatRoom->getUnreadMessagesCount());
	updateLastUpdateTime();
}

void ChatRoomModel::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	if( eventLog->getType() == linphone::EventLog::Type::ConferenceCallEnd ){
		setMissedCallsCount(mMissedCallsCount+1);
	}else if( eventLog->getType() == linphone::EventLog::Type::ConferenceCreated ){
		emit fullPeerAddressChanged();
	}
	updateLastUpdateTime();
}

void ChatRoomModel::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
		updateLastUpdateTime();
		emit messageReceived(message);
	}
}

void ChatRoomModel::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
		updateLastUpdateTime();
		emit messageReceived(message);
	}
}

void ChatRoomModel::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateLastUpdateTime();
}

// Called when the core have the participant (= exists)
void ChatRoomModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit participantAdded(chatRoom, eventLog);
	emit fullPeerAddressChanged();
}

void ChatRoomModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit participantRemoved(chatRoom, eventLog);
	emit fullPeerAddressChanged();
}

void ChatRoomModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit participantAdminStatusChanged(chatRoom, eventLog);
	emit isMeAdminChanged();	// It is not the case all the time but calling getters is not a heavy request
}

void ChatRoomModel::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){
	updateLastUpdateTime();
	emit stateChanged(getState());
}

void ChatRoomModel::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit securityLevelChanged((int)chatRoom->getSecurityLevel());
}
void ChatRoomModel::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit subjectChanged(getSubject());
	emit usernameChanged();
}

void ChatRoomModel::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	updateLastUpdateTime();
}

void ChatRoomModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateLastUpdateTime();
	emit participantDeviceAdded(chatRoom, eventLog);
}

void ChatRoomModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateLastUpdateTime();
	emit participantDeviceRemoved(chatRoom, eventLog);	
}

void ChatRoomModel::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if(e != events.end() )
		insertNotice(*e);
	else{
		events = mChatRoom->getHistoryEvents(0);
		auto e = std::find(events.begin(), events.end(), eventLog);
		if(e != events.end() )
			insertNotice(*e);
	}
	setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());	// Update message count. In the case of joining conference, the conference id was not valid thus, the missing count was not about the chat room but a global one.
	updateLastUpdateTime();
	emit usernameChanged();
	emit conferenceJoined(chatRoom, eventLog);
	emit isReadOnlyChanged();
}

void ChatRoomModel::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	if( chatRoom->getState() != linphone::ChatRoom::State::Deleted) {
		auto events = chatRoom->getHistoryEvents(0);
		auto e = std::find(events.begin(), events.end(), eventLog);
		if( e != events.end())
			insertNotice(*e);
		else{
			events = mChatRoom->getHistoryEvents(0);
			auto e = std::find(events.begin(), events.end(), eventLog);
			if(e != events.end() )
				insertNotice(*e);
		}
		updateLastUpdateTime();
		emit conferenceLeft(chatRoom, eventLog);
		emit isReadOnlyChanged();
	}
}

void ChatRoomModel::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if(e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
}

void ChatRoomModel::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateLastUpdateTime();
}

void ChatRoomModel::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateLastUpdateTime();
}

void ChatRoomModel::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom){
	updateLastUpdateTime();
}

void ChatRoomModel::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	updateLastUpdateTime();
	emit participantRegistrationSubscriptionRequested(chatRoom, participantAddress);
}

void ChatRoomModel::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationUnsubscriptionRequested(chatRoom, participantAddress);
}

void ChatRoomModel::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){

}

void ChatRoomModel::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
}

