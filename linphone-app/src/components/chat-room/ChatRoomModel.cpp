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

#include "ChatRoomModel.hpp"

#include <algorithm>

#include <QDateTime>
#include <QDesktopServices>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QSettings>
#include <QTimer>
#include <QUuid>
#include <QMessageBox>
#include <QUrlQuery>
#include <QImageReader>
#include <qqmlapplicationengine.h>

#include "ChatRoomListener.hpp"

#include "app/App.hpp"
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
#include "components/settings/SettingsModel.hpp"
#include "components/participant/ParticipantModel.hpp"
#include "components/participant/ParticipantListModel.hpp"
#include "components/presence/Presence.hpp"
#include "components/recorder/RecorderManager.hpp"
#include "components/recorder/RecorderModel.hpp"
#include "components/timeline/TimelineModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "components/core/event-count-notifier/AbstractEventCountNotifier.hpp"
#include "utils/Utils.hpp"
#include "utils/LinphoneEnums.hpp"



// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

void ChatRoomModel::connectTo(ChatRoomListener * listener){
	connect(listener, &ChatRoomListener::isComposingReceived, this, &ChatRoomModel::onIsComposingReceived);
	connect(listener, &ChatRoomListener::messageReceived, this, &ChatRoomModel::onMessageReceived);
	connect(listener, &ChatRoomListener::messagesReceived, this, &ChatRoomModel::onMessagesReceived);
	connect(listener, &ChatRoomListener::newEvent, this, &ChatRoomModel::onNewEvent);
	connect(listener, &ChatRoomListener::newEvents, this, &ChatRoomModel::onNewEvents);
	connect(listener, &ChatRoomListener::chatMessageReceived, this, &ChatRoomModel::onChatMessageReceived);
	connect(listener, &ChatRoomListener::chatMessagesReceived, this, &ChatRoomModel::onChatMessagesReceived);
	connect(listener, &ChatRoomListener::chatMessageSending, this, &ChatRoomModel::onChatMessageSending);
	connect(listener, &ChatRoomListener::chatMessageSent, this, &ChatRoomModel::onChatMessageSent);
	connect(listener, &ChatRoomListener::participantAdded, this, &ChatRoomModel::onParticipantAdded);
	connect(listener, &ChatRoomListener::participantRemoved, this, &ChatRoomModel::onParticipantRemoved);
	connect(listener, &ChatRoomListener::participantAdminStatusChanged, this, &ChatRoomModel::onParticipantAdminStatusChanged);
	connect(listener, &ChatRoomListener::stateChanged, this, &ChatRoomModel::onStateChanged);
	connect(listener, &ChatRoomListener::securityEvent, this, &ChatRoomModel::onSecurityEvent);
	connect(listener, &ChatRoomListener::subjectChanged, this, &ChatRoomModel::onSubjectChanged);
	connect(listener, &ChatRoomListener::undecryptableMessageReceived, this, &ChatRoomModel::onUndecryptableMessageReceived);
	connect(listener, &ChatRoomListener::participantDeviceAdded, this, &ChatRoomModel::onParticipantDeviceAdded);
	connect(listener, &ChatRoomListener::participantDeviceRemoved, this, &ChatRoomModel::onParticipantDeviceRemoved);
	connect(listener, &ChatRoomListener::conferenceJoined, this, &ChatRoomModel::onConferenceJoined);
	connect(listener, &ChatRoomListener::conferenceLeft, this, &ChatRoomModel::onConferenceLeft);
	connect(listener, &ChatRoomListener::ephemeralEvent, this, &ChatRoomModel::onEphemeralEvent);
	connect(listener, &ChatRoomListener::ephemeralMessageTimerStarted, this, &ChatRoomModel::onEphemeralMessageTimerStarted);
	connect(listener, &ChatRoomListener::ephemeralMessageDeleted, this, &ChatRoomModel::onEphemeralMessageDeleted);
	connect(listener, &ChatRoomListener::conferenceAddressGeneration, this, &ChatRoomModel::onConferenceAddressGeneration);
	connect(listener, &ChatRoomListener::participantRegistrationSubscriptionRequested, this, &ChatRoomModel::onParticipantRegistrationSubscriptionRequested);
	connect(listener, &ChatRoomListener::participantRegistrationUnsubscriptionRequested, this, &ChatRoomModel::onParticipantRegistrationUnsubscriptionRequested);
	connect(listener, &ChatRoomListener::chatMessageShouldBeStored, this, &ChatRoomModel::onChatMessageShouldBeStored);
	connect(listener, &ChatRoomListener::chatMessageParticipantImdnStateChanged, this, &ChatRoomModel::onChatMessageParticipantImdnStateChanged);
}

// -----------------------------------------------------------------------------
QSharedPointer<ChatRoomModel> ChatRoomModel::create(const std::shared_ptr<linphone::ChatRoom>& chatRoom, const QMap<QString,QMap<QString, std::shared_ptr<linphone::CallLog>>>& lastCalls){
	QSharedPointer<ChatRoomModel> model = QSharedPointer<ChatRoomModel>::create(chatRoom, lastCalls);
	if(model){
		model->mSelf = model;
		 //chatRoom->addListener(model);
		return model;
	}else
		return nullptr;
}

