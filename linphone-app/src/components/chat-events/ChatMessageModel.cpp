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
#include "ChatMessageModel.hpp"


#include <QQmlApplicationEngine>

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

#include "ChatMessageListener.hpp"

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "components/chat-reaction/ChatReactionModel.hpp"
#include "components/chat-reaction/ChatReactionListModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/content/ContentListModel.hpp"
#include "components/content/ContentModel.hpp"
#include "components/content/ContentProxyModel.hpp"
#include "components/core/CoreManager.hpp"
#include "app/providers/ThumbnailProvider.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/participant-imdn/ParticipantImdnStateListModel.hpp"
#include "components/participant-imdn/ParticipantImdnStateProxyModel.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"


void ChatMessageModel::connectTo(ChatMessageListener * listener){
	connect(listener, &ChatMessageListener::fileTransferRecv, this, &ChatMessageModel::onFileTransferRecv);
	connect(listener, &ChatMessageListener::fileTransferSendChunk, this, &ChatMessageModel::onFileTransferSendChunk);
	connect(listener, &ChatMessageListener::fileTransferSend, this, &ChatMessageModel::onFileTransferSend);
	connect(listener, &ChatMessageListener::fileTransferProgressIndication, this, &ChatMessageModel::onFileTransferProgressIndication);
	connect(listener, &ChatMessageListener::msgStateChanged, this, &ChatMessageModel::onMsgStateChanged);
	connect(listener, &ChatMessageListener::newMessageReaction, this, &ChatMessageModel::onNewMessageReaction);
	connect(listener, &ChatMessageListener::participantImdnStateChanged, this, &ChatMessageModel::onParticipantImdnStateChanged);
	connect(listener, &ChatMessageListener::ephemeralMessageTimerStarted, this, &ChatMessageModel::onEphemeralMessageTimerStarted);
	connect(listener, &ChatMessageListener::ephemeralMessageDeleted, this, &ChatMessageModel::onEphemeralMessageDeleted);
	connect(listener, &ChatMessageListener::participantImdnStateChanged, this->getParticipantImdnStates().get(), &ParticipantImdnStateListModel::onParticipantImdnStateChanged);
	connect(listener, &ChatMessageListener::reactionRemoved, this, &ChatMessageModel::onReactionRemoved);
}
// =============================================================================

ChatMessageModel::ChatMessageModel (const std::shared_ptr<linphone::ChatMessage>& chatMessage, const std::shared_ptr<const linphone::EventLog>& chatMessageLog, QObject * parent) : ChatEvent(ChatRoomModel::EntryType::MessageEntry, parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it
	init(chatMessage, chatMessageLog);
}

ChatMessageModel::~ChatMessageModel(){
	if(mChatMessage)
		mChatMessage->removeListener(mChatMessageListener);
}

void ChatMessageModel::init(const std::shared_ptr<linphone::ChatMessage>& chatMessage, const std::shared_ptr<const linphone::EventLog>& chatMessageLog){
	if(chatMessage){
		mParticipantImdnStateListModel = QSharedPointer<ParticipantImdnStateListModel>::create(chatMessage);
		mChatMessageListener = std::make_shared<ChatMessageListener>();
		connectTo(mChatMessageListener.get());
		mChatMessage = chatMessage;
		mChatMessage->addListener(mChatMessageListener);
		if( mChatMessage->isReply()){
			auto replyMessage = mChatMessage->getReplyMessage();
			if( replyMessage)// Reply message could be inexistant (for example : when locally deleted)
				mReplyChatMessageModel = create(replyMessage, this->parent());
		}
		std::list<std::shared_ptr<linphone::Content>> contents = chatMessage->getContents();
		QString txt;
		for(auto content : contents){
			if(content->isText())
				txt += content->getUtf8Text().c_str();
		}
		mContent = txt;
		
		mTimestamp = QDateTime::fromMSecsSinceEpoch(chatMessage->getTime() * 1000);
		if(chatMessageLog)
			mReceivedTimestamp = QDateTime::fromMSecsSinceEpoch(chatMessageLog->getCreationTime() * 1000);
		else
			mReceivedTimestamp = mTimestamp;
	}
	mWasDownloaded = false;

	mContentListModel = QSharedPointer<ContentListModel>::create(this);
	mChatReactionListModel = QSharedPointer<ChatReactionListModel>::create(this);
}

QSharedPointer<ChatMessageModel> ChatMessageModel::create(const std::shared_ptr<const linphone::EventLog>& chatMessageLog, QObject * parent){
	auto model = QSharedPointer<ChatMessageModel>::create(chatMessageLog->getChatMessage(), chatMessageLog, parent);
	return model;
}

