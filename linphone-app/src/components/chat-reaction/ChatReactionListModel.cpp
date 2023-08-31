/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#include "ChatReactionListModel.hpp"

#include "ChatReactionModel.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "utils/Utils.hpp"

// =============================================================================

ChatReactionListModel::ChatReactionListModel (ChatMessageModel * message, QObject* parent) : ProxyAbstractListModel<QVariantMap>(parent) {
	mParent = message;
	setChatMessageModel(message);
}

void ChatReactionListModel::setChatMessageModel(ChatMessageModel * message) {
	if(message){
		auto reactions = message->getChatMessage()->getReactions();
		mReactions.clear();
		mBodies.clear();
		for(auto reaction : reactions){
			auto reactionModel = QSharedPointer<ChatReactionModel>::create(reaction);
			auto body = reactionModel->getBody();
			if(!body.isEmpty()) {
				mReactions[reactionModel->getFromAddress()] = reactionModel;
				mBodies[reactionModel->getBody()].push_back(reactionModel);
			}
		}
		updateList();
	}
}

int ChatReactionListModel::count(){
	return mList.count();
}

int ChatReactionListModel::getChatReactionCount(const QString& emoji) const {
	if(emoji.isEmpty())
		return mReactions.size();
	else if(mBodies.contains(emoji))
		return mBodies[emoji].size();
	else
		return 0;
}

QSharedPointer<ChatReactionModel> ChatReactionListModel::add(std::shared_ptr<linphone::ChatMessageReaction> reaction){
	auto reactionModel = QSharedPointer<ChatReactionModel>::create(reaction);
	//ProxyListModel::add(reactionModel);
	emit chatReactionsChanged();
	return reactionModel;
}
	

void ChatReactionListModel::remove(ChatReactionModel * model){/*
	int count = 0;
	for(auto it = mList.begin() ; it != mList.end() ; ++count, ++it) {
		if( it->get() == model) {
			removeRow(count, QModelIndex());
			return;
		}
	}*/
}

void ChatReactionListModel::clear(){
	resetData();
}

/*
QSharedPointer<ChatReactionModel> ChatReactionListModel::getChatReactionModel(const std::shared_ptr<const linphone::ChatMessageReaction>& reaction){
	for(auto item : mList){
		auto c = item.objectCast<ChatReactionModel>();
		if(c->get() == content)
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
*/
void ChatReactionListModel::updateChatReaction(const std::shared_ptr<const linphone::ChatMessageReaction>& reaction) {
	QString address = Utils::coreStringToAppString(reaction->getFromAddress()->asStringUriOnly());
	auto itReaction = mReactions.find(address);
	int oldReactionCount = mReactions.size();
	if( itReaction == mReactions.end()) {// New
		auto reactionModel = QSharedPointer<ChatReactionModel>::create(reaction);
		auto body = reactionModel->getBody();
		if(body.isEmpty()) {
			mReactions.remove(reactionModel->getFromAddress());
			// TODO: optimize remove
			mBodies.clear();
			for(auto it : mReactions)
				mBodies[it->getBody()].push_back(it);
		}else{
			mReactions[reactionModel->getFromAddress()] = reactionModel;
			mBodies[reactionModel->getBody()].push_back(reactionModel);
		}
	}else{// Update
		(*itReaction)->setBody(Utils::coreStringToAppString(reaction->getBody()));
		// TODO: optimize update with a swap
		mBodies.clear();
		for(auto it : mReactions)
			mBodies[it->getBody()].push_back(it);
	}
	updateList();
	if(oldReactionCount != mReactions.size())
		emit chatReactionCountChanged();
}
void ChatReactionListModel::updateList(){
	QList<QVariantMap> data;
	if(mGroupBy == EMOJIES){
		for(auto it = mBodies.begin() ; it != mBodies.end() ; ++it) {
			QVariantMap emoji;
			emoji["body"] = it.key();
			emoji["reactionsCount"] = it->size();
			data << emoji;
		}
	}else{
		for(auto reaction : mReactions){
			QVariantMap react;
			react["reaction"] = QVariant::fromValue(reaction.get());
			data << react;
		}
	}
	resetData();
	ProxyAbstractListModel<QVariantMap>::add(data);
	emit chatReactionsChanged();
}
		
bool ChatReactionListModel::exists(std::shared_ptr<linphone::ChatMessageReaction> reaction) const {
	QString address = Utils::coreStringToAppString(reaction->getFromAddress()->asStringUriOnly());
	auto itReaction = mReactions.find(address);
	if(itReaction != mReactions.end())
		return (*itReaction)->getBody() == Utils::coreStringToAppString(reaction->getBody());
	return false;
}
		
void ChatReactionListModel::updateChatReaction(std::shared_ptr<linphone::ChatMessageReaction> oldReaction, std::shared_ptr<linphone::ChatMessageReaction> newReaction) {


}
void ChatReactionListModel::updateChatReaction(ChatMessageModel * messageModel) {

}

ChatReactionListModel::GROUP_BY_TYPE ChatReactionListModel::getGroupBy() const {
	return mGroupBy;
}

void ChatReactionListModel::setGroupBy(ChatReactionListModel::GROUP_BY_TYPE mode) {
	if( mGroupBy != mode ) {
		mGroupBy = mode;
		updateList();
		emit groupByChanged();
	}
}


/*

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
}*/
