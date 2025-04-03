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
		if (((sourceFlags & (int)LinphoneEnums::MagicSearchSource::RemoteCardDAV) > 0))
			sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::RemoteCardDAV;
		// For complete search, we search only on local contacts.
		// sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::CallLogs;
		// sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::ChatRooms;
		// sourceFlags &= ~(int)LinphoneEnums::MagicSearchSource::ConferencesInfo;
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

bool isContactTemporary(std::shared_ptr<linphone::Friend> f, bool allowNullFriendList = false) {
	auto friendList = f ? f->getFriendList() : nullptr;
	if (friendList == nullptr && !allowNullFriendList) return true;
	return friendList && (friendList == ToolModel::getLdapFriendList());
}

void MagicSearchModel::onSearchResultsReceived(const std::shared_ptr<linphone::MagicSearch> &magicSearch) {
	auto results = magicSearch->getLastSearch();
	qInfo() << log().arg("SDK send callback: onSearchResultsReceived : %1 results.").arg(results.size());
	auto appFriends = ToolModel::getAppFriendList();
	auto ldapFriends = ToolModel::getLdapFriendList();
	std::list<std::shared_ptr<linphone::SearchResult>> finalResults;
	for (auto result : results) {
		auto f = result->getFriend();
		auto sourceFlags = result->getSourceFlags();
		qInfo() << "result" << result->getAddress()->asStringUriOnly();
		qInfo() << "result has flag friend" << result->hasSourceFlag(linphone::MagicSearch::Source::Friends) << ((sourceFlags & (int)linphone::MagicSearch::Source::Friends) != 0);
		qInfo() << "result has flag ldap" << result->hasSourceFlag(linphone::MagicSearch::Source::LdapServers) << ((sourceFlags & (int)linphone::MagicSearch::Source::LdapServers) != 0);
		qInfo() << "result has flag carddav" << result->hasSourceFlag(linphone::MagicSearch::Source::RemoteCardDAV) << ((sourceFlags & (int)linphone::MagicSearch::Source::RemoteCardDAV) != 0);
		bool isFromRemoteDirectory = ((sourceFlags & (int)linphone::MagicSearch::Source::LdapServers) != 0) ||
									 ((sourceFlags & (int)linphone::MagicSearch::Source::RemoteCardDAV) != 0);
		if (!isFromRemoteDirectory && isContactTemporary(f, true)) {
			qInfo() << "Do not show friend " << f->getName() << "which is not remote and is in a temporary friend list";
			continue;
		}
		finalResults.push_back(result);
	}
	emit searchResultsReceived(finalResults);
	for (auto result : results) {
		auto f = result->getFriend();
		auto fList = f ? f->getFriendList() : nullptr;

		//		qDebug() << log().arg("") << (f ? f->getName().c_str() : "NoFriend") << ", "
		//		         << (result->getAddress() ? result->getAddress()->asString().c_str() : "NoAddr") << " / "
		//		         << (fList ? fList->getDisplayName().c_str() : "NoList") << result->getSourceFlags() << " /
		//"
		//		         << (f ? f.get() : nullptr);
		bool isLdap = (result->getSourceFlags() & (int)linphone::MagicSearch::Source::LdapServers) != 0;
		qInfo() << "result is ldap" << isLdap;
		// Do not add it into ldap_friends if it already exists in app_friends.
		if (isLdap && f &&
		    (!fList || fList->getDisplayName() != "app_friends")) { // Double check because of SDK merging that lead to
			// use a ldap result as of app_friends/ldap_friends.
			updateFriendListWithFriend(f, ldapFriends);
		}
	}
}

void MagicSearchModel::onMoreResultsAvailable(const std::shared_ptr<linphone::MagicSearch> &magicSearch,
                                              linphone::MagicSearch::Source source) {
}

// Store LDAP friends in separate list so they can still be retrieved by core->findFriend() for display names,
// but can be amended only by LDAP received friends.
// Done in this place so the application can benefit from user initiated searches for faster ldap name retrieval
// upon incoming call / chat message.

void MagicSearchModel::updateFriendListWithFriend(const std::shared_ptr<linphone::Friend> &linphoneFriend,
                                                  std::shared_ptr<linphone::FriendList> friendList) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();

	if (ToolModel::friendIsInFriendList(friendList, linphoneFriend))
		return; // Already exist. We don't need to manipulate list.
	for (auto address : linphoneFriend->getAddresses()) {
		auto existingFriend = friendList->findFriendByAddress(address);
		if (existingFriend) {
			friendList->removeFriend(existingFriend);
			friendList->addFriend(linphoneFriend);
			return;
		}
	}
	for (auto number : linphoneFriend->getPhoneNumbers()) {
		auto existingFriend = friendList->findFriendByPhoneNumber(number);
		if (existingFriend) {
			friendList->removeFriend(existingFriend);
			friendList->addFriend(linphoneFriend);
			return;
		}
	}
	qInfo() << log().arg("Adding Friend:") << linphoneFriend.get();
	friendList->addFriend(linphoneFriend);
	emit CoreModel::getInstance()->friendCreated(linphoneFriend);
}