ChatRoomModel::ChatRoomModel (const std::shared_ptr<linphone::ChatRoom>& chatRoom, const QMap<QString,QMap<QString, std::shared_ptr<linphone::CallLog>>>& lastCalls, QObject * parent) : ProxyListModel(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	CoreManager *coreManager = CoreManager::getInstance();
	mCoreHandlers = coreManager->getHandlers();
	
	mChatRoom = chatRoom;
	mChatRoomListener = std::make_shared<ChatRoomListener>();
	connectTo(mChatRoomListener.get());
	mChatRoom->addListener(mChatRoomListener);
	
	// Get messages.
	mList.clear();
	
	setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
	setMissedCallsCount(0);
	
	QElapsedTimer timer;
	timer.start();
	CoreHandlers *coreHandlers = mCoreHandlers.get();
	QObject::connect(this, &ChatRoomModel::messageSent, this, &ChatRoomModel::resetMessageCount);
	QObject::connect(coreHandlers, &CoreHandlers::callCreated, this, &ChatRoomModel::handleCallCreated);
	QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &ChatRoomModel::handleCallStateChanged);
	QObject::connect(coreHandlers, &CoreHandlers::presenceStatusReceived, this, &ChatRoomModel::handlePresenceStatusReceived);

	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactAdded, this, &ChatRoomModel::fullPeerAddressChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactAdded, this, &ChatRoomModel::avatarChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactRemoved, this, &ChatRoomModel::fullPeerAddressChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactRemoved, this, &ChatRoomModel::avatarChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactUpdated, this, &ChatRoomModel::fullPeerAddressChanged);
	QObject::connect(coreManager->getContactsListModel(), &ContactsListModel::contactUpdated, this, &ChatRoomModel::avatarChanged);

	connect(this, &ChatRoomModel::fullPeerAddressChanged, this, &ChatRoomModel::usernameChanged);
	connect(this, &ChatRoomModel::stateChanged, this, &ChatRoomModel::updatingChanged);
	
	if(mChatRoom){
		mParticipantListModel = QSharedPointer<ParticipantListModel>::create(this);
		connect(mParticipantListModel.get(), &ParticipantListModel::participantsChanged, this, &ChatRoomModel::fullPeerAddressChanged);
		auto participants = getParticipants(false);
		for(auto participant : participants){
			auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((participant)->getAddress()->asString()));
			if(contact) {
				connect(contact.get(), &ContactModel::contactUpdated, this, &ChatRoomModel::fullPeerAddressChanged);
			}
		}
		time_t callDate = 0;
		if(lastCalls.size() > 0){
			QString peerAddress = getParticipantAddress();
			QString localAddress = Utils::coreStringToAppString(mChatRoom->getLocalAddress()->asStringUriOnly());

			auto itLocal = lastCalls.find(localAddress);
			if(itLocal != lastCalls.end()){
				auto itPeer = itLocal->find(peerAddress);
				if(itPeer != itLocal->end()) {
					callDate = itPeer.value()->getStartDate();
					if( itPeer.value()->getStatus() == linphone::Call::Status::Success )
						callDate += itPeer.value()->getDuration();
				}
			}
		}
		setLastUpdateTime(QDateTime::fromMSecsSinceEpoch(std::max(mChatRoom->getLastUpdateTime(), callDate )*1000));

	}else
		mParticipantListModel = nullptr;
}

