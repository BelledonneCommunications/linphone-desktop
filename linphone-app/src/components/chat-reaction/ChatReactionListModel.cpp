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
	setChatMessageModel(message);
}

void ChatReactionListModel::setChatMessageModel(ChatMessageModel * message) {
	if(mParent) {
		disconnect(message, &ChatMessageModel::newMessageReaction, this, &ChatReactionListModel::onNewMessageReaction);
		disconnect(message, &ChatMessageModel::reactionRemoved, this, &ChatReactionListModel::onReactionRemoved);
	}
	mParent = message;
	if(mParent) {
		connect(message, &ChatMessageModel::newMessageReaction, this, &ChatReactionListModel::onNewMessageReaction);
		connect(message, &ChatMessageModel::reactionRemoved, this, &ChatReactionListModel::onReactionRemoved);
	}
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
		emit bodiesChanged();
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
	

void ChatReactionListModel::remove(ChatReactionModel * model){
}

void ChatReactionListModel::clear(){
	resetData();
}

void ChatReactionListModel::updateChatReaction(const std::shared_ptr<const linphone::ChatMessageReaction>& reaction) {
	auto fromAddress = reaction->getFromAddress()->clone();
	fromAddress->clean();
	QString address = Utils::coreStringToAppString(fromAddress->asStringUriOnly());
	auto itReaction = mReactions.find(address);
	int oldReactionCount = mReactions.size();
	auto oldBodies = getBodies();
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
	emit bodiesChanged();
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
	auto fromAddress = reaction->getFromAddress()->clone();
	fromAddress->clean();
	QString address = Utils::coreStringToAppString(fromAddress->asStringUriOnly());
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

QStringList ChatReactionListModel::getBodies() const {
	auto bodies = mBodies.keys();
	auto reactions = Constants::getReactionsList();
	std::sort(bodies.begin(), bodies.end(), [&](const QString& a, const QString& b){
		for(auto reaction : reactions){
			if( a == reaction) return true;
			if( b == reaction) return false;
		}
		return a < b;
	});
	return bodies;
}

void ChatReactionListModel::onNewMessageReaction(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction){
	updateChatReaction(reaction);
}
void ChatReactionListModel::onReactionRemoved(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::Address> & address) {
	auto fromAddress = address->clone();
	fromAddress->clean();
	mReactions.remove(Utils::coreStringToAppString(fromAddress->asStringUriOnly()));
	mBodies.clear();
	for(auto it : mReactions)
		mBodies[it->getBody()].push_back(it);
	updateList();
	emit chatReactionCountChanged();
	emit bodiesChanged();
}