QSharedPointer<ChatMessageModel> ChatMessageModel::create(const std::shared_ptr<linphone::ChatMessage>& chatMessage, QObject * parent){
	auto model = QSharedPointer<ChatMessageModel>::create(chatMessage, nullptr, parent);
	return model;
}

std::shared_ptr<linphone::ChatMessage> ChatMessageModel::getChatMessage(){
	return mChatMessage;
}

QSharedPointer<ContentModel> ChatMessageModel::getContentModel(std::shared_ptr<linphone::Content> content){
	return mContentListModel->getContentModel(content);
}

//-----------------------------------------------------------------------------------------------------------------------

QString ChatMessageModel::getFromDisplayName(){
	if(!mFromDisplayNameCache.isEmpty())
		return mFromDisplayNameCache;
	if(!mChatMessage)
		return "";
	mFromDisplayNameCache = Utils::getDisplayName(mChatMessage->getFromAddress());
	return mFromDisplayNameCache;
}

QString ChatMessageModel::getFromDisplayNameReplyMessage(){
	if( isReply()){
		if(!fromDisplayNameReplyMessage.isEmpty())
			return fromDisplayNameReplyMessage;
		if(!mChatMessage)
			return "";
		fromDisplayNameReplyMessage = Utils::getDisplayName(mChatMessage->getReplyMessageSenderAddress());
		return fromDisplayNameReplyMessage;
	}else
		return "";
}

QString ChatMessageModel::getFromSipAddress() const{
	return mChatMessage ? Utils::cleanSipAddress(Utils::coreStringToAppString(mChatMessage->getFromAddress()->asStringUriOnly())) : "";
}

QString ChatMessageModel::getToDisplayName() const{
	return mChatMessage ? Utils::getDisplayName(mChatMessage->getToAddress()) : "";
}

QString ChatMessageModel::getToSipAddress() const{
	return mChatMessage ? Utils::cleanSipAddress(Utils::coreStringToAppString(mChatMessage->getToAddress()->asStringUriOnly())) : "";
}

QString ChatMessageModel::getMyReaction() const {
	if(!mChatMessage) return "";
	auto myReaction = mChatMessage->getOwnReaction();
	return myReaction ? Utils::coreStringToAppString(myReaction->getBody()) : "";
}

ContactModel * ChatMessageModel::getContactModel() const{
	return mChatMessage ? CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::cleanSipAddress(Utils::coreStringToAppString(mChatMessage->getFromAddress()->asStringUriOnly()))).get() : nullptr;
}

bool ChatMessageModel::isEphemeral() const{
	return mChatMessage && mChatMessage->isEphemeral();
}

qint64 ChatMessageModel::getEphemeralExpireTime() const{
	time_t t = mChatMessage ? mChatMessage->getEphemeralExpireTime() : 0;
	return 	t >0 ? t - QDateTime::currentSecsSinceEpoch() : 0;
}

long ChatMessageModel::getEphemeralLifetime() const{
	return mChatMessage ? mChatMessage->getEphemeralLifetime() : 0;
}

LinphoneEnums::ChatMessageState ChatMessageModel::getState() const{
	return mChatMessage ? LinphoneEnums::fromLinphone(mChatMessage->getState()) : LinphoneEnums::ChatMessageStateIdle;
}

bool ChatMessageModel::isOutgoing() const{
	return mChatMessage && mChatMessage->isOutgoing();
}

ParticipantImdnStateProxyModel * ChatMessageModel::getProxyImdnStates(){
	ParticipantImdnStateProxyModel * proxy = new ParticipantImdnStateProxyModel();
	proxy->setChatMessageModel(this);
	return proxy;
}

QSharedPointer<ParticipantImdnStateListModel> ChatMessageModel::getParticipantImdnStates() const{
	return mParticipantImdnStateListModel;
}

QSharedPointer<ContentListModel> ChatMessageModel::getContents() const{
	return mContentListModel;
}

QSharedPointer<ChatReactionListModel> ChatMessageModel::getChatReactions() const {
	return mChatReactionListModel;
}

bool ChatMessageModel::isReply() const{
	return mChatMessage && mChatMessage->isReply();
}

ChatMessageModel * ChatMessageModel::getReplyChatMessageModel() const{
	return mReplyChatMessageModel.get();
}

bool ChatMessageModel::isForward() const{
	return mChatMessage && mChatMessage->isForward();
}

QString ChatMessageModel::getForwardInfo() const{
	return mChatMessage ? Utils::coreStringToAppString(mChatMessage->getForwardInfo()) : "";
}

QString ChatMessageModel::getForwardInfoDisplayName() const{
	QString forwardInfo = getForwardInfo();
	auto forwardAddress = Utils::interpretUrl(forwardInfo);
	if(!forwardAddress || Utils::isMe(forwardAddress))
		return "";// myself
	else
		return Utils::getDisplayName(forwardInfo);
}
//-----------------------------------------------------------------------------------------------------------------------



