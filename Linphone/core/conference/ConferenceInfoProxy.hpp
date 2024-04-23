/*
 * Copyright (c) 2020 Belledonne Communications SARL.
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

#ifndef CONFERENCE_INFO_PROXY_H_
#define CONFERENCE_INFO_PROXY_H_

#include "../proxy/SortFilterProxy.hpp"
#include "tool/AbstractObject.hpp"

class ConferenceInfoList;

class ConferenceInfoProxy : public SortFilterProxy, public AbstractObject {

	Q_OBJECT
	Q_PROPERTY(QString searchText READ getSearchText WRITE setSearchText NOTIFY searchTextChanged)
	Q_PROPERTY(bool haveCurrentDate READ haveCurrentDate NOTIFY haveCurrentDateChanged)
	Q_PROPERTY(int currentDateIndex READ getCurrentDateIndex NOTIFY currentDateIndexChanged)

public:
	enum ConferenceInfoFiltering { None = 0, Future = 1 };
	Q_ENUM(ConferenceInfoFiltering)
public:
	ConferenceInfoProxy(QObject *parent = Q_NULLPTR);
	~ConferenceInfoProxy();

	QString getSearchText() const;
	void setSearchText(const QString &search);

	bool haveCurrentDate() const;

	int getCurrentDateIndex() const;
	void updateCurrentDateIndex();

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	// Do not use the sort feature. We cannot retrieve indexes with mapToSource because Qt return -1 for items that are
	// not displayed. We need it to know where The workaround is to implement ourself the sort into the List.
	// bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

signals:
	void searchTextChanged();
	void haveCurrentDateChanged();
	void currentDateIndexChanged();

private:
	QString mSearchText;
	QSharedPointer<ConferenceInfoList> mList;
	int mCurrentDateIndex = -1;
	DECLARE_ABSTRACT_OBJECT
};

#endif // CONFERENCE_INFO_PROXY_H_