ChatRoomModel::~ChatRoomModel () {
	mParticipantListModel = nullptr;
	if(mChatRoom ){
		mChatRoom->removeListener(mChatRoomListener);
		if(mDeleteChatRoom){
			mDeleteChatRoom = false;
			if(CoreManager::getInstance()->getCore() ){
				auto participants = getParticipants();
				std::list<std::shared_ptr<linphone::Address>> participantsAddress;
				for(auto p : participants)
					participantsAddress.push_back(p->getAddress()->clone());
				auto internalChatRoom = CoreManager::getInstance()->getCore()->searchChatRoom(mChatRoom->getCurrentParams(), mChatRoom->getLocalAddress(), mChatRoom->getPeerAddress(), participantsAddress);
				if( internalChatRoom) {
					qInfo() << "Deleting ChatRoom : " << getSubject() << ",  address=" << getFullPeerAddress();
					CoreManager::getInstance()->getCore()->deleteChatRoom(internalChatRoom);
				}
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

QVariant ChatRoomModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	switch (role) {
		case Roles::ChatEntry: return QVariant::fromValue(mList[row].get());
		case Roles::SectionDate: return QVariant::fromValue(mList[row].objectCast<ChatEvent>()->getReceivedTimestamp().date());
	}
	
	return QVariant();
}

bool ChatRoomModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i) {
		mList[row].objectCast<ChatEvent>()->deleteEvent();
		mList.removeAt(row);
	}
	
	endRemoveRows();
	
	if (mList.count() == 0)
		emit allEntriesRemoved(mSelf.lock());
	else if (limit == mList.count())
		emit lastEntryRemoved();
	emit focused();// Removing rows is like having focus. Don't wait asynchronous events.
	emit dataChanged(index(row), index(limit));
	return true;
}

void ChatRoomModel::removeAllEntries () {
	qInfo() << QStringLiteral("Removing all entries of: (%1, %2).")
			   .arg(getPeerAddress()).arg(getLocalAddress());
	auto core = CoreManager::getInstance()->getCore();
	bool standardChatEnabled = CoreManager::getInstance()->getSettingsModel()->getStandardChatEnabled();
	beginResetModel();
	mList.clear();
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
	if( mChatRoom->isReadOnly())// = hasBeenLeft()
		deleteChatRoom();
	endResetModel();
	emit allEntriesRemoved(mSelf.lock());
	emit focused();// Removing all entries is like having focus. Don't wait asynchronous events.
}

void ChatRoomModel::removeEntry(ChatEvent* entry){
	remove(entry);
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
	return mChatRoom && mChatRoom->getPeerAddress() ? Utils::coreStringToAppString(mChatRoom->getPeerAddress()->asString()) : "";
}

QString ChatRoomModel::getFullLocalAddress () const {
	return mChatRoom && mChatRoom->getLocalAddress()? Utils::coreStringToAppString(mChatRoom->getLocalAddress()->asString()) : "";
}

QString ChatRoomModel::getConferenceAddress () const {
	if(!mChatRoom || mChatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Basic))
		return "";
	else {
		auto address = mChatRoom->getConferenceAddress();
		return address?Utils::coreStringToAppString(address->asString()):"";
	}
}

QString ChatRoomModel::getSubject () const {
	return mChatRoom ? Utils::coreStringToAppString(mChatRoom->getSubject()) : "";	// in UTF8
}

QString ChatRoomModel::getUsername () const {
	QString username;
	if( !mChatRoom)
		return "";
	if( !isOneToOne())
		username = getSubject();
	
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
		qWarning() << "ChatRoom has no peer address or address is invalid : Subject=" << getSubject()
			<< ", created at " << QDateTime::fromSecsSinceEpoch(mChatRoom->getCreationTime())
			<< " (" << mChatRoom.get() << ")";
		return "";
	}
}

QString ChatRoomModel::getAvatar () const {
	if( mChatRoom && mChatRoom->getNbParticipants() == 1){
		auto participants = getParticipants(false);	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((*participants.begin())->getAddress()->asString()));
		if(contact)
			return contact->getVcardModel()->getAvatar();
	}
	return "";
}

int ChatRoomModel::getPresenceStatus() const {
	if( mChatRoom && mChatRoom->getNbParticipants() == 1 && !isGroupEnabled()){
		auto participants = getParticipants(false);
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((*participants.begin())->getAddress()->asString()));
		if(contact) {
			return contact->getPresenceLevel();
		}
		else
			return -1;
	}else
		return -1;
}

QDateTime ChatRoomModel::getPresenceTimestamp() const {
	if( mChatRoom && mChatRoom->getNbParticipants() == 1 && !isGroupEnabled()){
		auto participants = getParticipants(false);
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((*participants.begin())->getAddress()->asString()));
		if(contact) {
			return contact->getPresenceTimestamp();
		}
		else
			return QDateTime();
	}else
		return QDateTime();
}

ParticipantListModel* ChatRoomModel::getParticipantListModel() const{
	return mParticipantListModel.get();
}

std::list<std::shared_ptr<linphone::Participant>> ChatRoomModel::getParticipants(const bool& withMe) const{
	auto participantList = mChatRoom->getParticipants();
	if(withMe) {
		auto me = mChatRoom->getMe();
		if( me )
			participantList.push_front(me);
	}
	return participantList;
}

LinphoneEnums::ChatRoomState ChatRoomModel::getState() const {
	return mChatRoom ? LinphoneEnums::fromLinphone(mChatRoom->getState()) : LinphoneEnums::ChatRoomStateNone;
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
	return mChatRoom && mChatRoom->getCurrentParams()->getEncryptionBackend() != linphone::ChatRoom::EncryptionBackend::None;
}

bool ChatRoomModel::haveConferenceAddress() const{
	return mChatRoom && getFullPeerAddress().toLower().contains("conf-id");
}

bool ChatRoomModel::markAsReadEnabled() const{
	return mMarkAsReadEnabled;
}

bool ChatRoomModel::isSecure() const{
	return mChatRoom && (mChatRoom->getSecurityLevel() == linphone::ChatRoom::SecurityLevel::Encrypted
			|| mChatRoom->getSecurityLevel() == linphone::ChatRoom::SecurityLevel::Safe);
}

int ChatRoomModel::getSecurityLevel() const{
	return mChatRoom ? (int)mChatRoom->getSecurityLevel() : 0;
}

bool ChatRoomModel::isGroupEnabled() const{
	return mChatRoom && mChatRoom->getCurrentParams()->groupEnabled(); 
}

bool ChatRoomModel::isConference() const{
	return mChatRoom && mChatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Conference);
}

