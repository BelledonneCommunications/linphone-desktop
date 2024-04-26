﻿/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef CONFERENCE_INFO_LIST_H_
#define CONFERENCE_INFO_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <linphone++/linphone.hh>

class CoreModel;
class ConferenceInfoCore;

class ConferenceInfoList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	// Create a ConferenceInfoList and make connections to List.
	static QSharedPointer<ConferenceInfoList> create();
	ConferenceInfoList(QObject *parent = Q_NULLPTR);
	~ConferenceInfoList();

	void setSelf(QSharedPointer<ConferenceInfoList> me);

	bool haveCurrentDate() const;
	void setHaveCurrentDate(bool have);
	void updateHaveCurrentDate();

	int getCurrentDateIndex() const;
	void setCurrentDateIndex(int index);

	int findConfInfoIndexByUri(const QString &uri);

	QSharedPointer<ConferenceInfoCore> build(const std::shared_ptr<linphone::ConferenceInfo> &conferenceInfo) const;

	QHash<int, QByteArray> roleNames() const override;

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
	static int sort(QList<QSharedPointer<ConferenceInfoCore>> &listToSort); // return the index of null item.

signals:
	void lUpdate();
	void addCurrentDateChanged();
	void haveCurrentDateChanged();
	void currentDateIndexChanged();

private:
	QSharedPointer<SafeConnection<ConferenceInfoList, CoreModel>> mCoreModelConnection;
	std::shared_ptr<CoreModel> mCoreModel;
	QSharedPointer<ConferenceInfoCore> mLastConfInfoInserted;
	bool mHaveCurrentDate = false;
	int mCurrentDateIndex = -1;
	DECLARE_ABSTRACT_OBJECT
};
#endif // CONFERENCE_INFO_LIST_H_
