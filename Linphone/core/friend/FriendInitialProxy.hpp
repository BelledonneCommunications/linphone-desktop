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

#ifndef FRIEND_INITIAL_PROXY_H_
#define FRIEND_INITIAL_PROXY_H_

#include "../proxy/SortFilterProxy.hpp"
#include "core/search/MagicSearchList.hpp"
#include "core/search/MagicSearchProxy.hpp"
#include "tool/AbstractObject.hpp"

/**
 * A proxy to filter the friends list with the first letter of the names
 **/
// =============================================================================

class FriendInitialProxy : public SortFilterProxy, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString filterText READ getFilterText WRITE setFilterText NOTIFY filterTextChanged)

public:
	FriendInitialProxy(QObject *parent = Q_NULLPTR);
	~FriendInitialProxy();

	QString getFilterText() const;
	void setFilterText(const QString &filter);

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void filterTextChanged();
	void sourceModelChanged();

protected:
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

	QString mFilterText;
	DECLARE_ABSTRACT_OBJECT
};

#endif
