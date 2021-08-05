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

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "app/providers/ThumbnailProvider.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/participant-imdn/ParticipantImdnStateListModel.hpp"
#include "components/participant-imdn/ParticipantImdnStateProxyModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"

// =============================================================================
namespace {
constexpr int ThumbnailImageFileWidth = 100;
constexpr int ThumbnailImageFileHeight = 100;

// In Bytes.
constexpr qint64 FileSizeLimit = 524288000;
}
/*
std::shared_ptr<ChatMessageModel::ChatMessageListener::ChatMessageListener> ChatMessageModel::ChatMessageListener::create(ChatMessageModel * model, std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent){// Call it instead constructor
	auto listener = std::shared_ptr<ChatMessageModel::ChatMessageListener::ChatMessageListener>(new ChatMessageModel::ChatMessageListener::ChatMessageListener(model,chatMessage, parent), [model](ChatMessageModel::ChatMessageListener::ChatMessageListener * listener){
		chatMessage->removeListener(model->getHandler());
	});
	chatMessage->addListener(listener);
	return model;
}

ChatMessageModel::ChatMessageListener::ChatMessageListener(ChatMessageModel * model, std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent){
	connect(this, &ChatMessageModel::ChatMessageListener::onFileTransferSend, model, ChatMessageModel::onFileTransferSend);
	connect(this, &ChatMessageModel::ChatMessageListener::onFileTransferProgressIndication, model, ChatMessageModel::onFileTransferProgressIndication);
	connect(this, &ChatMessageModel::ChatMessageListener::onMsgStateChanged, model, ChatMessageModel::onMsgStateChanged);
}
ChatMessageModel::ChatMessageListener::~ChatMessageListener(){

}
*/

// Warning : isFileTransfer/isFile/getpath cannot be used for Content that comes from linphone::ChatMessage::getContents(). That lead to a crash.
// in SDK there is this note : return c->isFile(); // TODO FIXME this doesn't work when Content is from linphone_chat_message_get_contents() list
ContentModel::ContentModel(ChatMessageModel* chatModel){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mChatMessageModel = chatModel;
	mWasDownloaded = false;
	mFileOffset = 0;
}
ContentModel::ContentModel(std::shared_ptr<linphone::Content> content, ChatMessageModel* chatModel){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mChatMessageModel = chatModel;
	mWasDownloaded = false;
	mFileOffset = 0;
	setContent(content);
}
std::shared_ptr<linphone::Content> ContentModel::getContent()const{
	return mContent;
}

quint64 ContentModel::getFileSize() const{
	auto s = mContent->getFileSize();
	return (quint64)s;
}

QString ContentModel::getName() const{
	return Utils::coreStringToAppString(mContent->getName());
}

QString ContentModel::getThumbnail() const{
	return mThumbnail;
}


void ContentModel::setFileOffset(quint64 fileOffset){
	if( mFileOffset != fileOffset) {
		mFileOffset = fileOffset;
		emit fileOffsetChanged();
	}
}
void ContentModel::setThumbnail(const QString& data){
	if( mThumbnail != data) {
		mThumbnail = data;
		emit thumbnailChanged();
	}
}
void ContentModel::setWasDownloaded(bool wasDownloaded){
	if( mWasDownloaded != wasDownloaded) {
		mWasDownloaded = wasDownloaded;
		emit wasDownloadedChanged();
	}
}

void ContentModel::setContent(std::shared_ptr<linphone::Content> content){
	mContent = content;
	auto chatMessageFileContentModel = mChatMessageModel->getFileContentModel();
	if(chatMessageFileContentModel && chatMessageFileContentModel->getContent() == content){
		QString path = Utils::coreStringToAppString(mContent->getFilePath());
		if (!path.isEmpty() && (mChatMessageModel->isOutgoing() ||
								mChatMessageModel->getState() == LinphoneEnums::ChatMessageStateDisplayed))
			createThumbnail();
	}
}

