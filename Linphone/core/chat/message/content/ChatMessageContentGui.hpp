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

#ifndef CHAT_MESSAGE_CONTENT_GUI_H_
#define CHAT_MESSAGE_CONTENT_GUI_H_

#include "core/chat/message/content/ChatMessageContentCore.hpp"
#include <QObject>
#include <QSharedPointer>

class ChatMessageContentGui : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(ChatMessageContentCore *core READ getCore CONSTANT)

public:
	ChatMessageContentGui(QSharedPointer<ChatMessageContentCore> core);
	~ChatMessageContentGui();
	ChatMessageContentCore *getCore() const;
	QSharedPointer<ChatMessageContentCore> mCore;
	DECLARE_ABSTRACT_OBJECT
};

#endif
