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

#include "ParticipantInfoProxy.hpp"
#include "ParticipantInfoList.hpp"

#include "core/chat/ChatCore.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

#include <QDebug>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ParticipantInfoProxy)

ParticipantInfoProxy::ParticipantInfoProxy(QObject *parent) : LimitProxy(parent) {
	mParticipants = ParticipantInfoList::create();
	setSourceModels(new SortFilterList(mParticipants.get(), Qt::AscendingOrder));
}

ParticipantInfoProxy::~ParticipantInfoProxy() {
}

ChatGui *ParticipantInfoProxy::getChat() const {
	return mChat;
}

void ParticipantInfoProxy::setChat(ChatGui *chat) {
	lDebug() << "[ParticipantInfoProxy] set current chat " << chat;
	if (mChat != chat) {
		mChat = chat;
		mParticipants->setChatCore(chat ? chat->mCore : nullptr);
		emit chatChanged();
	}
}

// -----------------------------------------------------------------------------

bool ParticipantInfoProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool ParticipantInfoProxy::SortFilterList::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	return true;
}
