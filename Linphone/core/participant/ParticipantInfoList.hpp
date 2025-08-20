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

#ifndef PARTICIPANT_INFO_LIST_H_
#define PARTICIPANT_INFO_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "model/chat/ChatModel.hpp"
#include "tool/thread/SafeConnection.hpp"

class ChatCore;

// =============================================================================

class ParticipantInfoList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	static QSharedPointer<ParticipantInfoList> create();
	static QSharedPointer<ParticipantInfoList> create(const QSharedPointer<ChatCore> &chatCore);

	ParticipantInfoList(QObject *parent = Q_NULLPTR);
	virtual ~ParticipantInfoList();

	void setChatCore(const QSharedPointer<ChatCore> &chatCore);
	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void lUpdateParticipants();

private:
	QSharedPointer<ChatCore> mChatCore;
	DECLARE_ABSTRACT_OBJECT
};
#endif // PARTICIPANT_INFO_LIST_H_
