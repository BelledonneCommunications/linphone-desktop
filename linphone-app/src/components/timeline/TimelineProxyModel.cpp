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

#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "TimelineProxyModel.hpp"
#include "TimelineListModel.hpp"
#include "TimelineModel.hpp"

#include <QDebug>


// =============================================================================

// -----------------------------------------------------------------------------

TimelineProxyModel::TimelineProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	CoreManager *coreManager = CoreManager::getInstance();
	AccountSettingsModel *accountSettingsModel = coreManager->getAccountSettingsModel();
	TimelineListModel * model = CoreManager::getInstance()->getTimelineListModel();
	
	connect(model, SIGNAL(selectedCountChanged(int)), this, SIGNAL(selectedCountChanged(int)));
	connect(model, &TimelineListModel::updated, this, &TimelineProxyModel::invalidate);
	
	setSourceModel(model);
	
	QObject::connect(accountSettingsModel, &AccountSettingsModel::defaultProxyChanged, this, [this]() {
		dynamic_cast<TimelineListModel*>(sourceModel())->update();
		invalidate();
		//updateCurrentSelection();
	});
	QObject::connect(coreManager->getSipAddressesModel(), &SipAddressesModel::sipAddressReset, this, [this]() {
		dynamic_cast<TimelineListModel*>(sourceModel())->reset();
		invalidate();// Invalidate and reload GUI if the model has been reset
		//updateCurrentSelection();
	});
	sort(0);
}

// -----------------------------------------------------------------------------
/*
void TimelineProxyModel::setCurrentChatRoomModel(ChatRoomModel *data){
	mCurrentChatRoomModel = CoreManager::getInstance()->getChatRoomModel(data);
	emit currentChatRoomModelChanged(mCurrentChatRoomModel);
	if(mCurrentChatRoomModel)
		emit currentTimelineChanged(dynamic_cast<TimelineListModel*>(sourceModel())->getTimeline(mCurrentChatRoomModel->getChatRoom(), false).get());
	else
		emit currentTimelineChanged(nullptr);
}

ChatRoomModel *TimelineProxyModel::getCurrentChatRoomModel()const{
	return mCurrentChatRoomModel.get();
}

void TimelineProxyModel::updateCurrentSelection(){
	auto currentAddress = CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddress();
	if(mCurrentChatRoomModel && !mCurrentChatRoomModel->getChatRoom()->getMe()->getAddress()->weakEqual(currentAddress) ){
		setCurrentChatRoomModel(nullptr);
	}
}
*/
void TimelineProxyModel::unselectAll(){
	dynamic_cast<TimelineListModel*>(sourceModel())->selectAll(false);
}

void TimelineProxyModel::setFilterFlags(const int& filterFlags){
	if( mFilterFlags != filterFlags){
		mFilterFlags = filterFlags;
		invalidate();
		emit filterFlagsChanged();
	}
}
void TimelineProxyModel::setFilterText(const QString& text){
	if( mFilterText != text){
		mFilterText = text;
		invalidate();
		emit filterTextChanged();
	}
}
// -----------------------------------------------------------------------------

bool TimelineProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	auto timeline = sourceModel()->data(index).value<TimelineModel*>();
	bool show = (mFilterFlags==0);// Show all at 0 (no hide all)
	auto currentAddress = Utils::interpretUrl(CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddressAsStringUriOnly());
	
	if( !show && ( (mFilterFlags & TimelineFilter::SimpleChatRoom) == TimelineFilter::SimpleChatRoom))
		show = !timeline->getChatRoomModel()->isGroupEnabled() && !timeline->getChatRoomModel()->haveEncryption();
	if( !show && ( (mFilterFlags & TimelineFilter::SecureChatRoom) == TimelineFilter::SecureChatRoom))
		show = !timeline->getChatRoomModel()->isGroupEnabled() && timeline->getChatRoomModel()->haveEncryption();
	if( !show && ( (mFilterFlags & TimelineFilter::GroupChatRoom) == TimelineFilter::GroupChatRoom))
		show = timeline->getChatRoomModel()->isGroupEnabled() && !timeline->getChatRoomModel()->haveEncryption();
	if( !show && ( (mFilterFlags & TimelineFilter::SecureGroupChatRoom) == TimelineFilter::SecureGroupChatRoom))
		show = timeline->getChatRoomModel()->isGroupEnabled() && timeline->getChatRoomModel()->haveEncryption();
	if( !show && ( (mFilterFlags & TimelineFilter::EphemeralChatRoom) == TimelineFilter::EphemeralChatRoom))
		show = timeline->getChatRoomModel()->isEphemeralEnabled();
	if(show && mFilterText != ""){
		QRegularExpression search(mFilterText, QRegularExpression::CaseInsensitiveOption);
		show = timeline->getChatRoomModel()->getSubject().contains(search) 
			|| timeline->getChatRoomModel()->getUsername().contains(search);
			//|| timeline->getChatRoomModel()->getFullPeerAddress().contains(search); not enough significant?
	}
	if(show)
		show = timeline->getChatRoomModel()->isCurrentProxy();
	return show;
}

bool TimelineProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const TimelineModel* a = sourceModel()->data(left).value<TimelineModel*>();
	const TimelineModel* b = sourceModel()->data(right).value<TimelineModel*>();
	
	return a->getChatRoomModel()->mLastUpdateTime >= b->getChatRoomModel()->mLastUpdateTime ;
}