bool ChatRoomModel::isOneToOne() const{
	return mChatRoom && mChatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::OneToOne);
}

bool ChatRoomModel::isMeAdmin() const{
	return mChatRoom && mChatRoom->getMe()->isAdmin();
}

bool ChatRoomModel::isCurrentAccount() const{
	return mChatRoom && Utils::isMe(mChatRoom->getLocalAddress());
}

bool ChatRoomModel::canHandleParticipants() const{
	return mChatRoom && mChatRoom->canHandleParticipants();
}

bool ChatRoomModel::getIsRemoteComposing () const {
	return mComposers.size() > 0;
}

bool ChatRoomModel::isEntriesLoading() const{
	return mEntriesLoading;
}

bool ChatRoomModel::isBasic() const{
	return mChatRoom && mChatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Basic);
}

bool ChatRoomModel::isUpdating() const{
	return getState() == LinphoneEnums::ChatRoomStateCreationPending || getState() == LinphoneEnums::ChatRoomStateTerminationPending;
}

bool ChatRoomModel::isNotificationsEnabled() const{
	auto id = getChatRoomId();
	QSettings settings;
	settings.beginGroup("chatrooms");
	settings.beginGroup(id);
	return settings.value("notifications", true).toBool();
}

std::shared_ptr<linphone::ChatRoom> ChatRoomModel::getChatRoom(){
	return mChatRoom;
}

QList<QString> ChatRoomModel::getComposers(){
	return mComposers.values();
}

