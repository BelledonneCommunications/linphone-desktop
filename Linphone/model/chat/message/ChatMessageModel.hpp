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

#ifndef CHAT_MESSAGE_MODEL_H_
#define CHAT_MESSAGE_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class ChatMessageModel : public ::Listener<linphone::ChatMessage, linphone::ChatMessageListener>,
                         public linphone::ChatMessageListener,
                         public AbstractObject {
	Q_OBJECT
public:
	ChatMessageModel(const std::shared_ptr<linphone::ChatMessage> &chatMessage, QObject *parent = nullptr);
	~ChatMessageModel();

	QString getText() const;
	QDateTime getTimestamp() const;

	QString getPeerAddress() const;

private:
	DECLARE_ABSTRACT_OBJECT
	virtual std::shared_ptr<linphone::Buffer> onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> &message,
	                                                             const std::shared_ptr<linphone::Content> &content,
	                                                             size_t offset,
	                                                             size_t size) override;
};

#endif
