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

#ifndef CHAT_CALL_MODEL_H
#define CHAT_CALL_MODEL_H

#include "utils/LinphoneEnums.hpp"
#include "ChatEvent.hpp"

// =============================================================================


class ChatCallModel : public QObject, public ChatEvent  {
	Q_OBJECT
	
public:
	static std::shared_ptr<ChatCallModel> create(std::shared_ptr<linphone::CallLog> chatLog, const bool& isStart, QObject * parent = nullptr);// Call it instead constructor
	ChatCallModel (std::shared_ptr<linphone::CallLog> eventLog, const bool& isStart, QObject * parent = nullptr);
	virtual ~ChatCallModel();
	
	Q_PROPERTY(ChatRoomModel::EntryType type MEMBER mType CONSTANT)
	Q_PROPERTY(QDateTime timestamp MEMBER mTimestamp CONSTANT)
	
	Q_PROPERTY(bool isStart MEMBER mIsStart WRITE setIsStart NOTIFY isStartChanged)
	Q_PROPERTY(LinphoneEnums::CallStatus status MEMBER mStatus WRITE setStatus NOTIFY statusChanged)
	Q_PROPERTY(bool isOutgoing MEMBER mIsOutgoing WRITE setIsOutgoing NOTIFY isOutgoingChanged)
	
	std::shared_ptr<linphone::CallLog> getCallLog();
	
	void setIsStart(const bool& isStart);
	void setStatus(const LinphoneEnums::CallStatus& status);
	void setIsOutgoing(const bool& isOutgoing);
	
	bool update();
	
	bool mIsStart;
	LinphoneEnums::CallStatus mStatus;
	bool mIsOutgoing;
signals:
	void isStartChanged();
	void statusChanged();
	void isOutgoingChanged();
	
private:
	std::shared_ptr<linphone::CallLog> mCallLog;
	std::weak_ptr<ChatCallModel> mSelf;	// Used to pass to functions that need a shared_ptr
};

Q_DECLARE_METATYPE(std::shared_ptr<ChatCallModel>)
Q_DECLARE_METATYPE(ChatCallModel*)
#endif
