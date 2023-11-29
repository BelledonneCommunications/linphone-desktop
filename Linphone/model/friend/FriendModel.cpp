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

#include "FriendModel.hpp"

#include <QDebug>

DEFINE_ABSTRACT_OBJECT(FriendModel)

FriendModel::FriendModel(const std::shared_ptr<linphone::Friend> &contact, QObject *parent)
    : ::Listener<linphone::Friend, linphone::FriendListener>(contact, parent) {
	mustBeInLinphoneThread(getClassName());
}

FriendModel::~FriendModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

std::shared_ptr<linphone::Friend> FriendModel::getFriend() const {
	return mMonitor;
}

QDateTime FriendModel::getPresenceTimestamp() const {
	if (mMonitor->getPresenceModel()) {
		time_t timestamp = mMonitor->getPresenceModel()->getLatestActivityTimestamp();
		if (timestamp == -1) return QDateTime();
		else return QDateTime::fromMSecsSinceEpoch(timestamp * 1000);
	} else return QDateTime();
}

void FriendModel::onPresenceReceived(const std::shared_ptr<linphone::Friend> &contact) {
	emit presenceReceived(LinphoneEnums::fromLinphone(contact->getConsolidatedPresence()), getPresenceTimestamp());
}
