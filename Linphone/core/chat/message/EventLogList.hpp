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

#ifndef EVENT_LOG_LIST_H_
#define EVENT_LOG_LIST_H_

#include "core/proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QLocale>

class EventLogGui;
class EventLogCore;
class ChatCore;
class ChatGui;
class ChatModel;
// =============================================================================

class EventLogList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	static QSharedPointer<EventLogList> create();
	EventLogList(QObject *parent = Q_NULLPTR);
	~EventLogList();

	QSharedPointer<ChatCore> getChatCore() const;
	ChatGui *getChat() const;
	void setChatCore(QSharedPointer<ChatCore> core);
	void setChatGui(ChatGui *chat);

	void connectItem(const QSharedPointer<EventLogCore> &item);
	void disconnectItem(const QSharedPointer<EventLogCore> &item);

	void setIsUpdating(bool updating);

	int findFirstUnreadIndex();

	void findChatMessageWithFilter(QString filter,
	                               QSharedPointer<EventLogCore> startEvent,
	                               bool forward = true,
	                               bool isFirstResearch = true);

	void setSelf(QSharedPointer<EventLogList> me);
	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
	QHash<int, QByteArray> roleNames() const override;

signals:
	void lUpdate();
	void filterChanged(QString filter);
	void eventInserted(int index, EventLogGui *message);
	void messageWithFilterFound(int index);
	void listAboutToBeReset();
	void chatGuiChanged();
	void isUpdatingChanged();

private:
	QString mFilter;
	QSharedPointer<ChatCore> mChatCore;
	QSharedPointer<SafeConnection<ChatCore, ChatModel>> mChatModelConnection;
	QSharedPointer<SafeConnection<EventLogList, CoreModel>> mCoreModelConnection;
	bool mIsUpdating = false;
	DECLARE_ABSTRACT_OBJECT
};

#endif
