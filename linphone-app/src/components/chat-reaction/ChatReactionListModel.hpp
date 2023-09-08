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

#ifndef CHAT_REACTION_LIST_MODEL_H_
#define CHAT_REACTION_LIST_MODEL_H_

#include <linphone++/linphone.hh>
#include "app/proxyModel/ProxyAbstractListModel.hpp"
#include <QDateTime>

class ChatReactionModel;
class ChatMessageModel;

class ChatReactionListModel : public ProxyAbstractListModel<QVariantMap> {
	Q_OBJECT
	
public:
	typedef enum{
		EMOJIES,
		REACTIONS
	}GROUP_BY_TYPE;
	Q_ENUM(GROUP_BY_TYPE)
	
	ChatReactionListModel (ChatMessageModel * message = nullptr, QObject * parent = nullptr);
	void setChatMessageModel(ChatMessageModel * message);
	
	int count();
	int getChatReactionCount(const QString& emoji = "")const;
	
	QSharedPointer<ChatReactionModel> add(std::shared_ptr<linphone::ChatMessageReaction> reaction);
	Q_INVOKABLE void remove(ChatReactionModel * model);
	
	void clear();
	
	ChatReactionListModel::GROUP_BY_TYPE getGroupBy() const;
	void setGroupBy(ChatReactionListModel::GROUP_BY_TYPE mode);
	
	QStringList getBodies() const;
	
	//QSharedPointer<ChatReactionModel> getChatReactionModel(const std::shared_ptr<const linphone::ChatMessageReaction>& reaction);
	
	bool exists(std::shared_ptr<linphone::ChatMessageReaction> reaction) const;
	
	void updateChatReaction(std::shared_ptr<linphone::ChatMessageReaction> oldReaction, std::shared_ptr<linphone::ChatMessageReaction> newReaction);
	void updateChatReaction(const std::shared_ptr<const linphone::ChatMessageReaction>& reaction);
	void updateChatReaction(ChatMessageModel * messageModel);
	
	void updateList();
	
	void onNewMessageReaction(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction);
	void onReactionRemoved(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::Address> & address);
signals:
	void chatReactionsChanged();
	void chatReactionCountChanged();
	void groupByChanged();
	void bodiesChanged();
	
private:
	ChatMessageModel * mParent = nullptr;
	QMap<QString, QSharedPointer<ChatReactionModel>> mReactions;
	QMap<QString, QVector<QSharedPointer<ChatReactionModel>>> mBodies;
	GROUP_BY_TYPE mGroupBy = EMOJIES;
	
};

Q_DECLARE_METATYPE(std::shared_ptr<ChatReactionListModel>)

#endif