QString ChatRoomModel::getParticipantAddress() const{
	if(!isSecure()){
		auto peerAddress = mChatRoom->getPeerAddress();
		if( peerAddress)
			return Utils::coreStringToAppString(peerAddress->asString());
		else if(isConference()){
			auto conferenceAddress = mChatRoom->getConferenceAddress();
			if( conferenceAddress)
				return Utils::coreStringToAppString(conferenceAddress->asString());
			else{
				qWarning() << "ConferenceAddress is NULL when requesting it from not secure and conference ChatRoomModel. Subject=" << getSubject()
					<< ", created at " << QDateTime::fromSecsSinceEpoch(mChatRoom->getCreationTime())
					<< " (" << mChatRoom.get() << ")";
				return "";
			}
		}else {
			qWarning() << "PeerAddress is NULL when requesting it from not secure ChatRoomModel. Subject=" << getSubject()
				<< ", created at " << QDateTime::fromSecsSinceEpoch(mChatRoom->getCreationTime())
				<< " (" << mChatRoom.get() << ")";
			return "";
		}
	}else{
		auto participants = getParticipantListModel();
		if(participants->getCount() > 1)
			return participants->getAt<ParticipantModel>(1)->getSipAddress();
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
		mChatRoom->setSubject(Utils::appStringToCoreString(subject));	// in UTF8
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
		for(auto e : mList){
			auto chatEvent = e.objectCast<ChatEvent>();
			if(chatEvent->mType == CallEntry && chatEvent->getTimestamp() > lastCallTime)
				lastCallTime = chatEvent->getTimestamp();
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
		if(call->dataExists("call-model"))
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
void ChatRoomModel::enableNotifications(const bool& enable){
	if(enable != isNotificationsEnabled()){
		auto id = getChatRoomId();
		QSettings settings;
		settings.beginGroup("chatrooms");
		settings.beginGroup(id);
		settings.setValue("notifications", enable);
		notificationsEnabledChanged();
	}
}

void ChatRoomModel::setReply(ChatMessageModel * model){
	if(model != mReplyModel.get()){
		if( model && model->getChatMessage() )
			mReplyModel = ChatMessageModel::create(model->getChatMessage());
		else
			mReplyModel = nullptr;
		emit replyChanged();
	}
}

ChatMessageModel * ChatRoomModel::getReply()const{
	return mReplyModel.get();
}

//------------------------------------------------------------------------------------------------

void ChatRoomModel::markAsToDelete(){
	mDeleteChatRoom = true;
}

void ChatRoomModel::deleteChatRoom(){
	qInfo() << "Deleting ChatRoom : " << getSubject() << ",  address=" << getFullPeerAddress();
	if(mChatRoom){
		CoreManager::getInstance()->getCore()->deleteChatRoom(mChatRoom);
	}
}

void ChatRoomModel::leaveChatRoom (){
	if(mChatRoom){
		if(!isReadOnly())
			mChatRoom->leave();
		if( mChatRoom->getHistorySize() == 0 && mChatRoom->getHistoryEventsSize() == 0)
			deleteChatRoom();
	}
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
	auto fileContents = CoreManager::getInstance()->getChatModel()->getContentListModel()->getSharedList<ContentModel>();
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
		if( mChatRoom->getState() != linphone::ChatRoom::State::Deleted){
			if (mChatRoom->getUnreadMessagesCount() > 0){
				mChatRoom->markAsRead();// Marking as read is only for messages. Not for calls.
			}
			setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
		}else
			setUnreadMessagesCount(0);
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
	
	static void getLimitedSelection(QList<QSharedPointer<ChatEvent> > *resultEntries, QList<EntrySorterHelper>& entries, const int& minEntries, ChatRoomModel * chatRoomModel) {// Sort and return a selection with at least 'minEntries'
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
				*resultEntries << ChatMessageModel::create(std::dynamic_pointer_cast<linphone::ChatMessage>(itEntries->mObject));
			else if( (*itEntries).mType == ChatRoomModel::EntryType::CallEntry) {
				auto entry = ChatCallModel::create(std::dynamic_pointer_cast<linphone::CallLog>(itEntries->mObject), true);
				if(entry) {
					*resultEntries << entry;
					if (entry->mStatus == LinphoneEnums::CallStatusSuccess) {
						entry = ChatCallModel::create(entry->getCallLog(), false);
						if(entry)
							*resultEntries << entry;
					}
				}
			}else{
				auto entry = ChatNoticeModel::create(std::dynamic_pointer_cast<linphone::EventLog>(itEntries->mObject));
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
				remove(mUnreadMessageNotice);
				mUnreadMessageNotice = nullptr;
		}
		if(count > 0){
			QDateTime lastUnreadMessage = QDateTime::currentDateTime();
			QDateTime lastReceivedMessage = lastUnreadMessage;
			enableMarkAsRead(false);
// Get chat messages
			for (auto &message : mChatRoom->getHistory(mLastEntriesStep)) {
				if( !message->isRead()) {
					lastUnreadMessage = min(lastUnreadMessage, QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000 - 1 ));	//-1 to be sure that event will be before the message
					lastReceivedMessage = min(lastReceivedMessage, ChatMessageModel::initReceivedTimestamp(message, false).addMSecs(-1));
				}
			}			
			mUnreadMessageNotice = ChatNoticeModel::create(ChatNoticeModel::NoticeType::NoticeUnreadMessages, lastUnreadMessage,lastReceivedMessage, QString::number(count));
			prepend(mUnreadMessageNotice);
			qDebug() << "New message notice timestamp to :" << lastUnreadMessage.toString() << " recv at " << lastReceivedMessage.toString();
		}
	}
}

int ChatRoomModel::loadTillMessage(ChatMessageModel * message){
	if( message){
		qDebug() << "Load history till message : " << message->getChatMessage()->getMessageId().c_str();
		auto linphoneMessage = message->getChatMessage();
	// First find on current list
		auto entry = std::find_if(mList.begin(), mList.end(), [linphoneMessage](const QSharedPointer<QObject>& entry ){
			auto chatEventEntry = entry.objectCast<ChatEvent>();
			return chatEventEntry->mType == ChatRoomModel::EntryType::MessageEntry && chatEventEntry.objectCast<ChatMessageModel>()->getChatMessage() == linphoneMessage;
		});
	// if not find, load more entries and find it in new entries.
		if( entry == mList.end()){
			mPostModelChangedEvents = false;
			beginResetModel();
			int newEntries = loadMoreEntries();
			while( newEntries > 0){// no more new entries
				int entryCount = 0;
				entry = mList.begin();
				auto chatEventEntry = entry->objectCast<ChatEvent>();
				while(entryCount < newEntries && 
					(chatEventEntry->mType != ChatRoomModel::EntryType::MessageEntry || chatEventEntry.objectCast<ChatMessageModel>()->getChatMessage() != linphoneMessage)
				){
					++entryCount;
					++entry;
					if( entry != mList.end())
						chatEventEntry = entry->objectCast<ChatEvent>();
				}
				if( entryCount < newEntries){// We got it
					qDebug() << "Find message at " << entryCount << " after loading new entries";
					mPostModelChangedEvents = true;
					endResetModel();
					return entryCount;
				}else
					newEntries = loadMoreEntries();// continue
			}
			mPostModelChangedEvents = true;
			endResetModel();
		}else{
			int entryCount = entry - mList.begin();
			qDebug() << "Find message at " << entryCount;
			return entryCount;
		}
		qWarning() << "Message has not been found in history";
	}
	return -1;
}

bool ChatRoomModel::isTerminated(const std::shared_ptr<linphone::ChatRoom>& chatRoom){
	return chatRoom->getState() == linphone::ChatRoom::State::Terminated || chatRoom->getState() == linphone::ChatRoom::State::Deleted;
}

bool ChatRoomModel::exists(const std::shared_ptr<linphone::ChatMessage> message) const{
	auto entry = std::find_if(mList.begin(), mList.end(), [message](const QSharedPointer<QObject>& entry ){
			auto chatEventEntry = entry.objectCast<ChatEvent>();
			return chatEventEntry->mType == ChatRoomModel::EntryType::MessageEntry && chatEventEntry.objectCast<ChatMessageModel>()->getChatMessage() == message;
		});
	// if not find, load more entries and find it in new entries.
	return entry != mList.end();
}

void ChatRoomModel::addBindingCall(){	// If a call is binding to this chat room, we avoid cleaning data (Add=+1, remove=-1)
	++mBindingCalls;
}
	
void ChatRoomModel::removeBindingCall(){
	--mBindingCalls;
}

void ChatRoomModel::resetData(){
	if( mBindingCalls == 0)
		ProxyListModel::resetData();
}

void ChatRoomModel::initEntries(){
	if( mList.size() > mLastEntriesStep)
		resetData();
	if(mList.size() <= (mUnreadMessageNotice ? 1 : 0)) {
		qDebug() << "Internal Entries : Init";
	// On call : reinitialize all entries. This allow to free up memory
		QList<QSharedPointer<ChatEvent> > entries;
		QList<EntrySorterHelper> prepareEntries;
	// Get chat messages
		for (auto &message : mChatRoom->getHistory(mFirstLastEntriesStep)) {
			prepareEntries << EntrySorterHelper(ChatMessageModel::initReceivedTimestamp(message, false).toTime_t() ,MessageEntry, message);
		}
	// Get events
		for(auto &eventLog : mChatRoom->getHistoryEvents(mFirstLastEntriesStep))
			prepareEntries << EntrySorterHelper(eventLog->getCreationTime() , NoticeEntry, eventLog);
	// Get calls.
		bool secureChatEnabled = CoreManager::getInstance()->getSettingsModel()->getSecureChatEnabled();
		bool standardChatEnabled = CoreManager::getInstance()->getSettingsModel()->getStandardChatEnabled();
		bool noChat = !secureChatEnabled && !standardChatEnabled;
	
		if(noChat || (isOneToOne() && (secureChatEnabled && !standardChatEnabled && isSecure()
			|| standardChatEnabled && !isSecure())) ) {
			auto callHistory = CallsListModel::getCallHistory(getParticipantAddress(), Utils::coreStringToAppString(mChatRoom->getLocalAddress()->asStringUriOnly()));
			// callhistory is sorted from newest to oldest
			int count = 0;
			for (auto callLog = callHistory.begin() ; count < mFirstLastEntriesStep && callLog != callHistory.end() ; ++callLog, ++count ){
				if(!(*callLog)->wasConference())
					prepareEntries << EntrySorterHelper((*callLog)->getStartDate(), CallEntry, *callLog);
			}
		}
		EntrySorterHelper::getLimitedSelection(&entries, prepareEntries, mFirstLastEntriesStep, this);
		qDebug() << "Internal Entries : Built";
		if(entries.size() >0){
			auto firstIndex = index(mList.size()-1,0);
			beginInsertRows(QModelIndex(),0, entries.size()-1);
			for(auto e : entries) {
				if( e->mType == ChatRoomModel::EntryType::MessageEntry){
					connect(e.objectCast<ChatMessageModel>().get(), &ChatMessageModel::remove, this, &ChatRoomModel::removeEntry);
					auto model = e.objectCast<ChatMessageModel>().get();
					qDebug() << "Adding" << model->getReceivedTimestamp().toString("yyyy/MM/dd hh:mm:ss.zzz") << model->getTimestamp().toString("yyyy/MM/dd hh:mm:ss.zzz") << (CoreManager::getInstance()->getSettingsModel()->isDeveloperSettingsAvailable() ? QString(model->getChatMessage()->getUtf8Text().c_str()).left(5) : "");
				}
				mList.push_back(e);
			}
			endInsertRows();
			auto lastIndex = index(mList.size()-1,0);
			emit dataChanged(firstIndex,lastIndex);
			updateNewMessageNotice(mChatRoom->getUnreadMessagesCount());
		}
		qDebug() << "Internal Entries : End";
	}
	mIsInitialized = true;
}
void ChatRoomModel::setEntriesLoading(const bool& loading){
	if( mEntriesLoading != loading){
		mEntriesLoading = loading;
		emit entriesLoadingChanged(mEntriesLoading);
	}
}

int ChatRoomModel::loadMoreEntries(){
	setEntriesLoading(true);
	int currentRowCount = rowCount();
	int newEntries = 0;
	do{
		QList<QSharedPointer<ChatEvent> > entries;
		QList<EntrySorterHelper> prepareEntries;
	// Get current event count for each type
		QVector<int> entriesCounts;
		entriesCounts.resize(3);
		for(auto itEntries = mList.begin() ; itEntries != mList.end() ; ++itEntries){
			auto chatEvent = itEntries->objectCast<ChatEvent>();
			if( chatEvent->mType == MessageEntry)
				++entriesCounts[0];
			else if( chatEvent->mType == CallEntry){
				if(chatEvent.objectCast<ChatCallModel>()->mIsStart)
					++entriesCounts[1];
			} else
				++entriesCounts[2];
		}
		
	// Messages
		for (auto &message : mChatRoom->getHistoryRange(entriesCounts[0], entriesCounts[0]+mLastEntriesStep)){
			auto itEntries = mList.begin();
			bool haveEntry = false;
			while(!haveEntry && itEntries != mList.end()){
				auto entry = itEntries->objectCast<ChatMessageModel>();
				haveEntry = (entry && entry->getChatMessage() == message);
				++itEntries;
			}
			if(!haveEntry)
				prepareEntries << EntrySorterHelper(ChatMessageModel::initReceivedTimestamp(message, false).toTime_t() ,MessageEntry, message);
		}
	
	// Calls
		bool secureChatEnabled = CoreManager::getInstance()->getSettingsModel()->getSecureChatEnabled();
		bool standardChatEnabled = CoreManager::getInstance()->getSettingsModel()->getStandardChatEnabled();
		bool noChat = !secureChatEnabled && !standardChatEnabled;
	
		if( noChat || (isOneToOne() && (secureChatEnabled && !standardChatEnabled && isSecure()
			|| standardChatEnabled && !isSecure())) ) {
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
			auto itEntries = mList.begin();
			bool haveEntry = false;
			while(!haveEntry && itEntries != mList.end()){
				auto entry = itEntries->objectCast<ChatNoticeModel>();
				haveEntry = (entry && entry->getEventLog() && entry->getEventLog() == eventLog);
				++itEntries;
			}
			if(!haveEntry)
				prepareEntries << EntrySorterHelper(eventLog->getCreationTime() , NoticeEntry, eventLog);
		}
		EntrySorterHelper::getLimitedSelection(&entries, prepareEntries, mLastEntriesStep, this);
		
		if(entries.size() >0){
			if(mPostModelChangedEvents){
				
				beginInsertRows(QModelIndex(), 0, entries.size()-1);
			}
			for(auto entry : entries)
				mList.prepend(entry);
			if(mPostModelChangedEvents){
				endInsertRows();
				emit dataChanged(index(0),index(entries.size()-1));
			}
			updateLastUpdateTime();
		}
		newEntries = entries.size();
	}while( newEntries>0 && currentRowCount == rowCount());
	currentRowCount = rowCount() - currentRowCount;
	setEntriesLoading(false);
	if(mPostModelChangedEvents)
		emit moreEntriesLoaded(currentRowCount);
	return currentRowCount;
}

//-------------------------------------------------
//-------------------------------------------------

void ChatRoomModel::onCallEnded(std::shared_ptr<linphone::Call> call){
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
		QSharedPointer<ChatCallModel> model = ChatCallModel::create(callLog, true);
		if(model){
			int row = mList.count();
			beginInsertRows(QModelIndex(), row, row);
			mList << model;
			endInsertRows();
			auto lastIndex = index(mList.size()-1,0);
			emit dataChanged(lastIndex,lastIndex );
			if (callLog->getStatus() == linphone::Call::Status::Success) {
				model = ChatCallModel::create(callLog, false);
				if(model)
					add(model);
			}
			updateLastUpdateTime();
		}
	}
}

void ChatRoomModel::insertCalls (const QList<std::shared_ptr<linphone::CallLog> > &calls) {
	if(mIsInitialized){
		QList<QSharedPointer<QObject> > entries;
		for(auto callLog : calls) {
			QSharedPointer<ChatCallModel> model = ChatCallModel::create(callLog, true);
			if(model){
				entries << model;
				if (callLog->getStatus() == linphone::Call::Status::Success) {
					model = ChatCallModel::create(callLog, false);
					if(model){
						entries << model;
					}
				}
			}
		}
		if(entries.size() > 0){
			prepend(entries);
		}
	}
}

QSharedPointer<ChatMessageModel> ChatRoomModel::insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message) {
	QSharedPointer<ChatMessageModel> model;
	if(mIsInitialized && !exists(message)){
		model = ChatMessageModel::create(message);
		if(model){
			qDebug() << "Adding at end" << model->getReceivedTimestamp().toString("hh:mm:ss.zzz") << model->getTimestamp().toString("hh:mm:ss.zzz") << QString(message->getUtf8Text().c_str()).left(5);
			connect(model.get(), &ChatMessageModel::remove, this, &ChatRoomModel::removeEntry);
			setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
			add(model);
		}
	}
	return model;
}

