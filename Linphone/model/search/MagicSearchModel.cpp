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

#include "MagicSearchModel.hpp"

#include <QDebug>

#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include <functional>

DEFINE_ABSTRACT_OBJECT(MagicSearchModel)

MagicSearchModel::MagicSearchModel(const std::shared_ptr<linphone::MagicSearch> &data, QObject *parent)
    : ::Listener<linphone::MagicSearch, linphone::MagicSearchListener>(data, parent) {
	mustBeInLinphoneThread(getClassName());
}

MagicSearchModel::~MagicSearchModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void MagicSearchModel::search(QString filter,
                              int sourceFlags,
                              LinphoneEnums::MagicSearchAggregation aggregation,
                              int maxResults) {
	mLastSearch = filter;
	setMaxResults(maxResults);
	if (filter == "" || filter == "*") {
		if (((sourceFlags & (int)LinphoneEnums::MagicSearchSource::LdapServers) > 0) &&
		    !SettingsModel::getInstance()->getSyncLdapContacts())
			sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::LdapServers;
		// For complete search, we search only on local contacts.
		sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::CallLogs;
		sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::ChatRooms;
		sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::ConferencesInfo;
	}
	qInfo() << log().arg("Searching ") << filter << " from " << sourceFlags << " with limit " << maxResults;
	mMonitor->getContactsListAsync(filter != "*" ? Utils::appStringToCoreString(filter) : "", "", sourceFlags,
	                               LinphoneEnums::toLinphone(aggregation));
}

int MagicSearchModel::getMaxResults() const {
	if (!mMonitor->getLimitedSearch()) return -1;
	else return mMonitor->getSearchLimit();
}

void MagicSearchModel::setMaxResults(int maxResults) {
	if (maxResults <= 0 && mMonitor->getLimitedSearch() ||
	    maxResults > 0 && (!mMonitor->getLimitedSearch() || maxResults != mMonitor->getSearchLimit())) {
		mMonitor->setLimitedSearch(maxResults > 0);
		if (maxResults > 0) mMonitor->setSearchLimit(maxResults);
		emit maxResultsChanged(maxResults);
	}
}

void MagicSearchModel::onSearchResultsReceived(const std::shared_ptr<linphone::MagicSearch> &magicSearch) {
	qDebug() << log().arg("SDK send callback: onSearchResultsReceived");
	auto results = magicSearch->getLastSearch();
	auto appFriends = ToolModel::getAppFriendList();
	std::list<std::shared_ptr<linphone::SearchResult>> finalResults;
	for (auto it : results) {
		bool isLdap = (it->getSourceFlags() & (int)LinphoneEnums::MagicSearchSource::LdapServers) != 0;
		bool toAdd = true;
		if (isLdap && it->getFriend()) {
			updateLdapFriendListWithFriend(it->getFriend());
			if (appFriends->findFriendByAddress(it->getFriend()->getAddress())) { // Already exist in app list
				toAdd = false;
			}
		}
		if (toAdd &&
		    std::find_if(finalResults.begin(), finalResults.end(), [it](std::shared_ptr<linphone::SearchResult> r) {
			    return r->getAddress()->weakEqual(it->getAddress());
		    }) == finalResults.end())
			finalResults.push_back(it);
	}
	emit searchResultsReceived(finalResults);
}

void MagicSearchModel::onLdapHaveMoreResults(const std::shared_ptr<linphone::MagicSearch> &magicSearch,
                                             const std::shared_ptr<linphone::Ldap> &ldap) {
	// emit ldapHaveMoreResults(ldap);
}

// Store LDAP friends in separate list so they can still be retrieved by core->findFriend() for display names,
// but can be amended only by LDAP received friends.
// Done in this place so the application can benefit from user initiated searches for faster ldap name retrieval
// upon incoming call / chat message.

void MagicSearchModel::updateLdapFriendListWithFriend(const std::shared_ptr<linphone::Friend> &linphoneFriend) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	auto ldapFriendList = ToolModel::getLdapFriendList();
	for (auto address : linphoneFriend->getAddresses()) {
		auto existingFriend = ldapFriendList->findFriendByAddress(address);
		if (existingFriend) {
			ldapFriendList->removeFriend(existingFriend);
			ldapFriendList->addFriend(linphoneFriend);
			return;
		}
	}
	for (auto number : linphoneFriend->getPhoneNumbers()) {
		auto existingFriend = ldapFriendList->findFriendByPhoneNumber(number);
		if (existingFriend) {
			ldapFriendList->removeFriend(existingFriend);
			ldapFriendList->addFriend(linphoneFriend);
			return;
		}
	}
	ldapFriendList->addFriend(linphoneFriend);
	emit CoreModel::getInstance()->friendCreated(linphoneFriend);
}
