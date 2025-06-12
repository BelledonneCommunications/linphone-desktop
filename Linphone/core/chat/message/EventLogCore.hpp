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

#ifndef EVENT_LOG_CORE_H_
#define EVENT_LOG_CORE_H_

#include "ChatMessageCore.hpp"
#include "core/call-history/CallHistoryCore.hpp"
#include "core/conference/ConferenceInfoCore.hpp"
#include "core/conference/ConferenceInfoGui.hpp"
#include "model/chat/message/ChatMessageModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>

#include <linphone++/linphone.hh>

class ChatMessageCore;

class EventLogCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(LinphoneEnums::EventLogType type MEMBER mEventLogType CONSTANT)
	Q_PROPERTY(ChatMessageCore *chatMessage READ getChatMessageCorePointer CONSTANT)
	// Q_PROPERTY(NotifyCore *notification MEMBER mNotifyCore CONSTANT)
	Q_PROPERTY(CallHistoryCore *callLog READ getCallHistoryCorePointer CONSTANT)
	Q_PROPERTY(bool important MEMBER mImportant CONSTANT)
	Q_PROPERTY(bool handled MEMBER mHandled CONSTANT)
	Q_PROPERTY(QString eventDetails MEMBER mEventDetails CONSTANT)
	Q_PROPERTY(QDateTime timestamp MEMBER mTimestamp CONSTANT)

public:
	static QSharedPointer<EventLogCore> create(const std::shared_ptr<const linphone::EventLog> &eventLog);
	EventLogCore(const std::shared_ptr<const linphone::EventLog> &eventLog);
	~EventLogCore();
	void setSelf(QSharedPointer<EventLogCore> me);
	std::string getEventLogId();
	QSharedPointer<ChatMessageCore> getChatMessageCore();
	QSharedPointer<CallHistoryCore> getCallHistoryCore();
	bool isHandled() const {
		return mHandled;
	}

private:
	DECLARE_ABSTRACT_OBJECT
	std::string mEventId;

	QSharedPointer<ChatMessageCore> mChatMessageCore = nullptr;
	QSharedPointer<CallHistoryCore> mCallHistoryCore = nullptr;
	LinphoneEnums::EventLogType mEventLogType;
	bool mHandled;
	bool mImportant;
	QString mEventDetails;
	QDateTime mTimestamp;

	ChatMessageCore *getChatMessageCorePointer();
	CallHistoryCore *getCallHistoryCorePointer();
	void computeEvent(const std::shared_ptr<const linphone::EventLog> &eventLog);
	QString getEphemeralFormatedTime(int selectedTime);
};

#endif // EventLogCore_H_
