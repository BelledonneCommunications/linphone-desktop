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

#ifndef EVENT_LIST_PROXY_H_
#define EVENT_LIST_PROXY_H_

#include "EventLogList.hpp"
#include "core/proxy/LimitProxy.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class ChatGui;

class EventLogProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(ChatGui *chatGui READ getChatGui WRITE setChatGui NOTIFY eventChanged)

public:
	DECLARE_SORTFILTER_CLASS()

	EventLogProxy(QObject *parent = Q_NULLPTR);
	~EventLogProxy();

	ChatGui *getChatGui();
	void setChatGui(ChatGui *chat);

	void setSourceModel(QAbstractItemModel *sourceModel) override;

	Q_INVOKABLE void loadUntil(int index);
	Q_INVOKABLE EventLogGui *getEventAtIndex(int i);
	QSharedPointer<EventLogCore> getEventCoreAtIndex(int i);
	Q_INVOKABLE int findFirstUnreadIndex();
	Q_INVOKABLE void markIndexAsRead(int proxyIndex);
	Q_INVOKABLE void findIndexCorrespondingToFilter(int startIndex, bool forward = true, bool isFirstResearch = true);

signals:
	void eventChanged();
	void eventInserted(int index, EventLogGui *message);
	void indexWithFilterFound(int index);
	void listAboutToBeReset();

protected:
	QSharedPointer<EventLogList> mList;
	QSharedPointer<EventLogCore> mLastSearchStart;
	ChatGui *mChatGui = nullptr;
	DECLARE_ABSTRACT_OBJECT
};

#endif
