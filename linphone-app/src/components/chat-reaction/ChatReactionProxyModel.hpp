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

#ifndef CHAT_REACTION_PROXY_MODEL_H_
#define CHAT_REACTION_PROXY_MODEL_H_

#include "app/proxyModel/SortFilterProxyModel.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "ChatReactionListModel.hpp"

// =============================================================================

class ChatReactionProxyModel : public SortFilterProxyModel {
	Q_OBJECT
	
public:
	ChatReactionProxyModel (QObject *parent = nullptr);	
	Q_PROPERTY(ChatMessageModel * chatMessageModel READ getChatMessageModel WRITE setChatMessageModel NOTIFY chatMessageModelChanged)
	Q_PROPERTY(int reactionCount READ getChatReactionCount NOTIFY chatReactionCountChanged)
	Q_PROPERTY(ChatReactionListModel::GROUP_BY_TYPE groupBy READ getGroupBy WRITE setGroupBy NOTIFY groupByChanged)
	Q_PROPERTY(QString filter READ getFilter WRITE setFilter NOTIFY filterChanged)
	Q_PROPERTY(QStringList bodies READ getBodies NOTIFY bodiesChanged)
	
	ChatMessageModel * getChatMessageModel() const;
	void setChatMessageModel(ChatMessageModel * message);
	Q_INVOKABLE void setChatMessageModel(ChatMessageModel * message, ChatReactionListModel::GROUP_BY_TYPE groupByMode);
	
	int getChatReactionCount() const;
	Q_INVOKABLE int getChatReactionCount(const QString& emoji) const;
	
	ChatReactionListModel::GROUP_BY_TYPE getGroupBy() const;
	void setGroupBy(ChatReactionListModel::GROUP_BY_TYPE mode);
	
	QString getFilter() const;
	void setFilter(const QString& filter);
	
	QStringList getBodies() const;
	
signals:
	void chatMessageModelChanged();
	void chatReactionCountChanged();
	void groupByChanged();
	void filterChanged();
	void bodiesChanged();
	
	
protected:
	QSharedPointer<ChatReactionListModel> mContents;
	virtual bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	//virtual bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
	//std::shared_ptr<ChatReacListModel> mContents;
	QString mFilter = "";
};


#endif
