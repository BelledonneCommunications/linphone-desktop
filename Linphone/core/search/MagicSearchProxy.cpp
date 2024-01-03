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

#include "MagicSearchProxy.hpp"
#include "MagicSearchList.hpp"

MagicSearchProxy::MagicSearchProxy(QObject *parent) : SortFilterProxy(parent) {
	mList = MagicSearchList::create();
	connect(mList.get(), &MagicSearchList::sourceFlagsChanged, this, &MagicSearchProxy::sourceFlagsChanged);
	connect(mList.get(), &MagicSearchList::aggregationFlagChanged, this, &MagicSearchProxy::aggregationFlagChanged);
	setSourceModel(mList.get());
	sort(0);
}

MagicSearchProxy::~MagicSearchProxy() {
}

QString MagicSearchProxy::getSearchText() const {
	return mSearchText;
}

void MagicSearchProxy::setSearchText(const QString &search) {
	mSearchText = search;
	qobject_cast<MagicSearchList *>(sourceModel())->setSearch(mSearchText);
}

int MagicSearchProxy::getSourceFlags() const {
	return qobject_cast<MagicSearchList *>(sourceModel())->getSourceFlags();
}

void MagicSearchProxy::setSourceFlags(int flags) {
	qobject_cast<MagicSearchList *>(sourceModel())->lSetSourceFlags(flags);
}

LinphoneEnums::MagicSearchAggregation MagicSearchProxy::getAggregationFlag() const {
	return qobject_cast<MagicSearchList *>(sourceModel())->getAggregationFlag();
}

void MagicSearchProxy::setAggregationFlag(LinphoneEnums::MagicSearchAggregation flag) {
	qobject_cast<MagicSearchList *>(sourceModel())->lSetAggregationFlag(flag);
}