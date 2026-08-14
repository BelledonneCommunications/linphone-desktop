/*
 * Copyright (c) 2010-2026 Belledonne Communications SARL.
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

#include "RecordingProxy.hpp"
#include "RecordingCore.hpp"
#include "core/App.hpp"

#include <QRegularExpression>

DEFINE_ABSTRACT_OBJECT(RecordingProxy)

RecordingProxy::RecordingProxy(QObject *parent) : LimitProxy(parent) {
	mRecordingList = RecordingList::create();
	connect(mRecordingList.get(), &RecordingList::listAboutToBeReset, this, &RecordingProxy::listAboutToBeReset);
	connect(mRecordingList.get(), &RecordingList::loadingChanged, this, [this](bool loading) {
		if (mLoading == loading) return;
		mLoading = loading;
		emit loadingChanged();
	});
	setSourceModels(new SortFilterList(mRecordingList.get(), Qt::DescendingOrder));
}

RecordingProxy::~RecordingProxy() {
}

bool RecordingProxy::getLoading() const {
	return mLoading;
}

void RecordingProxy::reload() {
	emit mRecordingList->lUpdate();
}

void RecordingProxy::removeAll() {
	mRecordingList->removeAll();
}

//------------------------------------------------------------------------------------------

bool RecordingProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	if (mFilterText.isEmpty() || mFilterText == "*") return true;
	QRegularExpression search(QRegularExpression::escape(mFilterText),
	                          QRegularExpression::CaseInsensitiveOption |
	                              QRegularExpression::UseUnicodePropertiesOption);
	auto recording = getItemAtSource<RecordingList, RecordingCore>(sourceRow);
	return recording && (recording->mDisplayName.contains(search) || recording->mFileName.contains(search));
}

bool RecordingProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto left = getItemAtSource<RecordingList, RecordingCore>(sourceLeft.row());
	auto right = getItemAtSource<RecordingList, RecordingCore>(sourceRight.row());
	if (!left || !right) return false;
	if (left->mDateTime == right->mDateTime) return left->mFileName < right->mFileName;
	return left->mDateTime < right->mDateTime;
}
