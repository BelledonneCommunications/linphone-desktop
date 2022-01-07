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

#ifndef CHAT_NOTICE_MODEL_H
#define CHAT_NOTICE_MODEL_H

#include "utils/LinphoneEnums.hpp"
#include "ChatEvent.hpp"

// =============================================================================


class ChatNoticeModel : public ChatEvent {
	Q_OBJECT
	
public:
	enum NoticeType {
		NoticeMessage,	// This is a Linphone message
		NoticeError,	// This is a Linphone error
		NoticeUnreadMessages
	};
	Q_ENUM(NoticeType);
	
	static std::shared_ptr<ChatNoticeModel> create(std::shared_ptr<linphone::EventLog> eventLog, QObject * parent = nullptr);// Call it instead constructor
	static std::shared_ptr<ChatNoticeModel> create(NoticeType noticeType, const QDateTime& timestamp,const QString& txt, QObject * parent = nullptr);
	ChatNoticeModel (std::shared_ptr<linphone::EventLog> eventLog, QObject * parent = nullptr);
	ChatNoticeModel (NoticeType noticeType, const QDateTime& timestamp, const QString& txt, QObject * parent = nullptr);
	virtual ~ChatNoticeModel();
	
	Q_PROPERTY(ChatRoomModel::EntryType type MEMBER mType CONSTANT)// NoticeEntry
	Q_PROPERTY(QDateTime timestamp MEMBER mTimestamp CONSTANT)
	Q_PROPERTY(QString name MEMBER mName WRITE setName NOTIFY nameChanged)
	Q_PROPERTY(NoticeType status MEMBER mStatus WRITE setStatus NOTIFY statusChanged)
	Q_PROPERTY(LinphoneEnums::EventLogType eventLogType MEMBER mEventLogType WRITE setEventLogType NOTIFY eventLogTypeChanged)
	
	
	std::shared_ptr<linphone::EventLog> getEventLog();
	
	void setName(const QString& data);
	void setStatus(NoticeType data);
	void setEventLogType(const LinphoneEnums::EventLogType& data);
	
	bool update();	// Update data from eventLog
	virtual void deleteEvent() override;
	
	QString mName;
	NoticeType mStatus;
	LinphoneEnums::EventLogType mEventLogType;
signals:
	void nameChanged();
	void statusChanged();
	void eventLogTypeChanged();
	
private:
	std::shared_ptr<linphone::EventLog> mEventLog;
	std::weak_ptr<ChatNoticeModel> mSelf;	// Used to pass to functions that need a shared_ptr
};

Q_DECLARE_METATYPE(std::shared_ptr<ChatNoticeModel>)
Q_DECLARE_METATYPE(ChatNoticeModel*)

#endif