void ChatMessageModel::setWasDownloaded(bool wasDownloaded){
	if( mWasDownloaded != wasDownloaded) {
		mWasDownloaded = wasDownloaded;
		emit wasDownloadedChanged();
	}
}

void ChatMessageModel::setTimestamp(const QDateTime& timestamp) {
	mTimestamp = timestamp;
}

void ChatMessageModel::setReceivedTimestamp(const QDateTime& timestamp) {
	mReceivedTimestamp = timestamp;
}

//-----------------------------------------------------------------------------------------------------------------------

void ChatMessageModel::resendMessage (){
	switch (getState()) {
		case LinphoneEnums::ChatMessageStateFileTransferError:
		case LinphoneEnums::ChatMessageStateNotDelivered: {
			mChatMessage->send();
			emit stateChanged();
			break;
		}
			
		default:
			qWarning() << QStringLiteral("Unable to resend message: %1. Bad state.").arg(getState());
	}
}

void ChatMessageModel::sendChatReaction(const QString& reaction){
	auto myReaction = mChatMessage->getOwnReaction();
	if( myReaction && Utils::coreStringToAppString(myReaction->getBody()) == reaction) {
		auto chatReaction = mChatMessage->createReaction("");
		chatReaction->send();
		//emit reactionRemoved(mChatMessage, chatReaction->getFromAddress());	// Do not emit because we want to display what the server got
	}else{
		auto chatReaction = mChatMessage->createReaction(Utils::appStringToCoreString(reaction));
		chatReaction->send();
		//emit newMessageReaction(mChatMessage, chatReaction);// Do not emit because we want to display what the server got
	}
}

void ChatMessageModel::deleteEvent(){
	if (mChatMessage && mChatMessage->getFileTransferInformation()) {
		mChatMessage->cancelFileTransfer();
	}
	if(mChatMessage)
		mChatMessage->getChatRoom()->deleteMessage(mChatMessage);
}


void ChatMessageModel::updateFileTransferInformation(){
	mContentListModel->updateContents(this);
}

void ChatMessageModel::onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer){
}
void ChatMessageModel::onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer) {
	
}
std::shared_ptr<linphone::Buffer> ChatMessageModel::onFileTransferSend (const std::shared_ptr<linphone::ChatMessage> &,const std::shared_ptr<linphone::Content> &content,size_t,size_t) {
	return nullptr;
}

void ChatMessageModel::onFileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message,const std::shared_ptr<linphone::Content> &content,size_t offset,size_t total) {
	auto contentModel = mContentListModel->getContentModel(content);
	if(contentModel) {
		contentModel->setFileOffset(offset);
		if (total == offset && mChatMessage && !mChatMessage->isOutgoing()) {
			mContentListModel->downloaded();
			bool allAreDownloaded = true;
			for(auto content : mContentListModel->getSharedList<ContentModel>())
				allAreDownloaded &= content->mWasDownloaded;
			setWasDownloaded(allAreDownloaded);
			QTimer::singleShot(60, App::getInstance(),
			                   [message, content]() { // on 100% downlaoded, the SDK still need to do stuff on file. It
				                                      // still need permission on file. Let the application to use the
				                                      // file after next iteration.
				                   App::getInstance()->getNotifier()->notifyReceivedFileMessage(message, content);
			                   });
		}
	}
}

void ChatMessageModel::onMsgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state) {
	updateFileTransferInformation();// On message state, file transfert information Content can be changed
	if( state == linphone::ChatMessage::State::FileTransferDone) {
		mContentListModel->updateContents(this);// Avoid having leak contents
		if( !mWasDownloaded){// Update states
			bool allAreDownloaded = true;
			for(auto content : mContentListModel->getSharedList<ContentModel>())
				allAreDownloaded &= content->mWasDownloaded;
			setWasDownloaded(allAreDownloaded);
		}
	}
	emit stateChanged();
}

void ChatMessageModel::onNewMessageReaction(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction){
	if(reaction->getFromAddress()->weakEqual(message->getLocalAddress()))
		emit myReactionChanged();
	emit newMessageReaction(message, reaction);
}

void ChatMessageModel::onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	
}
void ChatMessageModel::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message) {
	emit ephemeralExpireTimeChanged();
}
void ChatMessageModel::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message) {
	//emit remove(mSelf.lock());
	if(!isOutgoing())
		mContentListModel->removeDownloadedFiles();
	emit remove(this);
}

void ChatMessageModel::onReactionRemoved(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::Address> & address) {
	if(address->weakEqual(message->getLocalAddress()))
		emit myReactionChanged();
	emit reactionRemoved(message, address);
}
//-------------------------------------------------------------------------------------------------------