// Create a thumbnail from the first content that have a file and store it in Appdata
void ContentModel::createThumbnail () {
	//if (!getChatMessageModel()->getChatMessage()->getAppdata().empty())
	//		return;// Already exist : no need to create one
	//std::list<std::shared_ptr<linphone::Content> > contents = message->getContents();
	//if( contents.size() > 0)
	//{
	auto chatMessageFileContentModel = mChatMessageModel->getFileContentModel();
	if( chatMessageFileContentModel && chatMessageFileContentModel->getContent() == mContent){
		QString id;
		QString path = Utils::coreStringToAppString(mChatMessageModel->getChatMessage()->getFileTransferInformation()->getFilePath());
		
		auto appdata = ChatMessageModel::AppDataManager(Utils::coreStringToAppString(mChatMessageModel->getChatMessage()->getAppdata()));
		
		if(!appdata.mData.contains(path) 
				|| !QFileInfo(Utils::coreStringToAppString(Paths::getThumbnailsDirPath())+appdata.mData[path]).isFile()){
			// File don't exist. Create the thumbnail
			
			QImage image(path);
			if( image.isNull()){// Try to determine format from headers
				QImageReader reader(path);
				reader.setDecideFormatFromContent(true);
				QByteArray format = reader.format();
				if(!format.isEmpty())
					image = QImage(path, format);
			}
			if (!image.isNull()){
				int rotation = 0;
				QExifImageHeader exifImageHeader;
				if (exifImageHeader.loadFromJpeg(path))
					rotation = int(exifImageHeader.value(QExifImageHeader::ImageTag::Orientation).toShort());
				QImage thumbnail = image.scaled(
							ThumbnailImageFileWidth, ThumbnailImageFileHeight,
							Qt::KeepAspectRatio, Qt::SmoothTransformation
							);
				
				if (rotation != 0) {
					QTransform transform;
					if (rotation == 3 || rotation == 4)
						transform.rotate(180);
					else if (rotation == 5 || rotation == 6)
						transform.rotate(90);
					else if (rotation == 7 || rotation == 8)
						transform.rotate(-90);
					thumbnail = thumbnail.transformed(transform);
					if (rotation == 2 || rotation == 4 || rotation == 5 || rotation == 7)
						thumbnail = thumbnail.mirrored(true, false);
				}
				QString uuid = QUuid::createUuid().toString();
				id = QStringLiteral("%1.jpg").arg(uuid.mid(1, uuid.length() - 2));
				
				if (!thumbnail.save(Utils::coreStringToAppString(Paths::getThumbnailsDirPath()) + id , "jpg", 100)) {
					qWarning() << QStringLiteral("Unable to create thumbnail of: `%1`.").arg(path);
				}else{
					appdata.mData[path] = id;
					mChatMessageModel->getChatMessage()->setAppdata(Utils::appStringToCoreString(appdata.toString()));
				}
			}
		}
		
		if( path != ""){
			setWasDownloaded( !path.isEmpty() && QFileInfo(path).isFile());
			if(appdata.mData.contains(path))
				setThumbnail(QStringLiteral("image://%1/%2").arg(ThumbnailProvider::ProviderId).arg(appdata.mData[path]));
		}
	}
	//message->setAppdata(Utils::appStringToCoreString(id+':'+path));
	//}
}

