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
#include "components/chat/ChatModel.hpp"
#include "utils/Utils.hpp"

#include "TimelineModel.hpp"

#include <QDebug>


// =============================================================================

TimelineModel::TimelineModel (std::shared_ptr<linphone::ChatRoom> chatRoom, QObject *parent) : QObject(parent) {
	mChatModel = CoreManager::getInstance()->getChatModel(chatRoom);
}

QString TimelineModel::getFullPeerAddress() const{
	return mChatModel->getFullPeerAddress();
}
QString TimelineModel::getFullLocalAddress() const{
	return mChatModel->getLocalAddress();
}


QString TimelineModel::getUsername() const{
	std::string username = mChatModel->getChatRoom()->getSubject();
	if(username != ""){
		return QString::fromStdString(username);
	}
	username = mChatModel->getChatRoom()->getPeerAddress()->getDisplayName();
	if(username != "")
		return QString::fromStdString(username);
	username = mChatModel->getChatRoom()->getPeerAddress()->getUsername();
	if(username != "")
		return QString::fromStdString(username);
	return QString::fromStdString(mChatModel->getChatRoom()->getPeerAddress()->asStringUriOnly());
}

QString TimelineModel::getAvatar() const{
	return "";
}

int TimelineModel::getPresenceStatus() const{
	return 0;
}

std::shared_ptr<ChatModel> TimelineModel::getChatModel() const{
	return mChatModel;
}
