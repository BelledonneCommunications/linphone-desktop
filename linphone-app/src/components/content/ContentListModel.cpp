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

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "ContentListModel.hpp"
#include "ContentModel.hpp"
#include "utils/Constants.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

ContentListModel::ContentListModel (ChatMessageModel * message, QObject* parent) : ProxyListModel(parent) {
	mParent = message;
	if(message){
		std::list<std::shared_ptr<linphone::Content>> contents = message->getChatMessage()->getContents() ;
		for(auto content : contents){
			auto contentModel = QSharedPointer<ContentModel>::create(content, message);
			connect(this, &ContentListModel::updateTransferDataRequested, contentModel.get(), &ContentModel::updateTransferData);
			mList << contentModel;
		}
	}
}

int ContentListModel::count(){
	return mList.count();
}

QSharedPointer<ContentModel> ContentListModel::add(std::shared_ptr<linphone::Content> content){
	auto contentModel = QSharedPointer<ContentModel>::create(content, mParent);
	ProxyListModel::add(contentModel);
	emit contentsChanged();
	return contentModel;
}

void ContentListModel::addFile(const QString& path){
	QFile file(path);
	if (!file.exists())
		return;
	
	qint64 fileSize = file.size();
	if (fileSize > Constants::FileSizeLimit) {
		qWarning() << QStringLiteral("Unable to send file. (Size limit=%1)").arg(Constants::FileSizeLimit);
		return;
	}
	
	std::shared_ptr<linphone::Content> content = CoreManager::getInstance()->getCore()->createContent();
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
	content->setName(QFileInfo(file).fileName().toStdString());
	content->setFilePath(Utils::appStringToCoreString(path));
	
	auto modelAdded = add(content);
	if(!content->isFile())
		modelAdded->createThumbnail(true);	// Was not created because linphone::Content is not considered as a file (yet)
}

void ContentListModel::remove(ContentModel * model){
	int count = 0;
	for(auto it = mList.begin() ; it != mList.end() ; ++count, ++it) {
		if( it->get() == model) {
			removeRow(count, QModelIndex());
			return;
		}
	}
}

void ContentListModel::clear(){
	resetData();
}

void ContentListModel::removeDownloadedFiles(){
	for(auto model : mList){
		auto contentModel = model.objectCast<ContentModel>();
		contentModel->removeDownloadedFile();
	}
}

QSharedPointer<ContentModel> ContentListModel::getContentModel(std::shared_ptr<linphone::Content> content){
	for(auto item : mList){
		auto c = item.objectCast<ContentModel>();
		if(c->getContent() == content)
			return c;
	}
	if(content->isFileTransfer() || content->isFile() || content->isFileEncrypted()){
		for(auto item : mList){// Content object can be different for file (like while data transfer)
			auto c = item.objectCast<ContentModel>();
			if(c->getContent()->getFilePath() == content->getFilePath())
				return c;
		}
	}
	return nullptr;
}

void ContentListModel::updateContent(std::shared_ptr<linphone::Content> oldContent, std::shared_ptr<linphone::Content> newContent){
	int row = 0;
	for(auto content = mList.begin() ; content != mList.end() ; ++content, ++row){
		auto contentModel = content->objectCast<ContentModel>();
		if( contentModel->getContent() == oldContent){
			mList.replace(row, QSharedPointer<ContentModel>::create(newContent, contentModel->getChatMessageModel()));
			emit dataChanged(index(row,0), index(row,0));
			return;
		}
	}
}

void ContentListModel::updateContents(ChatMessageModel * messageModel){
	std::list<std::shared_ptr<linphone::Content>> contents = messageModel->getChatMessage()->getContents() ;
	int count = 0;
	beginResetModel();
	for(auto content : contents){
		if( count >= mList.size()){// New content
			mList.insert(count, QSharedPointer<ContentModel>::create(content, messageModel));
		}else if(mList.at(count).objectCast<ContentModel>()->getContent() != content){	// This content is not at its place
			int c = count + 1;
			while( c < mList.size() && mList.at(c).objectCast<ContentModel>()->getContent() != content)
				++c;
			if( c < mList.size()){// Found => swap position
#if QT_VERSION < QT_VERSION_CHECK(5, 13, 0)
				mList.swap(count, c);
#else
				mList.swapItemsAt(count, c);
#endif
			}else{// content is new
				mList.insert(count, QSharedPointer<ContentModel>::create(content, messageModel));	
			}
		}
		++count;
	}
	if(count < mList.size())// Remove all old contents
		mList.erase(mList.begin()+count, mList.end());
	endResetModel();
}

void ContentListModel::updateAllTransferData(){
	emit updateTransferDataRequested();
}

void ContentListModel::downloaded(){
	for(auto content : mList)
		content.objectCast<ContentModel>()->createThumbnail();
}