void ContentModel::downloadFile(){
	switch (mChatMessageModel->getState()) {
		case LinphoneEnums::ChatMessageStateDelivered:
		case LinphoneEnums::ChatMessageStateDeliveredToUser:
		case LinphoneEnums::ChatMessageStateDisplayed:
		case LinphoneEnums::ChatMessageStateFileTransferDone:
			break;
			
		default:
			qWarning() << QStringLiteral("Unable to download file of entry %1. It was not uploaded.").arg(mChatMessageModel->getState());
			return;
	}  
	bool soFarSoGood;
	QString filename = getName();//mFileTransfertContent->getName();
	const QString safeFilePath = Utils::getSafeFilePath(
				QStringLiteral("%1%2")
				.arg(CoreManager::getInstance()->getSettingsModel()->getDownloadFolder())
				.arg(filename),
				&soFarSoGood
				);
	
	if (!soFarSoGood) {
		qWarning() << QStringLiteral("Unable to create safe file path for: %1.").arg(filename);
		return;
	}
	mContent->setFilePath(Utils::appStringToCoreString(safeFilePath));
	//mChatMessage->getContents().front()->setFilePath(Utils::appStringToCoreString(safeFilePath));
	
	if( !mContent->isFileTransfer()){
		QMessageBox::warning(nullptr, "Download File", "This file was already downloaded and is no more on the server. Your peer have to resend it if you want to get it");
	}else
	{
		if (!mChatMessageModel->getChatMessage()->downloadContent(mContent))
			qWarning() << QStringLiteral("Unable to download file of entry %1.").arg(filename);
	}
}

void ContentModel::openFile (bool showDirectory) {
	if (!mWasDownloaded && !mChatMessageModel->isOutgoing()) {
		downloadFile();
	}else{
		QFileInfo info( Utils::coreStringToAppString(mContent->getFilePath()));
		QDesktopServices::openUrl(
					QUrl(QStringLiteral("file:///%1").arg(showDirectory ? info.absolutePath() : info.absoluteFilePath()))
					);
	}
}


// =============================================================================
ChatMessageListener::ChatMessageListener(ChatMessageModel * model, QObject* parent) : QObject(parent){
	connect(this, &ChatMessageListener::fileTransferRecv, model, &ChatMessageModel::onFileTransferRecv);
	connect(this, &ChatMessageListener::fileTransferSendChunk, model, &ChatMessageModel::onFileTransferSendChunk);
	connect(this, &ChatMessageListener::fileTransferSend, model, &ChatMessageModel::onFileTransferSend);
	connect(this, &ChatMessageListener::fileTransferProgressIndication, model, &ChatMessageModel::onFileTransferProgressIndication);
	connect(this, &ChatMessageListener::msgStateChanged, model, &ChatMessageModel::onMsgStateChanged);
	connect(this, &ChatMessageListener::participantImdnStateChanged, model, &ChatMessageModel::onParticipantImdnStateChanged);
	connect(this, &ChatMessageListener::ephemeralMessageTimerStarted, model, &ChatMessageModel::onEphemeralMessageTimerStarted);
	connect(this, &ChatMessageListener::ephemeralMessageDeleted, model, &ChatMessageModel::onEphemeralMessageDeleted);
	connect(this, &ChatMessageListener::participantImdnStateChanged, model->getParticipantImdnStates().get(), &ParticipantImdnStateListModel::onParticipantImdnStateChanged);
}



