/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "ConferenceInfoProxy.hpp"
#include "ConferenceInfoCore.hpp"
#include "ConferenceInfoGui.hpp"
#include "ConferenceInfoList.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceInfoProxy)

ConferenceInfoProxy::ConferenceInfoProxy(QObject *parent) : SortFilterProxy(parent) {
	mList = ConferenceInfoList::create();
	setSourceModel(mList.get());
	connect(this, &ConferenceInfoProxy::searchTextChanged, [this] { invalidate(); });
	connect(this, &ConferenceInfoProxy::lUpdate, mList.get(), &ConferenceInfoList::lUpdate);
}

ConferenceInfoProxy::~ConferenceInfoProxy() {
	setSourceModel(nullptr);
}

QString ConferenceInfoProxy::getSearchText() const {
	return mSearchText;
}

void ConferenceInfoProxy::setSearchText(const QString &search) {
	mSearchText = search;
	emit searchTextChanged();
}

bool ConferenceInfoProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	const ConferenceInfoGui *gui =
	    sourceModel()->data(sourceModel()->index(sourceRow, 0, sourceParent)).value<ConferenceInfoGui *>();
	if (gui) {
		auto ciCore = gui->getCore();
		assert(ciCore);
		if (!ciCore->getSubject().contains(mSearchText)) return false;
		if (ciCore->getDuration() == 0) return false;
		QDateTime currentDateTime = QDateTime::currentDateTimeUtc();
		if (mFilterType == 0) {
			// auto res = ciCore->getEndDateTimeUtc() < currentDateTime;
			return true;
		} else if (mFilterType == 1) {
			auto res = ciCore->getEndDateTimeUtc() >= currentDateTime;
			return res;
			// } else if (mFilterType == 2) {
			// return !Utils::isMe(ciCore->getOrganizer());
		} else return mFilterType == -1;
	}
	return false;
}

bool ConferenceInfoProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = getItemAt<ConferenceInfoList, ConferenceInfoGui>(left.row())->getCore();
	auto r = getItemAt<ConferenceInfoList, ConferenceInfoGui>(right.row())->getCore();

	return l->getDateTimeUtc() < r->getDateTimeUtc();
}