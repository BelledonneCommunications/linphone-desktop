/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef CHAT_LIST_H_
#define CHAT_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QLocale>

class ChatGui;
class ChatCore;
// =============================================================================

class ChatList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	static QSharedPointer<ChatList> create();
	// Create a ChatCore and make connections to List.
	QSharedPointer<ChatCore> createChatCore(const std::shared_ptr<linphone::ChatRoom> &chatroom);
	ChatList(QObject *parent = Q_NULLPTR);
	~ChatList();
	void setSelf(QSharedPointer<ChatList> me);

	int findChatIndex(ChatGui *chat);
	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void lUpdate();
	void filterChanged(QString filter);

private:
	QString mFilter;
	QSharedPointer<SafeConnection<ChatList, CoreModel>> mModelConnection;
	DECLARE_ABSTRACT_OBJECT
};

#endif
