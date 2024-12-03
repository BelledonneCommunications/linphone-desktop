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

#include "CallHistoryModel.hpp"

#include <QDebug>

#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(CallHistoryModel)

CallHistoryModel::CallHistoryModel(const std::shared_ptr<linphone::CallLog> &callLog, QObject *parent)
    : callLog(callLog) {
	mustBeInLinphoneThread(getClassName());
}

CallHistoryModel::~CallHistoryModel() {
	// mustBeInLinphoneThread("~" + getClassName());
}

void CallHistoryModel::removeCallHistory() {
	mustBeInLinphoneThread(getClassName() + "::removeCallHistory");
	qInfo() << "Removing call log: " << Utils::coreStringToAppString(callLog->getCallId());
	CoreModel::getInstance()->getCore()->removeCallLog(callLog);
}
