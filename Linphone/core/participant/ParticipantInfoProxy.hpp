/*
 * Copyright (c) 2020 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_INFO_PROXY_H_
#define PARTICIPANT_INFO_PROXY_H_

#include "../proxy/LimitProxy.hpp"
#include "core/chat/ChatGui.hpp"
#include "tool/AbstractObject.hpp"

#include <memory>

class ParticipantInfoList;
class ChatModel;
// =============================================================================

class QWindow;

class ParticipantInfoProxy : public LimitProxy, public AbstractObject {

	Q_OBJECT
	Q_PROPERTY(ChatGui *chat READ getChat WRITE setChat NOTIFY chatChanged)

public:
	DECLARE_SORTFILTER_CLASS(bool mShowMe;)

	ParticipantInfoProxy(QObject *parent = Q_NULLPTR);
	~ParticipantInfoProxy();

	ChatGui *getChat() const;
	void setChat(ChatGui *chatGui);

signals:
	void chatChanged();

private:
	ChatGui *mChat = nullptr;
	QSharedPointer<ParticipantInfoList> mParticipants;
	DECLARE_ABSTRACT_OBJECT
};

#endif // PARTICIPANT_INFO_PROXY_H_
