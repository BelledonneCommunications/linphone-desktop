﻿/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#ifndef CHAT_REACTION_MODEL_H_
#define CHAT_REACTION_MODEL_H_

#include <linphone++/linphone.hh>
#include <QDateTime>
#include <QObject>

class ChatReactionModel : public QObject {
	
	Q_OBJECT
	
public:
	ChatReactionModel(const std::shared_ptr<const linphone::ChatMessageReaction>& reaction);
	
	Q_PROPERTY(QString body READ getBody WRITE setBody NOTIFY bodyChanged)
	Q_PROPERTY(QString fromAddress READ getFromAddress CONSTANT)
	
	QString getBody() const;
	void setBody(const QString& body);
	
	QString getFromAddress() const;
	
signals:
	void bodyChanged();
	
private:
	QString mBody;
	QString mFromAddress;
};

Q_DECLARE_METATYPE(QSharedPointer<ChatReactionModel>)

#endif
