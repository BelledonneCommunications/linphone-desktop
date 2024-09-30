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

#ifndef MAGIC_SEARCH_PROXY_H_
#define MAGIC_SEARCH_PROXY_H_

#include "../proxy/SortFilterProxy.hpp"
#include "core/search/MagicSearchList.hpp"
#include "tool/LinphoneEnums.hpp"

// =============================================================================

class MagicSearchProxy : public SortFilterProxy {
	Q_OBJECT

	Q_PROPERTY(QString searchText READ getSearchText WRITE setSearchText NOTIFY searchTextChanged)
	Q_PROPERTY(int sourceFlags READ getSourceFlags WRITE setSourceFlags NOTIFY sourceFlagsChanged)
	Q_PROPERTY(LinphoneEnums::MagicSearchAggregation aggregationFlag READ getAggregationFlag WRITE setAggregationFlag
	               NOTIFY aggregationFlagChanged)
	Q_PROPERTY(bool showFavoritesOnly READ showFavoritesOnly WRITE setShowFavoritesOnly NOTIFY showFavoriteOnlyChanged)
	Q_PROPERTY(MagicSearchProxy *parentProxy WRITE setParentProxy NOTIFY parentProxyChanged)

public:
	MagicSearchProxy(QObject *parent = Q_NULLPTR);
	~MagicSearchProxy();

	QString getSearchText() const;
	void setSearchText(const QString &search);

	int getSourceFlags() const;
	void setSourceFlags(int flags);

	LinphoneEnums::MagicSearchAggregation getAggregationFlag() const;
	void setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag);

	bool showFavoritesOnly() const;
	void setShowFavoritesOnly(bool show);

	void setList(QSharedPointer<MagicSearchList> list);
	Q_INVOKABLE void setParentProxy(MagicSearchProxy *proxy);

	// Q_INVOKABLE forceUpdate();
	Q_INVOKABLE int findFriendIndexByAddress(const QString &address);

signals:
	void searchTextChanged();
	void sourceFlagsChanged(int sourceFlags);
	void aggregationFlagChanged(LinphoneEnums::MagicSearchAggregation aggregationFlag);
	void forceUpdate();
	void friendCreated(int index);
	void showFavoriteOnlyChanged();
	void parentProxyChanged();
	void initialized();

protected:
	QString mSearchText;
	int mSourceFlags;
	bool mShowFavoritesOnly = false;
	LinphoneEnums::MagicSearchAggregation mAggregationFlag;
	QSharedPointer<MagicSearchList> mList;
	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	virtual bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;
};

#endif
