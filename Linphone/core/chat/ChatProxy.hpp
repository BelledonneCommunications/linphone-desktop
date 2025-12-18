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

#ifndef CHAT_PROXY_H_
#define CHAT_PROXY_H_

#include "../proxy/SortFilterProxy.hpp"
#include "core/chat/ChatGui.hpp"
#include "core/chat/ChatList.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class ChatProxy : public SortFilterProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(QAbstractItemModel *model WRITE setSourceModel )

public:
	ChatProxy(QObject *parent = Q_NULLPTR);
	~ChatProxy();

	void setSourceModel(QAbstractItemModel *sourceModel) override;

	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

	Q_INVOKABLE int findChatIndex(ChatGui *chatGui);
	Q_INVOKABLE bool addChatInList(ChatGui *chatGui);

signals:
	void chatAdded(ChatGui *chat);

protected:
	QSharedPointer<ChatList> mList;
	DECLARE_ABSTRACT_OBJECT
};

#endif
