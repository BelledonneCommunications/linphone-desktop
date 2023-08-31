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

#include "ChatReactionProxyModel.hpp"

#include "ChatReactionListModel.hpp"
#include "ChatReactionModel.hpp"

// =============================================================================

ChatReactionProxyModel::ChatReactionProxyModel (QObject * parent) : SortFilterProxyModel(parent){
	mContents = QSharedPointer<ChatReactionListModel>::create();
	connect(mContents.get(), &ChatReactionListModel::chatReactionCountChanged, this, &ChatReactionProxyModel::chatReactionCountChanged);
	connect(mContents.get(), &ChatReactionListModel::groupByChanged, this, &ChatReactionProxyModel::groupByChanged);
	setSourceModel(mContents.get());
	sort(0);
}

ChatMessageModel * ChatReactionProxyModel::getChatMessageModel() const{
	return nullptr;
}

void ChatReactionProxyModel::setChatMessageModel(ChatMessageModel * message){
	setChatMessageModel(message, ChatReactionListModel::GROUP_BY_TYPE::EMOJIES);
}

void ChatReactionProxyModel::setChatMessageModel(ChatMessageModel * message, ChatReactionListModel::GROUP_BY_TYPE groupByMode) {
	if(message){
		auto model = qobject_cast<ChatReactionListModel*>(sourceModel());
		model->setChatMessageModel(message);
		model->setGroupBy(groupByMode);
	}
	emit chatMessageModelChanged();
	emit chatReactionCountChanged();
}

int ChatReactionProxyModel::getChatReactionCount() const {
	auto model = qobject_cast<ChatReactionListModel*>(sourceModel());
	if(model)
		return model->getChatReactionCount();
	else
		return 0;
}

int ChatReactionProxyModel::getChatReactionCount(const QString& emoji) const {
	auto model = qobject_cast<ChatReactionListModel*>(sourceModel());
	if(model)
		return model->getChatReactionCount(emoji);
	else
		return 0;
}

ChatReactionListModel::GROUP_BY_TYPE ChatReactionProxyModel::getGroupBy() const {
	auto model = qobject_cast<ChatReactionListModel*>(sourceModel());
	return model ? model->getGroupBy() : ChatReactionListModel::GROUP_BY_TYPE::EMOJIES;
}

void ChatReactionProxyModel::setGroupBy(ChatReactionListModel::GROUP_BY_TYPE mode) {
	auto model = qobject_cast<ChatReactionListModel*>(sourceModel());
	if(model)
		model->setGroupBy(mode);
}

QString ChatReactionProxyModel::getFilter() const {
	return mFilter;
}

void ChatReactionProxyModel::setFilter(const QString& filter) {
	if(mFilter != filter) {
		mFilter = filter;
		emit filterChanged();
		invalidate();
	}
}

/*
void ChatReactionProxyModel::setContentListModel(ContentListModel * model){
	setSourceModel(model);
	sort(0);
	emit chatMessageModelChanged();
}
*/

bool ChatReactionProxyModel::filterAcceptsRow (
		int sourceRow,
		const QModelIndex &sourceParent
		) const {
		
	bool show = false;
	
	if (mFilter.isEmpty())
		show = true;
	else{
		auto model = qobject_cast<ChatReactionListModel*>(sourceModel());
		QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
		auto reaction = sourceModel()->data(index).value<QVariantMap>();
		
		if( model->getGroupBy() == ChatReactionListModel::GROUP_BY_TYPE::REACTIONS) {
			if( mFilter == reaction["reaction"].value<ChatReactionModel*>()->getBody())
				show = true;
		}
	}
	return show;
}

/*
bool ChatReactionProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const ContentModel *contentA = sourceModel()->data(left).value<ContentModel *>();
	const ContentModel *contentB = sourceModel()->data(right).value<ContentModel *>();
	bool aIsForward = contentA->getChatMessageModel() && contentA->getChatMessageModel()->isForward();
	bool aIsReply = contentA->getChatMessageModel() && contentA->getChatMessageModel()->isReply();
	bool aIsVoiceRecording = contentA->isVoiceRecording();
	bool aIsFile = contentA->isFile() || contentA->isFileEncrypted() || contentA->isFileTransfer();
	bool aIsText = contentA->isText() ;
	bool bIsForward = contentB->getChatMessageModel() && contentB->getChatMessageModel()->isForward();
	bool bIsReply = contentB->getChatMessageModel() && contentB->getChatMessageModel()->isReply();
	bool bIsVoiceRecording = contentB->isVoiceRecording();
	bool bIsFile = contentB->isFile() || contentB->isFileEncrypted() || contentB->isFileTransfer();
	bool bIsText = contentB->isText() ;
	
	return !bIsForward && (aIsForward
			|| !bIsReply && (aIsReply
				|| !bIsVoiceRecording && (aIsVoiceRecording
					|| !bIsFile && (aIsFile
						|| aIsText && !bIsText
						)
					)
				)
			);
}
*/
/*
void ChatReactionProxyModel::remove(ContentModel * model){
	qobject_cast<ContentListModel*>(sourceModel())->remove(model);
}

void ChatReactionProxyModel::clear(){
	qobject_cast<ContentListModel*>(sourceModel())->clear();
}

ContentProxyModel::FilterContentType ChatReactionProxyModel::getFilter() const{
	return mFilter;
}
void ChatReactionProxyModel::setFilter(const FilterContentType& contentType){
	if(contentType != mFilter){
		mFilter = contentType;
		emit filterChanged();
		invalidate();
	}
}*/