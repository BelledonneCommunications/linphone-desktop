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
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

ContentListModel::ContentListModel (ChatMessageModel * message) : QAbstractListModel(message) {
	std::list<std::shared_ptr<linphone::Content>> contents = message->getChatMessage()->getContents() ;
	for(auto content : contents){
		auto contentModel = std::make_shared<ContentModel>(content, message);
		connect(this, &ContentListModel::updateTransferDataRequested, contentModel.get(), &ContentModel::updateTransferData);
		mList << contentModel;
	}
}

int ContentListModel::rowCount (const QModelIndex &index) const{
	return mList.count();
}

int ContentListModel::count(){
	return mList.count();
}

QHash<int, QByteArray> ContentListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "modelData";
	return roles;
}

QVariant ContentListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row].get());
	
	return QVariant();
}

bool ContentListModel::removeRow (int row, const QModelIndex &parent){
	return removeRows(row, 1, parent);
}

bool ContentListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row);
	
	endRemoveRows();
	
	return true;
}
std::shared_ptr<ContentModel> ContentListModel::getContentModel(std::shared_ptr<linphone::Content> content){
	for(auto c : mList)
		if(c->getContent() == content)
			return c;
	if(content->isFileTransfer() || content->isFile() || content->isFileEncrypted()){
		for(auto c : mList)// Content object can be different for file (like while data transfer)
			if(c->getContent()->getFilePath() == content->getFilePath())
				return c;
	}
	return nullptr;
}
void ContentListModel::updateContent(std::shared_ptr<linphone::Content> oldContent, std::shared_ptr<linphone::Content> newContent){
	int row = 0;
	for(auto content = mList.begin() ; content != mList.end() ; ++content, ++row){
		if( (*content)->getContent() == oldContent){
			mList.replace(row, std::make_shared<ContentModel>(newContent, (*content)->getChatMessageModel()));
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
			mList.insert(count, std::make_shared<ContentModel>(content, messageModel));
		}else if(mList.at(count)->getContent() != content){	// This content is not at its place
			int c = count + 1;
			while( c < mList.size() && mList.at(c)->getContent() != content)
				++c;
			if( c < mList.size()){// Found => swap position
				mList.swap(count, c);
			}else{// content is new
				mList.insert(count, std::make_shared<ContentModel>(content, messageModel));	
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
		content->createThumbnail();
}