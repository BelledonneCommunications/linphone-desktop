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

#ifndef LINPHONE_ENUMS_H_
#define LINPHONE_ENUMS_H_

#include <linphone++/linphone.hh>
#include <QObject>

// This namespace is used to pass Linphone enumerators to QML

// =============================================================================

namespace LinphoneEnums {
Q_NAMESPACE

void registerMetaTypes();

enum MediaEncryption {
	MediaEncryptionNone = int(linphone::MediaEncryption::None),
	MediaEncryptionDtls = int(linphone::MediaEncryption::DTLS),
	MediaEncryptionSrtp = int(linphone::MediaEncryption::SRTP),
	MediaEncryptionZrtp = int(linphone::MediaEncryption::ZRTP)
};
Q_ENUM_NS(MediaEncryption)

linphone::MediaEncryption toLinphone(const LinphoneEnums::MediaEncryption& encryption);
LinphoneEnums::MediaEncryption fromLinphone(const linphone::MediaEncryption& encryption);

enum FriendCapability {
	FriendCapabilityNone = int(linphone::FriendCapability::None),
	FriendCapabilityGroupChat = int(linphone::FriendCapability::GroupChat),
	FriendCapabilityLimeX3Dh = int(linphone::FriendCapability::LimeX3Dh),
	FriendCapabilityEphemeralMessages = int(linphone::FriendCapability::EphemeralMessages)
};
Q_ENUM_NS(FriendCapability)

linphone::FriendCapability toLinphone(const LinphoneEnums::FriendCapability& capability);
LinphoneEnums::FriendCapability fromLinphone(const linphone::FriendCapability& capability);


enum EventLogType {
	EventLogTypeNone = int(linphone::EventLog::Type::None),
	EventLogTypeConferenceCreated = int(linphone::EventLog::Type::ConferenceCreated),
	EventLogTypeConferenceTerminated = int(linphone::EventLog::Type::ConferenceTerminated),
	EventLogTypeConferenceCallStart = int(linphone::EventLog::Type::ConferenceCallStart),
	EventLogTypeConferenceCallEnd = int(linphone::EventLog::Type::ConferenceCallEnd),
	EventLogTypeConferenceChatMessage = int(linphone::EventLog::Type::ConferenceChatMessage),
	EventLogTypeConferenceParticipantAdded = int(linphone::EventLog::Type::ConferenceParticipantAdded),
	EventLogTypeConferenceParticipantRemoved = int(linphone::EventLog::Type::ConferenceParticipantRemoved),
	EventLogTypeConferenceParticipantSetAdmin = int(linphone::EventLog::Type::ConferenceParticipantSetAdmin),
	EventLogTypeConferenceParticipantUnsetAdmin = int(linphone::EventLog::Type::ConferenceParticipantUnsetAdmin),
	EventLogTypeConferenceParticipantDeviceAdded = int(linphone::EventLog::Type::ConferenceParticipantDeviceAdded),
	EventLogTypeConferenceParticipantDeviceRemoved = int(linphone::EventLog::Type::ConferenceParticipantDeviceRemoved),
	EventLogTypeConferenceParticipantDeviceMediaChanged = int(linphone::EventLog::Type::ConferenceParticipantDeviceMediaChanged),
	EventLogTypeConferenceSubjectChanged= int(linphone::EventLog::Type::ConferenceSubjectChanged),
	EventLogTypeConferenceAvailableMediaChanged = int(linphone::EventLog::Type::ConferenceAvailableMediaChanged),
	EventLogTypeConferenceSecurityEvent = int(linphone::EventLog::Type::ConferenceSecurityEvent),
	EventLogTypeConferenceEphemeralMessageLifetimeChanged = int(linphone::EventLog::Type::ConferenceEphemeralMessageLifetimeChanged),
	EventLogTypeConferenceEphemeralMessageEnabled = int(linphone::EventLog::Type::ConferenceEphemeralMessageEnabled),
	EventLogTypeConferenceEphemeralMessageDisabled = int(linphone::EventLog::Type::ConferenceEphemeralMessageDisabled)
};
Q_ENUM_NS(EventLogType)

linphone::EventLog::Type toLinphone(const LinphoneEnums::EventLogType& capability);
LinphoneEnums::EventLogType fromLinphone(const linphone::EventLog::Type& data);

enum ChatMessageState {
	ChatMessageStateIdle = int(linphone::ChatMessage::State::Idle),
	ChatMessageStateInProgress = int(linphone::ChatMessage::State::InProgress),
	ChatMessageStateDelivered = int(linphone::ChatMessage::State::Delivered),
	ChatMessageStateNotDelivered = int(linphone::ChatMessage::State::NotDelivered),
	ChatMessageStateFileTransferError = int(linphone::ChatMessage::State::FileTransferError),
	ChatMessageStateFileTransferDone = int(linphone::ChatMessage::State::FileTransferDone),
	ChatMessageStateDeliveredToUser = int(linphone::ChatMessage::State::DeliveredToUser),
	ChatMessageStateDisplayed = int(linphone::ChatMessage::State::Displayed),
	ChatMessageStateFileTransferInProgress = int(linphone::ChatMessage::State::FileTransferInProgress)
};
Q_ENUM_NS(ChatMessageState)

linphone::ChatMessage::State toLinphone(const LinphoneEnums::ChatMessageState& capability);
LinphoneEnums::ChatMessageState fromLinphone(const linphone::ChatMessage::State& capability);

enum CallStatus {
		CallStatusDeclined = int(linphone::Call::Status::Declined),
		CallStatusMissed = int(linphone::Call::Status::Missed),
		CallStatusSuccess = int(linphone::Call::Status::Success),
		CallStatusAborted = int(linphone::Call::Status::Aborted),
		CallStatusEarlyAborted = int(linphone::Call::Status::EarlyAborted),
		CallStatusAcceptedElsewhere = int(linphone::Call::Status::AcceptedElsewhere),
		CallStatusDeclinedElsewhere = int(linphone::Call::Status::DeclinedElsewhere)
	};
Q_ENUM_NS(CallStatus)

linphone::Call::Status toLinphone(const LinphoneEnums::CallStatus& capability);
LinphoneEnums::CallStatus fromLinphone(const linphone::Call::Status& capability);


}

Q_DECLARE_METATYPE(LinphoneEnums::MediaEncryption)
Q_DECLARE_METATYPE(LinphoneEnums::FriendCapability)
Q_DECLARE_METATYPE(LinphoneEnums::EventLogType)
Q_DECLARE_METATYPE(LinphoneEnums::ChatMessageState)
Q_DECLARE_METATYPE(LinphoneEnums::CallStatus)

#endif
