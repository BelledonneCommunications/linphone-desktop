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
#include "components/chat-events/ChatCallModel.hpp"
#include "components/chat-events/ChatEvent.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/chat-events/ChatNoticeModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/participant/ParticipantModel.hpp"
#include "components/participant/ParticipantListModel.hpp"
#include "components/presence/Presence.hpp"
#include "components/timeline/TimelineModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"
#include "utils/LinphoneEnums.hpp"



// =============================================================================

using namespace std;

namespace {
constexpr int ThumbnailImageFileWidth = 100;
constexpr int ThumbnailImageFileHeight = 100;

// In Bytes.
constexpr qint64 FileSizeLimit = 524288000;
}

// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
std::shared_ptr<ChatRoomModel> ChatRoomModel::create(std::shared_ptr<linphone::ChatRoom> chatRoom){
	std::shared_ptr<ChatRoomModel> model = std::make_shared<ChatRoomModel>(chatRoom);
	if(model){
		model->mSelf = model;
		 chatRoom->addListener(model);
		return model;
	}else
		return nullptr;
}

ChatRoomModel::ChatRoomModel (std::shared_ptr<linphone::ChatRoom> chatRoom){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	CoreManager *coreManager = CoreManager::getInstance();
	mCoreHandlers = coreManager->getHandlers();
	
	mChatRoom = chatRoom;
		
	setLastUpdateTime(QDateTime::fromMSecsSinceEpoch(mChatRoom->getLastUpdateTime()));
	setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
	setMissedCallsCount(0);
	
	qWarning() << "Creation ChatRoom with unreadmessages: " << mChatRoom->getUnreadMessagesCount();
	
	// Get messages.
	mEntries.clear();
	
	QElapsedTimer timer;
	timer.start();
	{
		CoreHandlers *coreHandlers = mCoreHandlers.get();
		//QObject::connect(coreHandlers, &CoreHandlers::messageReceived, this, &ChatRoomModel::handleMessageReceived);
		QObject::connect(coreHandlers, &CoreHandlers::callCreated, this, &ChatRoomModel::handleCallCreated);
		QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &ChatRoomModel::handleCallStateChanged);
		QObject::connect(coreHandlers, &CoreHandlers::presenceStatusReceived, this, &ChatRoomModel::handlePresenceStatusReceived);
		//QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &ChatRoomModel::handleIsComposingChanged);
	}
	if(mChatRoom){
		mParticipantListModel = std::make_shared<ParticipantListModel>(this);
		connect(mParticipantListModel.get(), &ParticipantListModel::participantsChanged, this, &ChatRoomModel::fullPeerAddressChanged);
		connect(mParticipantListModel.get(), &ParticipantListModel::participantsChanged, this, &ChatRoomModel::usernameChanged);
		auto participants = mChatRoom->getParticipants();	
		for(auto participant : participants){
			auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(QString::fromStdString((participant)->getAddress()->asString()));
			if(contact) {
				connect(contact, &ContactModel::contactUpdated, this, &ChatRoomModel::fullPeerAddressChanged);
				connect(contact, &ContactModel::contactUpdated, this, &ChatRoomModel::usernameChanged);
			}
		}
	}else
		mParticipantListModel = nullptr;
}

