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

#ifndef MAGIC_SEARCH_MODEL_H_
#define MAGIC_SEARCH_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class MagicSearchModel : public ::Listener<linphone::MagicSearch, linphone::MagicSearchListener>,
                         public linphone::MagicSearchListener,
                         public AbstractObject {
	Q_OBJECT
public:
	MagicSearchModel(const std::shared_ptr<linphone::MagicSearch> &data, QObject *parent = nullptr);
	~MagicSearchModel();

	void search(QString filter, int sourceFlags, LinphoneEnums::MagicSearchAggregation aggregation, int maxResults);

	int getMaxResults() const;
	void setMaxResults(int maxResults);
	QString mLastSearch;

signals:
	void maxResultsChanged(int maxResults);

private:
	DECLARE_ABSTRACT_OBJECT

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onSearchResultsReceived(const std::shared_ptr<linphone::MagicSearch> &magicSearch) override;
	virtual void onMoreResultsAvailable(const std::shared_ptr<linphone::MagicSearch> &magicSearch,
	                                    linphone::MagicSearch::Source source) override;
	void updateFriendListWithFriend(const std::shared_ptr<linphone::Friend> &linphoneFriend,
	                                std::shared_ptr<linphone::FriendList> friendList);

signals:
	void searchResultsReceived(const std::list<std::shared_ptr<linphone::SearchResult>> &results);
};

#endif
