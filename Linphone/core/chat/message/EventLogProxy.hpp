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
// #include "core/proxy/LimitProxy.hpp"
#include "tool/AbstractObject.hpp"
#include <QSortFilterProxyModel>

// =============================================================================

class ChatGui;

class EventLogProxy : public QSortFilterProxyModel, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)
	Q_PROPERTY(ChatGui *chatGui READ getChatGui WRITE setChatGui NOTIFY chatGuiChanged)
	Q_PROPERTY(int initialDisplayItems READ getInitialDisplayItems WRITE setInitialDisplayItems NOTIFY
	               initialDisplayItemsChanged)
	Q_PROPERTY(int maxDisplayItems READ getMaxDisplayItems WRITE setMaxDisplayItems NOTIFY maxDisplayItemsChanged)
	Q_PROPERTY(int displayItemsStep READ getDisplayItemsStep WRITE setDisplayItemsStep NOTIFY displayItemsStepChanged)
	Q_PROPERTY(QString filterText READ getFilterText WRITE setFilterText NOTIFY filterTextChanged)

public:
	// DECLARE_SORTFILTER_CLASS()

	EventLogProxy(QObject *parent = Q_NULLPTR);
	~EventLogProxy();

	ChatGui *getChatGui();
	void setChatGui(ChatGui *chat);

	void setSourceModel(QAbstractItemModel *sourceModel) override;
	virtual int getCount() const;
	static int getDisplayCount(int listCount, int maxCount);
	int getDisplayCount(int listCount) const;
	int getInitialDisplayItems() const;
	void setInitialDisplayItems(int initialItems);

	int getMaxDisplayItems() const;
	void setMaxDisplayItems(int maxItems);

	int getDisplayItemsStep() const;
	void setDisplayItemsStep(int step);

	QString getFilterText() const;
	void setFilterText(const QString &filter);

	// bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	// bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

	QSharedPointer<EventLogCore> getAt(int atIndex) const;

	Q_INVOKABLE void displayMore();
	Q_INVOKABLE void loadUntil(int index);
	Q_INVOKABLE EventLogGui *getEventAtIndex(int i);
	QSharedPointer<EventLogCore> getEventCoreAtIndex(int i);
	Q_INVOKABLE int findFirstUnreadIndex();
	Q_INVOKABLE void markIndexAsRead(int proxyIndex);
	Q_INVOKABLE void findIndexCorrespondingToFilter(int startIndex, bool forward = true, bool isFirstResearch = true);

signals:
	void eventInsertedByUser(int index);
	void indexWithFilterFound(int index);
	void chatGuiChanged();
	void countChanged();
	void initialDisplayItemsChanged();
	void maxDisplayItemsChanged();
	void displayItemsStepChanged();
	void filterTextChanged();

protected:
	QSharedPointer<EventLogList> mList;
	QSharedPointer<EventLogCore> mLastSearchStart;
	ChatGui *mChatGui = nullptr;
	int mInitialDisplayItems = -1;
	int mMaxDisplayItems = -1;
	int mDisplayItemsStep = 5;
	QString mFilterText;
	DECLARE_ABSTRACT_OBJECT
};

#endif