ChatRoomModel::~ChatRoomModel () {
	mParticipantListModel = nullptr;
	if(mChatRoom && mDeleteChatRoom)
		CoreManager::getInstance()->getCore()->deleteChatRoom(mChatRoom);
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
			return QVariant::fromValue(mEntries[row]->mTimestamp.date());
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
	qInfo() << QStringLiteral("Removing all chat entries of: (%1, %2).")
			   .arg(getPeerAddress()).arg(getLocalAddress());
	
	beginResetModel();	
	for (auto &entry : mEntries)
		entry->deleteEvent();
	mEntries.clear();
		
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
//--------------------------------------------------------------------------------------------

QString ChatRoomModel::getPeerAddress () const {
	if(haveEncryption() || isGroupEnabled()){
		return getParticipants()->addressesToString();
	}else
		return mChatRoom ? Utils::coreStringToAppString(mChatRoom->getPeerAddress()->asStringUriOnly()) : "";
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
	if(haveEncryption() || isGroupEnabled()){
		return getParticipants()->addressesToString();
	}else
		return mChatRoom ? Utils::coreStringToAppString(mChatRoom->getPeerAddress()->asString()) : "";
}

QString ChatRoomModel::getFullLocalAddress () const {
	return mChatRoom ? QString::fromStdString(mChatRoom->getLocalAddress()->asString()) : "";
}

QString ChatRoomModel::getConferenceAddress () const {
	if(!mChatRoom)
		return "";
	else {
		auto address = mChatRoom->getConferenceAddress();
		return address?QString::fromStdString(address->asString()):"";
	}
}

QString ChatRoomModel::getSubject () const {
	return mChatRoom ? QString::fromStdString(mChatRoom->getSubject()) : "";
}

QString ChatRoomModel::getUsername () const {
	QString username;
	if( !mChatRoom)
		return "";
	if( isGroupEnabled())
		username = QString::fromStdString(mChatRoom->getSubject());
	
	if(username != "")
		return username;
	if(  mChatRoom->getNbParticipants() >= 1)
		username = mParticipantListModel->displayNamesToString();
	if(username != "")
		return username;
	if(haveEncryption() || isGroupEnabled())
		return "";// Wait for more info
	username = Utils::getDisplayName(mChatRoom->getPeerAddress());
	if(username != "")
		return username;
	return QString::fromStdString(mChatRoom->getPeerAddress()->asStringUriOnly());
}

QString ChatRoomModel::getAvatar () const {
	if( mChatRoom && mChatRoom->getNbParticipants() == 1){
		auto participants = mChatRoom->getParticipants();	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(QString::fromStdString((*participants.begin())->getAddress()->asString()));
		if(contact)
			return contact->getVcardModel()->getAvatar();
	}
	return "";
}

int ChatRoomModel::getPresenceStatus() const {
	if( mChatRoom && mChatRoom->getNbParticipants() == 1 && !isGroupEnabled()){
		auto participants = mChatRoom->getParticipants();	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(QString::fromStdString((*participants.begin())->getAddress()->asString()));
		if(contact) {
			int p = contact->getPresenceLevel();
			return p;
		}
		else
			return 0;
	}else
		return 0;
}

ParticipantListModel* ChatRoomModel::getParticipants() const{
	return mParticipantListModel.get();
}

int ChatRoomModel::getState() const {
	return mChatRoom ? (int)mChatRoom->getState() : 0;	
}

bool ChatRoomModel::hasBeenLeft() const{
	return mChatRoom && mChatRoom->hasBeenLeft();	
}

bool ChatRoomModel::isEphemeralEnabled() const{
	return mChatRoom && mChatRoom->ephemeralEnabled();
}

long ChatRoomModel::getEphemeralLifetime() const{
	return mChatRoom ? mChatRoom->getEphemeralLifetime() : 0;
}

bool ChatRoomModel::canBeEphemeral(){
	return mChatRoom && isGroupEnabled();
}

bool ChatRoomModel::haveEncryption() const{
	return mChatRoom && mChatRoom->getCurrentParams()->getEncryptionBackend() != linphone::ChatRoomEncryptionBackend::None;
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
bool ChatRoomModel::isMeAdmin() const{
	return mChatRoom->getMe()->isAdmin();
}

bool ChatRoomModel::canHandleParticipants() const{
	return mChatRoom->canHandleParticipants();
}
/*
bool ChatRoomModel::getIsRemoteComposing () const {
	return mIsRemoteComposing;
}
*/

std::shared_ptr<linphone::ChatRoom> ChatRoomModel::getChatRoom(){
	return mChatRoom;
}

QList<QString> ChatRoomModel::getComposers(){
	return mComposers.values();
}

//------------------------------------------------------------------------------------------------

void ChatRoomModel::setLastUpdateTime(const QDateTime& lastUpdateDate) {
	if(mLastUpdateTime != lastUpdateDate ) {
		mLastUpdateTime = lastUpdateDate;
		emit lastUpdateTimeChanged();
	}	
}

void ChatRoomModel::setUnreadMessagesCount(const int& count){
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
	shared_ptr<linphone::ChatMessage> _message = mChatRoom->createMessageFromUtf8("");
	_message->getContents().begin()->get()->setUtf8Text(message.toUtf8().toStdString());
	_message->send();
	
	emit messageSent(_message);
}

void ChatRoomModel::sendFileMessage (const QString &path) {
	
	QFile file(path);
	if (!file.exists())
		return;
	
	qint64 fileSize = file.size();
	if (fileSize > FileSizeLimit) {
		qWarning() << QStringLiteral("Unable to send file. (Size limit=%1)").arg(FileSizeLimit);
		return;
	}
	
	shared_ptr<linphone::Content> content = CoreManager::getInstance()->getCore()->createContent();
	{
		QStringList mimeType = QMimeDatabase().mimeTypeForFile(path).name().split('/');
		if (mimeType.length() != 2) {
			qWarning() << QStringLiteral("Unable to get supported mime type for: `%1`.").arg(path);
			return;
		}
		content->setType(Utils::appStringToCoreString(mimeType[0]));
		content->setSubtype(Utils::appStringToCoreString(mimeType[1]));
	}
	content->setSize(size_t(fileSize)); 
	content->setName(Utils::appStringToCoreString( QFileInfo(file).fileName()));

	shared_ptr<linphone::ChatMessage> message = mChatRoom->createFileTransferMessage(content);
	message->getContents().front()->setFilePath(Utils::appStringToCoreString(path));
	message->send();
	
	emit messageSent(message);
}

// -----------------------------------------------------------------------------

void ChatRoomModel::compose () {
	if( mChatRoom)
		mChatRoom->compose();
}

void ChatRoomModel::resetMessageCount () {
	if(mChatRoom && !mDeleteChatRoom){
		if (mChatRoom->getUnreadMessagesCount() > 0){
			mChatRoom->markAsRead();// Marking as read is only for messages. Not for calls.
		}
		setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
		setMissedCallsCount(0);
		emit messageCountReset();
	}
}

void ChatRoomModel::initEntries(){
	if(!mIsInitialized){
		QList<std::shared_ptr<ChatEvent> > entries;
// Get chat messages
		for (auto &message : mChatRoom->getHistory(0))
			entries << ChatMessageModel::create(message, this);
// Get events
		for(auto &eventLog : mChatRoom->getHistoryEvents(0)){
			 auto entry = ChatNoticeModel::create(eventLog, this);
			 if(entry)
				entries << entry;
		}
// Get calls.
		if(!isSecure() )
			for (auto &callLog : CoreManager::getInstance()->getCore()->getCallHistory(mChatRoom->getPeerAddress(), mChatRoom->getLocalAddress())){
				auto entry = ChatCallModel::create(callLog, true, this);
				if(entry) {
					entries << entry;
					if (callLog->getStatus() == linphone::Call::Status::Success) {
						entry = ChatCallModel::create(callLog, false, this);
						if(entry)
							entries << entry;
					}
				}
			}
		mIsInitialized = true;
		beginInsertRows(QModelIndex(), 0, entries.size()-1);
		mEntries = entries;
		endInsertRows();
	}
}


// -----------------------------------------------------------------------------

void ChatRoomModel::insertCall (const shared_ptr<linphone::CallLog> &callLog) {
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
		}
	}
}