void ChatMessageListener::onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer){
	emit fileTransferRecv(message, content, buffer);
}
void ChatMessageListener::onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer){
	emit fileTransferSendChunk(message, content, offset, size, buffer);
}
std::shared_ptr<linphone::Buffer> ChatMessageListener::onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size) {
	emit fileTransferSend(message, content, offset, size);
	return nullptr;
}
void ChatMessageListener::onFileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t i){
	emit fileTransferProgressIndication(message, content, offset, i);
}
void ChatMessageListener::onMsgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state){
	emit msgStateChanged(message, state);
}
void ChatMessageListener::onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	emit participantImdnStateChanged(message, state);
}
void ChatMessageListener::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message){
	emit ephemeralMessageTimerStarted(message);
}
void ChatMessageListener::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message){
	emit ephemeralMessageDeleted(message);
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
ChatMessageModel::ChatMessageModel ( std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent) : QObject(parent), ChatEvent(ChatRoomModel::EntryType::MessageEntry) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it
	mParticipantImdnStateListModel = std::make_shared<ParticipantImdnStateListModel>(chatMessage);
	mChatMessageListener = std::make_shared<ChatMessageListener>(this, parent);
	mChatMessage = chatMessage;
	mWasDownloaded = false;
	mChatMessage->addListener(mChatMessageListener);
	mTimestamp = QDateTime::fromMSecsSinceEpoch(chatMessage->getTime() * 1000);
	connect(this, &ChatMessageModel::remove, dynamic_cast<ChatRoomModel*>(parent), &ChatRoomModel::removeEntry);
	
	std::list<std::shared_ptr<linphone::Content>> contents = chatMessage->getContents();
	QString txt;
	for(auto content : contents){
		if(content->isText())
			txt += Utils::coreStringToAppString(content->getUtf8Text());
	}
	mContent = txt;
	//mIsOutgoing = chatMessage->isOutgoing() || chatMessage->getState() == linphone::ChatMessage::State::Idle;
	
	// Old workaround.
	// It can exist messages with a not delivered status. It's a linphone core bug.
	/*
	linphone::ChatMessage::State state = chatMessage->getState();
	if (state == linphone::ChatMessage::State::InProgress)
		dest["status"] = ChatRoomModel::MessageStatusNotDelivered;
	else
		dest["status"] = static_cast<ChatRoomModel::MessageStatus>(chatMessage->getState());	
	*/
	
	auto content = chatMessage->getFileTransferInformation();
	if (content) {
		mFileTransfertContent = std::make_shared<ContentModel>(this);
		mFileTransfertContent->setContent(content);
		
	}
	for(auto content : chatMessage->getContents()){
		mContents << std::make_shared<ContentModel>(content, this);
	}
	
}

ChatMessageModel::~ChatMessageModel(){
	mChatMessage->removeListener(mChatMessageListener);
}
std::shared_ptr<ChatMessageModel> ChatMessageModel::create(std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent){
	auto model = std::make_shared<ChatMessageModel>(chatMessage, parent);
	return model;
}

std::shared_ptr<linphone::ChatMessage> ChatMessageModel::getChatMessage(){
	return mChatMessage;
}
std::shared_ptr<ContentModel> ChatMessageModel::getContentModel(std::shared_ptr<linphone::Content> content){
	if(content == mFileTransfertContent->getContent())
		return mFileTransfertContent;
	for(auto c : mContents)
		if(c->getContent() == content)
			return c;
	return nullptr;
}

ContentModel * ChatMessageModel::getContent(int i){
	return mContents[i].get();
}

//-----------------------------------------------------------------------------------------------------------------------

QString ChatMessageModel::getFromDisplayName() const{
	return Utils::getDisplayName(mChatMessage->getFromAddress());	
}

QString ChatMessageModel::getFromSipAddress() const{
	return Utils::cleanSipAddress(Utils::coreStringToAppString(mChatMessage->getFromAddress()->asStringUriOnly()));
}

QString ChatMessageModel::getToDisplayName() const{
	return Utils::getDisplayName(mChatMessage->getToAddress());
}

ContactModel * ChatMessageModel::getContactModel() const{
	return CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(Utils::coreStringToAppString(mChatMessage->getFromAddress()->asString()));
}

bool ChatMessageModel::isEphemeral() const{
	return mChatMessage->isEphemeral();
}

qint64 ChatMessageModel::getEphemeralExpireTime() const{
	time_t t = mChatMessage->getEphemeralExpireTime();
	return 	t >0 ? t - QDateTime::currentSecsSinceEpoch() : 0;
	//return QDateTime::fromMSecsSinceEpoch(mChatMessage->getEphemeralExpireTime() * 1000)
}

LinphoneEnums::ChatMessageState ChatMessageModel::getState() const{
	return LinphoneEnums::fromLinphone(mChatMessage->getState());
}

bool ChatMessageModel::isOutgoing() const{
	return mChatMessage->isOutgoing();
}

