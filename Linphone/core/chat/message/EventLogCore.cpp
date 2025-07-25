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

#include "EventLogCore.hpp"
#include "core/App.hpp"
#include "core/chat/ChatCore.hpp"
#include "model/tool/ToolModel.hpp"

DEFINE_ABSTRACT_OBJECT(EventLogCore)

QSharedPointer<EventLogCore> EventLogCore::create(const std::shared_ptr<const linphone::EventLog> &eventLog) {
	auto sharedPointer = QSharedPointer<EventLogCore>(new EventLogCore(eventLog), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

EventLogCore::EventLogCore(const std::shared_ptr<const linphone::EventLog> &eventLog) {
	mustBeInLinphoneThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mEventLogType = LinphoneEnums::fromLinphone(eventLog->getType());
	mTimestamp = QDateTime::fromMSecsSinceEpoch(eventLog->getCreationTime() * 1000);
	auto chatmessage = eventLog->getChatMessage();
	if (chatmessage) {
		mChatMessageCore = ChatMessageCore::create(chatmessage);
		mEventId = Utils::coreStringToAppString(chatmessage->getMessageId());
		mTimestamp = QDateTime::fromSecsSinceEpoch(chatmessage->getTime());
	} else if (eventLog->getCallLog()) {
		mCallHistoryCore = CallHistoryCore::create(eventLog->getCallLog());
		mEventId = Utils::coreStringToAppString(eventLog->getCallLog()->getCallId());
	}
	if (mEventId.isEmpty()) { // getNotifyId
		QString type = QString::fromLatin1(
		    QMetaEnum::fromType<LinphoneEnums::EventLogType>().valueToKey(static_cast<int>(mEventLogType)));
		mEventId = type + QString::number(static_cast<qint64>(eventLog->getCreationTime()));
		computeEvent(eventLog);
	}
}

EventLogCore::~EventLogCore() {
}

void EventLogCore::setSelf(QSharedPointer<EventLogCore> me) {
}

QString EventLogCore::getEventLogId() {
	return mEventId;
}

QSharedPointer<ChatMessageCore> EventLogCore::getChatMessageCore() {
	return mChatMessageCore;
}
ChatMessageGui *EventLogCore::getChatMessageGui() {
	return mChatMessageCore ? new ChatMessageGui(mChatMessageCore) : nullptr;
}

QSharedPointer<CallHistoryCore> EventLogCore::getCallHistoryCore() {
	return mCallHistoryCore;
}

ChatMessageCore *EventLogCore::getChatMessageCorePointer() {
	return mChatMessageCore.get();
}
CallHistoryCore *EventLogCore::getCallHistoryCorePointer() {
	return mCallHistoryCore.get();
}

QDateTime EventLogCore::getTimestamp() const {
	return mTimestamp;
}

// Events (other than ChatMessage and CallLog which are handled in their respective Core)

void EventLogCore::computeEvent(const std::shared_ptr<const linphone::EventLog> &eventLog) {
	mustBeInLinphoneThread(getClassName());
	mHandled = true;
	mImportant = false;
	mEphemeralRelated = false;

	auto participantAddress = eventLog->getParticipantAddress() ? eventLog->getParticipantAddress()->clone() : nullptr;

	switch (eventLog->getType()) {
		case linphone::EventLog::Type::ConferenceCreated:
			mEventDetails = tr("conference_created_event");
			break;
		case linphone::EventLog::Type::ConferenceTerminated:
			mEventDetails = tr("conference_created_terminated");
			mImportant = true;
			break;
		case linphone::EventLog::Type::ConferenceParticipantAdded:
			mEventDetails = tr("conference_participant_added_event").arg(ToolModel::getDisplayName(participantAddress));
			break;
		case linphone::EventLog::Type::ConferenceParticipantRemoved:
			mEventDetails =
			    tr("conference_participant_removed_event").arg(ToolModel::getDisplayName(participantAddress));
			mImportant = true;
			break;
		case linphone::EventLog::Type::ConferenceSecurityEvent: {
			if (eventLog->getSecurityEventType() == linphone::EventLog::SecurityEventType::SecurityLevelDowngraded) {
				auto faultyParticipant = eventLog->getSecurityEventFaultyDeviceAddress()
				                             ? eventLog->getSecurityEventFaultyDeviceAddress()->clone()
				                             : nullptr;
				if (faultyParticipant)
					mEventDetails = tr("conference_security_event").arg(ToolModel::getDisplayName(faultyParticipant));
				else if (participantAddress)
					mEventDetails = tr("conference_security_event").arg(ToolModel::getDisplayName(participantAddress));
				mImportant = true;
			} else mHandled = false;
			break;
		}
		case linphone::EventLog::Type::ConferenceEphemeralMessageEnabled:
			mEphemeralRelated = true;
			mEventDetails = tr("conference_ephemeral_message_enabled_event")
			                    .arg(Utils::getEphemeralFormatedTime(eventLog->getEphemeralMessageLifetime()));
			break;
		case linphone::EventLog::Type::ConferenceEphemeralMessageLifetimeChanged:
			mEphemeralRelated = true;
			mHandled = eventLog->getEphemeralMessageLifetime() != 0; // Disabled is sent in case of 0.
			mEventDetails = tr("conference_ephemeral_message_lifetime_changed_event")
			                    .arg(Utils::getEphemeralFormatedTime(eventLog->getEphemeralMessageLifetime()));
			break;
		case linphone::EventLog::Type::ConferenceEphemeralMessageDisabled:
			mEphemeralRelated = true;
			mEventDetails = tr("conference_ephemeral_message_disabled_event");
			mImportant = true;
			break;
		case linphone::EventLog::Type::ConferenceSubjectChanged:
			mEventDetails = tr("conference_subject_changed_event").arg(QString::fromStdString(eventLog->getSubject()));
			break;
		case linphone::EventLog::Type::ConferenceParticipantSetAdmin:
			mEventDetails =
			    tr("conference_participant_set_admin_event").arg(ToolModel::getDisplayName(participantAddress));
			break;
		case linphone::EventLog::Type::ConferenceParticipantUnsetAdmin:
			mEventDetails =
			    tr("conference_participant_unset_admin_event").arg(ToolModel::getDisplayName(participantAddress));
			break;
		default:
			mHandled = false;
	}
}
