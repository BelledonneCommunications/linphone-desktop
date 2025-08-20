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

#include <QtDebug>

#include "core/App.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"

#include "AbstractEventCountNotifier.hpp"

// =============================================================================

using namespace std;

DEFINE_ABSTRACT_OBJECT(AbstractEventCountNotifier)

AbstractEventCountNotifier::AbstractEventCountNotifier(QObject *parent) : QObject(parent) {
}

int AbstractEventCountNotifier::getEventCount() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto coreModel = CoreModel::getInstance();
	int count = coreModel->getCore()->getMissedCallsCount();
	return count;
}

int AbstractEventCountNotifier::getCurrentEventCount() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	// auto coreModel = CoreModel::getInstance();
	// int count = coreModel->getCore()->getMissedCallsCount();
	// bool filtered = SettingsModel::getInstance()->isSystrayNotificationFiltered();
	// bool global = SettingsModel::getInstance()->isSystrayNotificationGlobal();
	// if (global && !filtered)
	return getEventCount();
	// else {
	// 	auto currentAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
	// 	if (currentAccount) {
	// 		auto linphoneChatRooms = currentAccount->filterChatRooms("");
	// 		for (const auto &chatRoom : linphoneChatRooms) {
	// 			count += chatRoom->getUnreadMessagesCount();
	// 		}
	// 	}
	// 	return count;
	// }
}