void ChatRoomModel::insertMessages (const QList<std::shared_ptr<linphone::ChatMessage> > &messages) {
	if(mIsInitialized){
		QList<QSharedPointer<QObject> > entries;
		for(auto message : messages) {
			QSharedPointer<ChatMessageModel> model = ChatMessageModel::create(message);
			if(model){
				connect(model.get(), &ChatMessageModel::remove, this, &ChatRoomModel::removeEntry);
				entries << model;
			}
		}
		if(entries.size() > 0){
			prepend(entries);
			setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
		}
	}
}

void ChatRoomModel::insertNotice (const std::shared_ptr<linphone::EventLog> &eventLog) {
	if(mIsInitialized){
		QSharedPointer<ChatNoticeModel> model = ChatNoticeModel::create(eventLog);
		if(model)
			add(model);
	}
}

void ChatRoomModel::insertNotices (const QList<std::shared_ptr<linphone::EventLog>> &eventLogs) {
	if(mIsInitialized){
		QList<QSharedPointer<QObject> > entries;
		for(auto eventLog : eventLogs) {
			QSharedPointer<ChatNoticeModel> model = ChatNoticeModel::create(eventLog);
			if(model) {
				entries << model;
			}
		}
		if(entries.size() > 0){
			prepend(entries);
		}
	}
}

