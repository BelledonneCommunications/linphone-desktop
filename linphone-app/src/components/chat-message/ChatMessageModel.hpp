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

#ifndef CHAT_MESSAGE_MODEL_H
#define CHAT_MESSAGE_MODEL_H

#include "utils/LinphoneEnums.hpp"

// =============================================================================


class ChatMessageModel : public QObject {
  Q_OBJECT

public:
  ChatMessageModel (std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent = nullptr);
  
  Q_PROPERTY(bool isEphemeral READ isEphemeral NOTIFY isEphemeralChanged)
  Q_PROPERTY(qint64 ephemeralExpireTime READ getEphemeralExpireTime NOTIFY ephemeralExpireTimeChanged)
  
  std::shared_ptr<linphone::ChatMessage> getChatMessage();
  
  bool isEphemeral() const;
  qint64 getEphemeralExpireTime() const;
  
signals:
  void isEphemeralChanged();
  void ephemeralExpireTimeChanged();
  

private:
  std::shared_ptr<linphone::ChatMessage> mChatMessage;
};

Q_DECLARE_METATYPE(std::shared_ptr<ChatMessageModel>)

#endif