ContentModel * ChatMessageModel::getFileContentModel() const{
	return mFileTransfertContent.get();
}

QList<ContentModel*> ChatMessageModel::getContents() const{
	QList<ContentModel*> models;
	for(auto content : mContents)
		models << content.get();
	return models;
}

ParticipantImdnStateProxyModel * ChatMessageModel::getProxyImdnStates(){
	ParticipantImdnStateProxyModel * proxy = new ParticipantImdnStateProxyModel();
	proxy->setChatMessageModel(this);
	return proxy;
}

std::shared_ptr<ParticipantImdnStateListModel> ChatMessageModel::getParticipantImdnStates() const{
	return mParticipantImdnStateListModel;
}



//-----------------------------------------------------------------------------------------------------------------------



void ChatMessageModel::setWasDownloaded(bool wasDownloaded){
	if( mWasDownloaded != wasDownloaded) {
		mWasDownloaded = wasDownloaded;
		emit wasDownloadedChanged();
	}
}

//-----------------------------------------------------------------------------------------------------------------------

void ChatMessageModel::resendMessage (){
	switch (getState()) {
		case LinphoneEnums::ChatMessageStateFileTransferError:
		case LinphoneEnums::ChatMessageStateNotDelivered: {
			mChatMessage->send();
			break;
		}
			
		default:
			qWarning() << QStringLiteral("Unable to resend message: %1. Bad state.").arg(getState());
	}
}


void ChatMessageModel::deleteEvent(){
	if (mChatMessage && mChatMessage->getFileTransferInformation()) {// Remove thumbnail
		mChatMessage->cancelFileTransfer();
		QString appdata = Utils::coreStringToAppString(mChatMessage->getAppdata());
		QStringList fields = appdata.split(':');
		
		if(fields[0].size() > 0) {
			QString thumbnailPath = Utils::coreStringToAppString(Paths::getThumbnailsDirPath()) + fields[0];
			if (!QFile::remove(thumbnailPath))
				qWarning() << QStringLiteral("Unable to remove `%1`.").arg(thumbnailPath);
		}
		mChatMessage->setAppdata("");// Remove completely Thumbnail from the message
	}
	mChatMessage->getChatRoom()->deleteMessage(mChatMessage);
}
void ChatMessageModel::updateFileTransferInformation(){
	if( mFileTransfertContent && mFileTransfertContent->getContent() != getChatMessage()->getFileTransferInformation()){
		mFileTransfertContent->setContent(getChatMessage()->getFileTransferInformation());
	}
}

void ChatMessageModel::onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer){
}
void ChatMessageModel::onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer) {
	
}
std::shared_ptr<linphone::Buffer> ChatMessageModel::onFileTransferSend (const std::shared_ptr<linphone::ChatMessage> &,const std::shared_ptr<linphone::Content> &content,size_t,size_t) {
	return nullptr;
}

void ChatMessageModel::onFileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message,const std::shared_ptr<linphone::Content> &content,size_t offset,size_t) {
	// content parameter is not in getContents() and getFileTransferInformation(). Question? What is it? Workaround : use the current file transfert.
	// Note here : mFileTransfertContent->getContent() == getChatMessage()->getFileTransferInformation()
	// Idea : 
	//	auto model = getContentModel(content);
	//	if(model)
	//		model->setFileOffset(offset);
	mFileTransfertContent->setFileOffset(offset);
}

void ChatMessageModel::onMsgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state) {
	updateFileTransferInformation();// On message state, file transfert information Content can be changed
	// File message downloaded.
	if (state == linphone::ChatMessage::State::FileTransferDone && !mChatMessage->isOutgoing()) {
		if(mFileTransfertContent)
			mFileTransfertContent->createThumbnail();
		setWasDownloaded(true);
		App::getInstance()->getNotifier()->notifyReceivedFileMessage(message);
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
	emit remove(this);
}
//-------------------------------------------------------------------------------------------------------


