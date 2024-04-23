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
}

MagicSearchModel::~MagicSearchModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void MagicSearchModel::search(QString filter) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mLastSearch = filter;
	mMonitor->getContactsListAsync(filter != "*" ? Utils::appStringToCoreString(filter) : "", "", mSourceFlags,
	                               LinphoneEnums::toLinphone(mAggregationFlag));
}

void MagicSearchModel::setSourceFlags(int flags) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mSourceFlags != flags) {
		mSourceFlags = flags;
		emit sourceFlagsChanged(mSourceFlags);
	}
}

void MagicSearchModel::setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mAggregationFlag != flag) {
		mAggregationFlag = flag;
		emit aggregationFlagChanged(mAggregationFlag);
	}
}

void MagicSearchModel::onSearchResultsReceived(const std::shared_ptr<linphone::MagicSearch> &magicSearch) {
	emit searchResultsReceived(magicSearch->getLastSearch());
}

void MagicSearchModel::onLdapHaveMoreResults(const std::shared_ptr<linphone::MagicSearch> &magicSearch,
                                             const std::shared_ptr<linphone::Ldap> &ldap) {
	// emit ldapHaveMoreResults(ldap);
}
