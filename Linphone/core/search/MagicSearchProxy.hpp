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

#include "../proxy/LimitProxy.hpp"
#include "core/search/MagicSearchList.hpp"
#include "tool/LinphoneEnums.hpp"

// =============================================================================

class MagicSearchProxy : public LimitProxy {
	Q_OBJECT
	Q_CLASSINFO("RegisterEnumClassesUnscoped", "false") // Avoid name clashes
	Q_PROPERTY(QString searchText READ getSearchText WRITE setSearchText NOTIFY searchTextChanged)
	Q_PROPERTY(int sourceFlags READ getSourceFlags WRITE setSourceFlags NOTIFY sourceFlagsChanged)

	Q_PROPERTY(int maxResults READ getMaxResults WRITE setMaxResults NOTIFY maxResultsChanged)
	Q_PROPERTY(LinphoneEnums::MagicSearchAggregation aggregationFlag READ getAggregationFlag WRITE setAggregationFlag
	               NOTIFY aggregationFlagChanged)

	Q_PROPERTY(MagicSearchProxy *parentProxy READ getParentProxy WRITE setParentProxy NOTIFY parentProxyChanged)
	Q_PROPERTY(MagicSearchProxy *hideListProxy READ getHideListProxy WRITE setHideListProxy NOTIFY hideListProxyChanged)

public:
	enum class FilteringTypes { None = 0, Favorites = 1, App = 2, Ldap = 4, CardDAV = 8, Other = 16 };
	Q_ENUM(FilteringTypes)

	DECLARE_SORTFILTER_CLASS(MagicSearchProxy *mHideListProxy = nullptr;)
	MagicSearchProxy(QObject *parent = Q_NULLPTR);
	~MagicSearchProxy();

	QString getSearchText() const;
	void setSearchText(const QString &search);

	int getSourceFlags() const;
	void setSourceFlags(int flags);

	LinphoneEnums::MagicSearchAggregation getAggregationFlag() const;
	void setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag);

	int getMaxResults() const;
	void setMaxResults(int maxResults);

	MagicSearchProxy *getParentProxy() const;
	void setList(QSharedPointer<MagicSearchList> list);
	Q_INVOKABLE void setParentProxy(MagicSearchProxy *proxy);

	MagicSearchProxy *getHideListProxy() const;
	void setHideListProxy(MagicSearchProxy *proxy);

	// Q_INVOKABLE forceUpdate();
	Q_INVOKABLE int findFriendIndexByAddress(const QString &address);
	Q_INVOKABLE FriendGui *findFriendByAddress(const QString &address);
	Q_INVOKABLE int loadUntil(const QString &address);

signals:
	void searchTextChanged();
	void sourceFlagsChanged(int sourceFlags);
	void aggregationFlagChanged(LinphoneEnums::MagicSearchAggregation aggregationFlag);
	void maxResultsChanged(int maxResults);
	void forceUpdate();
	void localFriendCreated(int index);
	void parentProxyChanged();
	void hideListProxyChanged();
	void initialized();
	void resultsProcessed();

protected:
	MagicSearchProxy *mParentProxy = nullptr;
	QString mSearchText;
	QSharedPointer<MagicSearchList> mList;
};

#endif