void ChatRoomModel::insertMessageAtEnd (const shared_ptr<linphone::ChatMessage> &message) {
	if(mIsInitialized){
		std::shared_ptr<ChatMessageModel> model = ChatMessageModel::create(message, this);
		if(model){
			int row = mEntries.count();
			beginInsertRows(QModelIndex(), row, row);
			mEntries << model;
			endInsertRows();
		}
	}
}

void ChatRoomModel::insertNotice (const std::shared_ptr<linphone::EventLog> &enventLog) {
	if(mIsInitialized){
		std::shared_ptr<ChatNoticeModel> model = ChatNoticeModel::create(enventLog, this);
		if(model){
			int row = mEntries.count();
			beginInsertRows(QModelIndex(), row, row);
			mEntries << model;
			endInsertRows();
		}
	}
}

// -----------------------------------------------------------------------------

void ChatRoomModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::Call::State state) {
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
				auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(QString::fromStdString((*participants.begin())->getAddress()->asString()));
				auto friendsAddresses = contact->getVcardModel()->getSipAddresses();
				for(auto friendAddress = friendsAddresses.begin() ; !canUpdatePresence && friendAddress != friendsAddresses.end() ; ++friendAddress){
					shared_ptr<linphone::Address> lAddress = CoreManager::getInstance()->getCore()->interpretUrl(
								Utils::appStringToCoreString(friendAddress->toString())
								);
					canUpdatePresence = lAddress->weakEqual(*itContactAddress);
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
	//ContactModel * model = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString(remoteAddress->asString()));
	if(!isComposing) {
		auto it = mComposers.begin();
		while(it != mComposers.end() && !it.key()->weakEqual(remoteAddress))
			++it;
		if(it != mComposers.end())
			mComposers.erase(it);
	}else
		mComposers[remoteAddress] = Utils::getDisplayName(remoteAddress);
	qWarning() << "Composing : " << isComposing << mComposers.values();
	emit isRemoteComposingChanged();
}

void ChatRoomModel::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	qWarning() << "M1";
	setUnreadMessagesCount(chatRoom->getUnreadMessagesCount());
}