QString ChatRoomModel::getChatRoomId()const{
	return getChatRoomId(getLocalAddress(), getPeerAddress());
}

QString ChatRoomModel::getChatRoomId(const QString& localAddress, const QString& remoteAddress){
	return localAddress + "~"+remoteAddress;
}

QString ChatRoomModel::getChatRoomId(const std::shared_ptr<linphone::ChatRoom>& chatRoom){
	auto localAddress = chatRoom->getLocalAddress()->clone();
	localAddress->clean();
	return getChatRoomId(Utils::coreStringToAppString(localAddress->asStringUriOnly()), (chatRoom->getPeerAddress() ? Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly()) : ""));
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
				auto participants = getParticipants(false);
				auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString((*participants.begin())->getAddress()->asString()));
				if(contact){
					auto friendsAddresses = contact->getVcardModel()->getSipAddresses();
					for(auto friendAddress = friendsAddresses.begin() ; !canUpdatePresence && friendAddress != friendsAddresses.end() ; ++friendAddress){
						shared_ptr<linphone::Address> lAddress = Utils::interpretUrl(friendAddress->toString());
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
}

void ChatRoomModel::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	if(message) ChatMessageModel::initReceivedTimestamp(message, true);
	setUnreadMessagesCount(chatRoom->getUnreadMessagesCount());
	updateLastUpdateTime();
}

