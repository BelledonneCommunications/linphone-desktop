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
	connect(mContents.get(), &ChatReactionListModel::bodiesChanged, this, &ChatReactionProxyModel::bodiesChanged);
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

QStringList ChatReactionProxyModel::getBodies() const {
	auto model = qobject_cast<ChatReactionListModel*>(sourceModel());
	if(model) {
		return model->getBodies();
	}else
		return QStringList();
}

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
	auto a = sourceModel()->data(left).value<QVariantMap>();
	auto b = sourceModel()->data(right).value<QVariantMap>();
	
}
*/