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

#include <QtDebug>

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/timeline/TimelineListModel.hpp"

#include "AbstractEventCountNotifier.hpp"
#include "components/timeline/TimelineModel.hpp"

// =============================================================================

using namespace std;

AbstractEventCountNotifier::AbstractEventCountNotifier(QObject *parent)
	: QObject(parent)
{
	CoreManager *coreManager = CoreManager::getInstance();
	connect(coreManager,
			&CoreManager::eventCountChanged,
			this,
			&AbstractEventCountNotifier::eventCountChanged);
	connect(coreManager->getAccountSettingsModel(),
			&AccountSettingsModel::defaultAccountChanged,
			this,
			&AbstractEventCountNotifier::internalNotifyEventCount);
	connect(this,
			&AbstractEventCountNotifier::eventCountChanged,
			this,
			&AbstractEventCountNotifier::internalNotifyEventCount);
}

// -----------------------------------------------------------------------------

int AbstractEventCountNotifier::getEventCount() const
{
	auto coreManager = CoreManager::getInstance();
	int count = coreManager->getCore()->getMissedCallsCount();
	if (coreManager->getSettingsModel()->getStandardChatEnabled()
		|| coreManager->getSettingsModel()->getSecureChatEnabled())
		count += coreManager->getCore()->getUnreadChatMessageCountFromActiveLocals();
	return count;
}

int AbstractEventCountNotifier::getCurrentEventCount() const
{
	auto coreManager = CoreManager::getInstance();
	int count = coreManager->getCore()->getMissedCallsCount();
	auto timelines = coreManager->getTimelineListModel()->getSharedList<TimelineModel>();
	bool filtered = CoreManager::getInstance()->getSettingsModel()->isSystrayNotificationFiltered();
	bool global = CoreManager::getInstance()->getSettingsModel()->isSystrayNotificationGlobal();
	if( global && !filtered) return getEventCount();
	for (const auto &timeline : timelines) {
		auto chatRoom = timeline->getChatRoomModel();
		if (!coreManager->getCore()->getDefaultAccount()
			|| ((global || chatRoom->isCurrentAccount()) && (!filtered || chatRoom->isNotificationsEnabled())))
			count += chatRoom->getUnreadMessagesCount();
	}
	return count;
}

void AbstractEventCountNotifier::internalNotifyEventCount()
{
	int n = getCurrentEventCount();

	qInfo() << QStringLiteral("Notify event count: %1.").arg(n);
	n = n > 99 ? 99 : n;
	notifyEventCount(n);
}