void ChatRoomModel::onMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::ChatMessage>> & messages){
	for(auto message : messages)
		if(message) ChatMessageModel::initReceivedTimestamp(message, true);
	setUnreadMessagesCount(chatRoom->getUnreadMessagesCount());
	updateLastUpdateTime();
}


void ChatRoomModel::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	if(eventLog){
		if( eventLog->getType() == linphone::EventLog::Type::ConferenceCallEnded ){
			setMissedCallsCount(mMissedCallsCount+1);
		}else if( eventLog->getType() == linphone::EventLog::Type::ConferenceCreated ){
			emit fullPeerAddressChanged();
		}
		updateLastUpdateTime();
	}
}

void ChatRoomModel::onNewEvents(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::EventLog>> & eventLogs){
	int missCount = 0;
	bool updatePeerAddress = false;
	for(auto eventLog : eventLogs)
		if(eventLog){
			if( eventLog->getType() == linphone::EventLog::Type::ConferenceCallEnded )
				++missCount;
			if( eventLog->getType() == linphone::EventLog::Type::ConferenceCreated )
				updatePeerAddress = true;
		}
	if(missCount > 0)
		setMissedCallsCount(mMissedCallsCount+missCount);
	if(updatePeerAddress)
		emit fullPeerAddressChanged();
	updateLastUpdateTime();
}

void ChatRoomModel::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	auto message = eventLog->getChatMessage();
	if(message){
		ChatMessageModel::initReceivedTimestamp(message, true);
		insertMessageAtEnd(message);
		updateLastUpdateTime();
		emit messageReceived(message);
	}
}

void ChatRoomModel::onChatMessagesReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::list<std::shared_ptr<linphone::EventLog>> & eventLogs){
	for(auto eventLog : eventLogs){
		auto message = eventLog->getChatMessage();
		if(message){
			ChatMessageModel::initReceivedTimestamp(message, true);
			insertMessageAtEnd(message);
			updateLastUpdateTime();
			emit messageReceived(message);
		}
	}
}

void ChatRoomModel::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto message = eventLog->getChatMessage();
	if(message){
		ChatMessageModel::initReceivedTimestamp(message, true);
		insertMessageAtEnd(message);
		updateLastUpdateTime();
		emit messageReceived(message);
	}
}

void ChatRoomModel::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto message = eventLog->getChatMessage();
	if(message) ChatMessageModel::initReceivedTimestamp(message, true);	// Just in case
	updateLastUpdateTime();
}

// Called when the core have the participant (= exists)
void ChatRoomModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit participantAdded(eventLog);
	emit fullPeerAddressChanged();
}

void ChatRoomModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit participantRemoved(eventLog);
	emit fullPeerAddressChanged();
}

void ChatRoomModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto events = chatRoom->getHistoryEvents(0);
	auto e = std::find(events.begin(), events.end(), eventLog);
	if( e != events.end() )
		insertNotice(*e);
	updateLastUpdateTime();
	emit participantAdminStatusChanged(eventLog);
	emit isMeAdminChanged();	// It is not the case all the time but calling getters is not a heavy request
}

void ChatRoomModel::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){
	updateLastUpdateTime();
	emit stateChanged(getState());
	if(newState == linphone::ChatRoom::State::Deleted){
		mChatRoom->removeListener(mChatRoomListener);
		mChatRoom = nullptr;
		emit chatRoomDeleted();
	}
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
	emit participantDeviceAdded(eventLog);
}

void ChatRoomModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	updateLastUpdateTime();
	emit participantDeviceRemoved(eventLog);
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
	emit conferenceJoined(eventLog);
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
		emit conferenceLeft(eventLog);
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
	emit participantRegistrationSubscriptionRequested(participantAddress);
}

void ChatRoomModel::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){
	emit participantRegistrationUnsubscriptionRequested(participantAddress);
}

void ChatRoomModel::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){

}

void ChatRoomModel::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
}

