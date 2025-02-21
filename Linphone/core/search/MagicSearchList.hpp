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

#ifndef MAGIC_SEARCH_LIST_H_
#define MAGIC_SEARCH_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "core/friend/FriendGui.hpp"
#include "model/search/MagicSearchModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QLocale>

class FriendCore;
class CoreModel;
// =============================================================================

// Return FriendGui list to Ui
class MagicSearchList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	static QSharedPointer<MagicSearchList> create();
	MagicSearchList(QObject *parent = Q_NULLPTR);
	~MagicSearchList();

	void setSelf(QSharedPointer<MagicSearchList> me);
	void connectContact(FriendCore* data);
	void setSearch(const QString &search);
	void setResults(const QList<QSharedPointer<FriendCore>> &contacts);
	void add(QSharedPointer<FriendCore> contact);

	int getSourceFlags() const;
	void setSourceFlags(int flags);

	LinphoneEnums::MagicSearchAggregation getAggregationFlag() const;
	void setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag);

	int getMaxResults() const;
	void setMaxResults(int maxResults);

	virtual QHash<int, QByteArray> roleNames() const override;
	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

	int findFriendIndexByAddress(const QString &address);
	QSharedPointer<FriendCore> findFriendByAddress(const QString &address);

signals:
	void
	lSearch(QString filter, int sourceFlags, LinphoneEnums::MagicSearchAggregation aggregationFlag, int maxResults);

	void sourceFlagsChanged(int sourceFlags);
	void aggregationFlagChanged(LinphoneEnums::MagicSearchAggregation flag);
	void maxResultsChanged(int maxResults);

	void friendCreated(int index, FriendGui *data);
	void friendStarredChanged();

	void resultsProcessed();

	void initialized();

private:
	int mSourceFlags;
	LinphoneEnums::MagicSearchAggregation mAggregationFlag;
	QString mSearchFilter;
	int mMaxResults = -1;

	std::shared_ptr<MagicSearchModel> mMagicSearch;
	QSharedPointer<SafeConnection<MagicSearchList, MagicSearchModel>> mModelConnection;
	QSharedPointer<SafeConnection<MagicSearchList, CoreModel>> mCoreModelConnection;

	DECLARE_ABSTRACT_OBJECT
};

#endif
