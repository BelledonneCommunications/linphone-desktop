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
#include "components/participant/ParticipantListModel.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
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
	connect(model, &TimelineListModel::selectedChanged, this, &TimelineProxyModel::selectedChanged);
	connect(model, &TimelineListModel::countChanged, this, &TimelineProxyModel::countChanged);

	QObject::connect(accountSettingsModel, &AccountSettingsModel::defaultAccountChanged, this, [this]() {
		qobject_cast<TimelineListModel*>(sourceModel())->update();
		invalidate();
		//updateCurrentSelection();
	});
	QObject::connect(coreManager->getSipAddressesModel(), &SipAddressesModel::sipAddressReset, this, [this]() {
		qobject_cast<TimelineListModel*>(sourceModel())->reset();
		invalidate();// Invalidate and reload GUI if the model has been reset
		//updateCurrentSelection();
	});

	setSourceModel(model);
	sort(0);
}

// -----------------------------------------------------------------------------

void TimelineProxyModel::unselectAll(){
	qobject_cast<TimelineListModel*>(sourceModel())->selectAll(false);
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
	if(!timeline || !timeline->getChatRoomModel() || timeline->getChatRoomModel()->getState() == (int)linphone::ChatRoom::State::Terminated)
		return false;
	bool haveEncryption = timeline->getChatRoomModel()->haveEncryption();
	if(!CoreManager::getInstance()->getSettingsModel()->getStandardChatEnabled() && !haveEncryption)
		return false;
	if(!CoreManager::getInstance()->getSettingsModel()->getSecureChatEnabled() && haveEncryption)
		return false;
	bool show = (mFilterFlags==0);// Show all at 0 (no hide all)
	bool isGroup = timeline->getChatRoomModel()->isGroupEnabled();
	bool isEphemeral = timeline->getChatRoomModel()->isEphemeralEnabled();

	if( mFilterFlags > 0) {
		show = !(( ( (mFilterFlags & TimelineFilter::SimpleChatRoom) == TimelineFilter::SimpleChatRoom) && isGroup)
				|| ( ( (mFilterFlags & TimelineFilter::SecureChatRoom) == TimelineFilter::SecureChatRoom) && !haveEncryption)
				|| ( ( (mFilterFlags & TimelineFilter::GroupChatRoom) == TimelineFilter::GroupChatRoom) && !isGroup)
				|| ( ( (mFilterFlags & TimelineFilter::StandardChatRoom) == TimelineFilter::StandardChatRoom) && haveEncryption)
				|| ( ( (mFilterFlags & TimelineFilter::EphemeralChatRoom) == TimelineFilter::EphemeralChatRoom) && !isEphemeral)
				|| ( ( (mFilterFlags & TimelineFilter::NoEphemeralChatRoom) == TimelineFilter::NoEphemeralChatRoom) && isEphemeral));
	}
		
	if(show && mFilterText != ""){
		QRegularExpression search(QRegularExpression::escape(mFilterText), QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption);
		show = timeline->getChatRoomModel()->getSubject().contains(search) 
			|| timeline->getChatRoomModel()->getUsername().contains(search);
			//|| timeline->getChatRoomModel()->getFullPeerAddress().contains(search); not enough significant?
	}
	if(show)
		show = timeline->getChatRoomModel()->isCurrentAccount();
	return show;
}

bool TimelineProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const TimelineModel* a = sourceModel()->data(left).value<TimelineModel*>();
	const TimelineModel* b = sourceModel()->data(right).value<TimelineModel*>();
	bool aHaveUnread = a->getChatRoomModel()->getAllUnreadCount() > 0;
	bool bHaveUnread = b->getChatRoomModel()->getAllUnreadCount() > 0;
	return (aHaveUnread && !bHaveUnread)
			|| (aHaveUnread == bHaveUnread && a->getChatRoomModel()->mLastUpdateTime > b->getChatRoomModel()->mLastUpdateTime);
}
