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
	connect(listener, &ChatMessageListener::participantImdnStateChanged, this, &ChatMessageModel::onParticipantImdnStateChanged);
	connect(listener, &ChatMessageListener::ephemeralMessageTimerStarted, this, &ChatMessageModel::onEphemeralMessageTimerStarted);
	connect(listener, &ChatMessageListener::ephemeralMessageDeleted, this, &ChatMessageModel::onEphemeralMessageDeleted);
	connect(listener, &ChatMessageListener::participantImdnStateChanged, this->getParticipantImdnStates().get(), &ParticipantImdnStateListModel::onParticipantImdnStateChanged);
}
// =============================================================================

ChatMessageModel::AppDataManager::AppDataManager(const QString& appdata){
	if(!appdata.isEmpty()){
		for(QString pair : appdata.split(';')){
			QStringList fields = pair.split(':');
			if(fields.size() > 1)
				mData[fields[1]] = fields[0];
			else
				qWarning() << "Bad or too old appdata. It need a compatibility parsing : " << appdata;
		}
	}
}

QString ChatMessageModel::AppDataManager::toString(){
	QStringList pairs;
	for(QMap<QString,QString>::iterator it = mData.begin() ; it != mData.end() ; ++it){
		pairs << it.value() + ":" + it.key();
	}
	return pairs.join(';');
}
ChatMessageModel::ChatMessageModel ( std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent) : ChatEvent(ChatRoomModel::EntryType::MessageEntry, parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it
	if(chatMessage){
		mParticipantImdnStateListModel = QSharedPointer<ParticipantImdnStateListModel>::create(chatMessage);
		mChatMessageListener = std::make_shared<ChatMessageListener>(parent);
		connectTo(mChatMessageListener.get());
		mChatMessage = chatMessage;
		mChatMessage->addListener(mChatMessageListener);
		if( mChatMessage->isReply()){
			auto replyMessage = mChatMessage->getReplyMessage();
			if( replyMessage)// Reply message could be inexistant (for example : when locally deleted)
				mReplyChatMessageModel = create(replyMessage, parent);
		}
		std::list<std::shared_ptr<linphone::Content>> contents = chatMessage->getContents();
		QString txt;
		for(auto content : contents){
			if(content->isText())
				txt += content->getUtf8Text().c_str();
		}
		mContent = txt;
		
		mTimestamp = QDateTime::fromMSecsSinceEpoch(chatMessage->getTime() * 1000);
	}
	mWasDownloaded = false;

	mContentListModel = QSharedPointer<ContentListModel>::create(this);
}

ChatMessageModel::~ChatMessageModel(){
	if(mChatMessage)
		mChatMessage->removeListener(mChatMessageListener);
}
QSharedPointer<ChatMessageModel> ChatMessageModel::create(std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent){
	auto model = QSharedPointer<ChatMessageModel>::create(chatMessage, parent);
	return model;
}

std::shared_ptr<linphone::ChatMessage> ChatMessageModel::getChatMessage(){
	return mChatMessage;
}

QSharedPointer<ContentModel> ChatMessageModel::getContentModel(std::shared_ptr<linphone::Content> content){
	return mContentListModel->getContentModel(content);
}

//-----------------------------------------------------------------------------------------------------------------------

QString ChatMessageModel::getFromDisplayName() const{
	return mChatMessage ? Utils::getDisplayName(mChatMessage->getFromAddress()) : "";
}

QString ChatMessageModel::getFromDisplayNameReplyMessage() const{
	if( isReply())
		return Utils::getDisplayName(mChatMessage->getReplyMessageSenderAddress());
	else
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

ContactModel * ChatMessageModel::getContactModel() const{
	return mChatMessage ? CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString(mChatMessage->getFromAddress()->asString())).get() : nullptr;
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

void ChatMessageModel::deleteEvent(){
	if (mChatMessage && mChatMessage->getFileTransferInformation()) {// Remove thumbnail
		mChatMessage->cancelFileTransfer();
		QString appdata = QString::fromStdString(mChatMessage->getAppdata());
		QStringList fields = appdata.split(':');
		
		if(fields[0].size() > 0) {
			QString thumbnailPath = QString::fromStdString(Paths::getThumbnailsDirPath()) + fields[0];
			if (!QFile::remove(thumbnailPath))
				qWarning() << QStringLiteral("Unable to remove `%1`.").arg(thumbnailPath);
		}
		mChatMessage->setAppdata("");// Remove completely Thumbnail from the message
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
			App::getInstance()->getNotifier()->notifyReceivedFileMessage(message, content);
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
//-------------------------------------------------------------------------------------------------------


