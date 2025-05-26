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

#ifndef CHAT_MESSAGE_CONTENT_LIST_H_
#define CHAT_MESSAGE_CONTENT_LIST_H_

#include "core/proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QLocale>

class ChatMessageGui;
class ChatMessageCore;
// =============================================================================

class ChatMessageContentList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	static QSharedPointer<ChatMessageContentList> create();
	ChatMessageContentList(QObject *parent = Q_NULLPTR);
	~ChatMessageContentList();

	QSharedPointer<ChatMessageCore> getChatMessageCore() const;
	ChatMessageGui *getChatMessage() const;
	void setChatMessageCore(QSharedPointer<ChatMessageCore> core);
	void setChatMessageGui(ChatMessageGui *chat);

	int findFirstUnreadIndex();

	void setSelf(QSharedPointer<ChatMessageContentList> me);
	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void lAddFile(QString path);
	void isFileChanged();
	void lUpdate();
	void chatMessageChanged();

private:
	QSharedPointer<ChatMessageCore> mChatMessageCore;
	QSharedPointer<SafeConnection<ChatMessageContentList, CoreModel>> mModelConnection;
	DECLARE_ABSTRACT_OBJECT
};

#endif
