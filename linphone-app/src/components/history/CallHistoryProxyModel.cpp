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

#include "CallHistoryProxyModel.hpp"
#include "CallHistoryListModel.hpp"
#include "CallHistoryModel.hpp"

#include "app/App.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "utils/Utils.hpp"
#include <QDebug>
#include <QQuickWindow>


// =============================================================================

// -----------------------------------------------------------------------------

CallHistoryProxyModel::CallHistoryProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	auto model = new CallHistoryListModel();
	setSourceModel(model);
	sort(0);
	connect(CoreManager::getInstance()->getAccountSettingsModel(), &AccountSettingsModel::defaultAccountChanged, model, &CallHistoryListModel::reload);
	connect(model, &CallHistoryListModel::lastCallDateChanged, this, &CallHistoryProxyModel::invalidate);
	App *app = App::getInstance();
	connect(app->getMainWindow(), &QWindow::activeChanged, this, [this]() {
		handleIsActiveChanged(App::getInstance()->getMainWindow());
	});
}

// -----------------------------------------------------------------------------

void CallHistoryProxyModel::setFilterFlags(int filterFlags){
	if( mFilterFlags != filterFlags){
		mFilterFlags = filterFlags;
		invalidate();
		emit filterFlagsChanged();
	}
}

void CallHistoryProxyModel::setFilterText(const QString& text){
	if( mFilterText != text){
		mFilterText = text;
		invalidate();
		emit filterTextChanged();
	}
}
	
// -----------------------------------------------------------------------------

bool CallHistoryProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	if(!sourceModel())
		return false;
	bool show = true;
	
	const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	auto timeline = sourceModel()->data(index).value<CallHistoryModel*>();
	
	if( mFilterFlags > 0) {
		show = ( ((mFilterFlags & CallTimelineFilter::Incoming) == CallTimelineFilter::Incoming) && !timeline->mLastCallIsOutgoing)
				|| ( ((mFilterFlags & CallTimelineFilter::Outgoing) == CallTimelineFilter::Outgoing) && timeline->mLastCallIsOutgoing)
				|| ( ((mFilterFlags & CallTimelineFilter::Missed) == CallTimelineFilter::Missed) && timeline->mLastCallStatus == LinphoneEnums::CallStatusMissed)
				;
	}
	
	
	if(show && mFilterText != ""){
		QRegularExpression search(QRegularExpression::escape(mFilterText), QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption);
		show = ( timeline->getTitle().contains(search)
				//|| timeline->getRemoteAddress().contains(search)
				|| Utils::getDisplayName(timeline->getRemoteAddress()).contains(search)
				);
			//|| timeline->getChatRoomModel()->getFullPeerAddress().contains(search); not enough significant?
	}
	return show;
}

bool CallHistoryProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	if( !sourceModel())
		return false;
	const CallHistoryModel* a = sourceModel()->data(left).value<CallHistoryModel*>();
	const CallHistoryModel* b = sourceModel()->data(right).value<CallHistoryModel*>();
	return a->mLastCallDate > b->mLastCallDate;
}

static inline QWindow *getParentWindow (QObject *object) {
	App *app = App::getInstance();
	const QWindow *mainWindow = app->getMainWindow();
	const QWindow *callsWindow = app->getCallsWindow();
	for (QObject *parent = object->parent(); parent; parent = parent->parent())
		if (parent == mainWindow || parent == callsWindow)
			return static_cast<QWindow *>(parent);
	return nullptr;
}

void CallHistoryProxyModel::handleIsActiveChanged (QWindow *window) {
	if (window->isActive() && getParentWindow(this) == window) {
		CoreManager::getInstance()->resetMissedCallsCount();
	}
}
