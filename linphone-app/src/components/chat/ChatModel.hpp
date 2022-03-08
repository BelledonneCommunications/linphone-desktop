/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

// Used to store data between chats

#ifndef CHAT_MODEL_H_
#define CHAT_MODEL_H_

#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
class ContentListModel;

class ChatModel : public QObject{
	Q_OBJECT
public:
	ChatModel(QObject * parent = nullptr);
	
// Getters
	std::shared_ptr<ContentListModel> getContentListModel() const;
	
// Tools
	Q_INVOKABLE void clear();
	
private:
	std::shared_ptr<ContentListModel> mContents;
};

#endif
