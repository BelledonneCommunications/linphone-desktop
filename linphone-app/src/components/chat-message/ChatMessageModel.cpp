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

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "ChatMessageModel.hpp"

// =============================================================================

ChatMessageModel::ChatMessageModel ( std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent) : QObject(parent) {
  mChatMessage = chatMessage;
}

std::shared_ptr<linphone::ChatMessage> ChatMessageModel::getChatMessage(){
	return mChatMessage;
}

bool ChatMessageModel::isEphemeral() const{
	return mChatMessage->isEphemeral();
}

qint64 ChatMessageModel::getEphemeralExpireTime() const{
	return 	mChatMessage->getEphemeralExpireTime();
}