void ChatRoomModel::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "New Event" <<(int) eventLog->getType();
	if( eventLog->getType() == linphone::EventLog::Type::ConferenceCallEnd ){
		setMissedCallsCount(mMissedCallsCount+1);
	}else if( eventLog->getType() == linphone::EventLog::Type::ConferenceCreated ){
		emit fullPeerAddressChanged();
	}
}

void ChatRoomModel::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	qWarning() << "M2";
	auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
		setLastUpdateTime(QDateTime::fromMSecsSinceEpoch(chatRoom->getLastUpdateTime()));
		emit messageReceived(message);
	}
}

void ChatRoomModel::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "S1";
	auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
		setLastUpdateTime(QDateTime::fromMSecsSinceEpoch(chatRoom->getLastUpdateTime()));
		emit messageReceived(message);
	}
}

void ChatRoomModel::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "S2";
}

void ChatRoomModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	emit participantAdded(chatRoom, eventLog);
	emit fullPeerAddressChanged();
}

void ChatRoomModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	emit participantRemoved(chatRoom, eventLog);
	emit fullPeerAddressChanged();
}

void ChatRoomModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantAdminStatusChanged(chatRoom, eventLog);
	emit isMeAdminChanged();	// It is not the case all the time but calling getters is not a heavy request
}

void ChatRoomModel::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){
	emit stateChanged(getState());
}

void ChatRoomModel::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	emit securityLevelChanged((int)chatRoom->getSecurityLevel());
	//emit securityEvent(chatRoom, eventLog);
}
void ChatRoomModel::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	emit subjectChanged(getSubject());
	emit usernameChanged();
}

void ChatRoomModel::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
}

void ChatRoomModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantDeviceAdded(chatRoom, eventLog);
}

void ChatRoomModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	emit participantDeviceRemoved(chatRoom, eventLog);	
}

void ChatRoomModel::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "onConferenceJoined";
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
	emit usernameChanged();
	emit conferenceJoined(chatRoom, eventLog);
	emit hasBeenLeftChanged();
}

void ChatRoomModel::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "onConferenceLeft";
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
		emit conferenceLeft(chatRoom, eventLog);
		emit hasBeenLeftChanged();
	}
}

void ChatRoomModel::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if(e != events.end() )
		insertNotice(*e);
}

void ChatRoomModel::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "onEphemeralMessageTimerStarted";
}

void ChatRoomModel::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "onEphemeralMessageDeleted";
}

void ChatRoomModel::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom){
	qWarning() << "onConferenceAddressGeneration";
}

void ChatRoomModel::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationSubscriptionRequested(chatRoom, participantAddress);
}

void ChatRoomModel::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationUnsubscriptionRequested(chatRoom, participantAddress);
}

void ChatRoomModel::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	qWarning() << "onChatMessageShouldBeStored";
}

void ChatRoomModel::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
}

