/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"

#include "ConferenceInfoListModel.hpp"
#include "ConferenceInfoMapModel.hpp"
#include "ConferenceInfoProxyModel.hpp"

// =============================================================================

using namespace std;

ConferenceInfoProxyModel::ConferenceInfoProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	mEntryTypeFilter = ConferenceType::Scheduled;
	setSourceModel(new ConferenceInfoMapModel());
	sort(0, Qt::DescendingOrder);
}

ConferenceInfoProxyModel::ConferenceInfoProxyModel (ConferenceInfoListModel * list, QObject *parent) : QSortFilterProxyModel(parent) {
	mEntryTypeFilter = ConferenceType::Scheduled;
	setSourceModel(list);
	sort(0, Qt::DescendingOrder);
}

int ConferenceInfoProxyModel::getConferenceInfoFilter () {
	return mEntryTypeFilter;
}

void ConferenceInfoProxyModel::setConferenceInfoFilter (int filterMode) {
	if (getConferenceInfoFilter() != filterMode) {
		mEntryTypeFilter = filterMode;
		invalidate();
		emit conferenceInfoFilterChanged(filterMode);
	}
}

bool ConferenceInfoProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	return true;
/*
	bool show = false;
	QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
	const ConferenceInfoListModel* ics = sourceModel()->data(index).value<ConferenceInfoListModel*>();
		
		
	if( mEntryTypeFilter == ConferenceType::Ended && ics->eventModel.value<ChatCallModel*>() != nullptr)
			show = true;
		else if( mEntryTypeFilter == ChatRoomModel::EntryType::MessageEntry && eventModel.value<ChatMessageModel*>() != nullptr)
			show = true;
		else if( mEntryTypeFilter == ChatRoomModel::EntryType::NoticeEntry && eventModel.value<ChatNoticeModel*>() != nullptr)
			show = true;
	}
	if( show && mFilterText != ""){
		QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
		auto eventModel = sourceModel()->data(index);
		ChatMessageModel * chatModel = eventModel.value<ChatMessageModel*>();
		if( chatModel){
			QRegularExpression search(QRegularExpression::escape(mFilterText), QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption);
			show = chatModel->mContent.contains(search);
		}
	}
	return show;*/
}

bool ConferenceInfoProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const ConferenceInfoListModel* deviceA = sourceModel()->data(left).value<ConferenceInfoListModel*>();
  const ConferenceInfoListModel* deviceB = sourceModel()->data(right).value<ConferenceInfoListModel*>();

  return deviceA->getAt(0)->getDateTime() < deviceB->getAt(0)->getDateTime();
}

QVariant ConferenceInfoProxyModel::getAt(int row){
	QModelIndex sourceIndex = mapToSource(this->index(row, 0));
	return sourceModel()->data(sourceIndex);
}

void ConferenceInfoProxyModel::add(QSharedPointer<ConferenceInfoModel> conferenceInfoModel){
	qobject_cast<ConferenceInfoListModel*>(sourceModel())->add(conferenceInfoModel);
}