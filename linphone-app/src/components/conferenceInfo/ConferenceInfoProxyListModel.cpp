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

#include "ConferenceInfoProxyListModel.hpp"

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"

#include "ConferenceInfoListModel.hpp"
#include "ConferenceInfoMapModel.hpp"


// =============================================================================

using namespace std;

//---------------------------------------------------------------------------------------------

ConferenceInfoProxyListModel::ConferenceInfoProxyListModel (QObject *parent) : SortFilterAbstractProxyModel<ConferenceInfoListModel>(new ConferenceInfoListModel(parent), parent) {
	//setFilterType(0);
	//connect(this, &ConferenceInfoProxyListModel::filterTypeChanged, qobject_cast<ConferenceInfoListModel*>(sourceModel()), &ConferenceInfoListModel::filterTypeChanged);
}

bool ConferenceInfoProxyListModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	auto listModel = qobject_cast<ConferenceInfoListModel*>(sourceModel());
	if(listModel){
		QModelIndex index = listModel->index(sourceRow, 0, QModelIndex());
		const ConferenceInfoModel* ics = sourceModel()->data(index).value<ConferenceInfoModel*>();
		if(ics){
			QDateTime currentDateTime = QDateTime::currentDateTime();
			if( mFilterType == 0){
				return ics->getEndDateTime() < currentDateTime;
			}else if( mFilterType == 1){
				return ics->getDateTime() >= currentDateTime;
			}
		}
	}
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

bool ConferenceInfoProxyListModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	return true;
/*
  const ConferenceInfoListModel* deviceA = sourceModel()->data(left).value<ConferenceInfoListModel*>();
  const ConferenceInfoListModel* deviceB = sourceModel()->data(right).value<ConferenceInfoListModel*>();

  return deviceA->getAt<ConferenceInfoModel>(0)->getDateTime() < deviceB->getAt<ConferenceInfoModel>(0)->getDateTime();
  */
}
/*
QVariant ConferenceInfoProxyModel::getAt(int row){
	QModelIndex sourceIndex = mapToSource(this->index(row, 0));
	return sourceModel()->data(sourceIndex);
}

void ConferenceInfoProxyModel::add(QSharedPointer<ConferenceInfoModel> conferenceInfoModel){
	qobject_cast<ConferenceInfoListModel*>(sourceModel())->add(conferenceInfoModel);
}*/