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
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(MagicSearchModel)

MagicSearchModel::MagicSearchModel(const std::shared_ptr<linphone::MagicSearch> &data, QObject *parent)
    : ::Listener<linphone::MagicSearch, linphone::MagicSearchListener>(data, parent) {
	mustBeInLinphoneThread(getClassName());
	// Removed is managed by FriendCore that allow to remove result automatically.
	// No need to restart a new search in this case
	connect(CoreModel::getInstance().get(), &CoreModel::friendAdded, this, [this]() {
		if (!mLastSearch.isEmpty()) search(mLastSearch);
	});
}

MagicSearchModel::~MagicSearchModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void MagicSearchModel::search(QString filter) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mLastSearch = filter;
	mMonitor->getContactsListAsync(filter != "*" ? Utils::appStringToCoreString(filter) : "", "", mSourceFlags,
	                               mAggregationFlag);
}

void MagicSearchModel::onSearchResultsReceived(const std::shared_ptr<linphone::MagicSearch> &magicSearch) {
	emit searchResultsReceived(magicSearch->getLastSearch());
}

void MagicSearchModel::onLdapHaveMoreResults(const std::shared_ptr<linphone::MagicSearch> &magicSearch,
                                             const std::shared_ptr<linphone::Ldap> &ldap) {
	// emit ldapHaveMoreResults(ldap);
}
