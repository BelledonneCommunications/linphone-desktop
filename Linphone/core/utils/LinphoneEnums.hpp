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

#include <QObject>
#include <linphone++/linphone.hh>

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

linphone::MediaEncryption toLinphone(const LinphoneEnums::MediaEncryption &encryption);
LinphoneEnums::MediaEncryption fromLinphone(const linphone::MediaEncryption &encryption);

enum FriendCapability {
	FriendCapabilityNone = int(linphone::Friend::Capability::None),
	FriendCapabilityGroupChat = int(linphone::Friend::Capability::GroupChat),
	FriendCapabilityLimeX3Dh = int(linphone::Friend::Capability::LimeX3Dh),
	FriendCapabilityEphemeralMessages = int(linphone::Friend::Capability::EphemeralMessages)
};
Q_ENUM_NS(FriendCapability)

linphone::Friend::Capability toLinphone(const LinphoneEnums::FriendCapability &capability);
LinphoneEnums::FriendCapability fromLinphone(const linphone::Friend::Capability &capability);

enum EventLogType {
	EventLogTypeNone = int(linphone::EventLog::Type::None),
	EventLogTypeConferenceCreated = int(linphone::EventLog::Type::ConferenceCreated),
	EventLogTypeConferenceTerminated = int(linphone::EventLog::Type::ConferenceTerminated),
	EventLogTypeConferenceCallStarted = int(linphone::EventLog::Type::ConferenceCallStarted),
	EventLogTypeConferenceCallEnded = int(linphone::EventLog::Type::ConferenceCallEnded),
	EventLogTypeConferenceChatMessage = int(linphone::EventLog::Type::ConferenceChatMessage),
	EventLogTypeConferenceParticipantAdded = int(linphone::EventLog::Type::ConferenceParticipantAdded),
	EventLogTypeConferenceParticipantRemoved = int(linphone::EventLog::Type::ConferenceParticipantRemoved),
	EventLogTypeConferenceParticipantSetAdmin = int(linphone::EventLog::Type::ConferenceParticipantSetAdmin),
	EventLogTypeConferenceParticipantUnsetAdmin = int(linphone::EventLog::Type::ConferenceParticipantUnsetAdmin),
	EventLogTypeConferenceParticipantDeviceAdded = int(linphone::EventLog::Type::ConferenceParticipantDeviceAdded),
	EventLogTypeConferenceParticipantDeviceRemoved = int(linphone::EventLog::Type::ConferenceParticipantDeviceRemoved),
	EventLogTypeConferenceParticipantDeviceMediaAvailabilityChanged =
	    int(linphone::EventLog::Type::ConferenceParticipantDeviceMediaAvailabilityChanged),
	EventLogTypeConferenceSubjectChanged = int(linphone::EventLog::Type::ConferenceSubjectChanged),
	EventLogTypeConferenceAvailableMediaChanged = int(linphone::EventLog::Type::ConferenceAvailableMediaChanged),
	EventLogTypeConferenceSecurityEvent = int(linphone::EventLog::Type::ConferenceSecurityEvent),
	EventLogTypeConferenceEphemeralMessageLifetimeChanged =
	    int(linphone::EventLog::Type::ConferenceEphemeralMessageLifetimeChanged),
	EventLogTypeConferenceEphemeralMessageEnabled = int(linphone::EventLog::Type::ConferenceEphemeralMessageEnabled),
	EventLogTypeConferenceEphemeralMessageDisabled = int(linphone::EventLog::Type::ConferenceEphemeralMessageDisabled)
};
Q_ENUM_NS(EventLogType)

linphone::EventLog::Type toLinphone(const LinphoneEnums::EventLogType &capability);
LinphoneEnums::EventLogType fromLinphone(const linphone::EventLog::Type &data);

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

linphone::ChatMessage::State toLinphone(const LinphoneEnums::ChatMessageState &data);
LinphoneEnums::ChatMessageState fromLinphone(const linphone::ChatMessage::State &data);

enum ChatRoomState {
	ChatRoomStateNone = int(linphone::ChatRoom::State::None),
	ChatRoomStateInstantiated = int(linphone::ChatRoom::State::Instantiated),
	ChatRoomStateCreationPending = int(linphone::ChatRoom::State::CreationPending),
	ChatRoomStateCreated = int(linphone::ChatRoom::State::Created),
	ChatRoomStateCreationFailed = int(linphone::ChatRoom::State::CreationFailed),
	ChatRoomStateTerminationPending = int(linphone::ChatRoom::State::TerminationPending),
	ChatRoomStateTerminated = int(linphone::ChatRoom::State::Terminated),
	ChatRoomStateTerminationFailed = int(linphone::ChatRoom::State::TerminationFailed),
	ChatRoomStateDeleted = int(linphone::ChatRoom::State::Deleted),
};
Q_ENUM_NS(ChatRoomState)

linphone::ChatRoom::State toLinphone(const LinphoneEnums::ChatRoomState &data);
LinphoneEnums::ChatRoomState fromLinphone(const linphone::ChatRoom::State &data);

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

linphone::Call::Status toLinphone(const LinphoneEnums::CallStatus &capability);
LinphoneEnums::CallStatus fromLinphone(const linphone::Call::Status &capability);

enum ConferenceLayout {
	ConferenceLayoutGrid = int(linphone::Conference::Layout::Grid),
	ConferenceLayoutActiveSpeaker = int(linphone::Conference::Layout::ActiveSpeaker),
	ConferenceLayoutAudioOnly = ConferenceLayoutGrid + ConferenceLayoutActiveSpeaker + 1,
};
Q_ENUM_NS(ConferenceLayout)

linphone::Conference::Layout toLinphone(const LinphoneEnums::ConferenceLayout &layout);
LinphoneEnums::ConferenceLayout fromLinphone(const linphone::Conference::Layout &layout);

enum ConferenceInfoState {
	ConferenceInfoStateNew = int(linphone::ConferenceInfo::State::New),
	ConferenceInfoStateUpdated = int(linphone::ConferenceInfo::State::Updated),
	ConferenceInfoStateCancelled = int(linphone::ConferenceInfo::State::Cancelled)
};
Q_ENUM_NS(ConferenceInfoState)

linphone::ConferenceInfo::State toLinphone(const LinphoneEnums::ConferenceInfoState &state);
LinphoneEnums::ConferenceInfoState fromLinphone(const linphone::ConferenceInfo::State &state);

enum ConferenceSchedulerState {
	ConferenceSchedulerStateAllocationPending = int(linphone::ConferenceScheduler::State::AllocationPending),
	ConferenceSchedulerStateError = int(linphone::ConferenceScheduler::State::Error),
	ConferenceSchedulerStateIdle = int(linphone::ConferenceScheduler::State::Idle),
	ConferenceSchedulerStateReady = int(linphone::ConferenceScheduler::State::Ready),
	ConferenceSchedulerStateUpdating = int(linphone::ConferenceScheduler::State::Updating)
};
Q_ENUM_NS(ConferenceSchedulerState)

linphone::ConferenceScheduler::State toLinphone(const LinphoneEnums::ConferenceSchedulerState &state);
LinphoneEnums::ConferenceSchedulerState fromLinphone(const linphone::ConferenceScheduler::State &state);

enum ParticipantDeviceState {
	ParticipantDeviceStateJoining = int(linphone::ParticipantDevice::State::Joining),
	ParticipantDeviceStatePresent = int(linphone::ParticipantDevice::State::Present),
	ParticipantDeviceStateLeaving = int(linphone::ParticipantDevice::State::Leaving),
	ParticipantDeviceStateLeft = int(linphone::ParticipantDevice::State::Left),
	ParticipantDeviceStateScheduledForJoining = int(linphone::ParticipantDevice::State::ScheduledForJoining),
	ParticipantDeviceStateScheduledForLeaving = int(linphone::ParticipantDevice::State::ScheduledForLeaving),
	ParticipantDeviceStateOnHold = int(linphone::ParticipantDevice::State::OnHold),
	ParticipantDeviceStateAlerting = int(linphone::ParticipantDevice::State::Alerting),
	ParticipantDeviceStateMutedByFocus = int(linphone::ParticipantDevice::State::MutedByFocus),

};
Q_ENUM_NS(ParticipantDeviceState)

linphone::ParticipantDevice::State toLinphone(const LinphoneEnums::ParticipantDeviceState &state);
LinphoneEnums::ParticipantDeviceState fromLinphone(const linphone::ParticipantDevice::State &state);

enum TunnelMode {
	TunnelModeDisable = int(linphone::Tunnel::Mode::Disable),
	TunnelModeEnable = int(linphone::Tunnel::Mode::Enable),
	TunnelModeAuto = int(linphone::Tunnel::Mode::Auto)
};
Q_ENUM_NS(TunnelMode)

linphone::Tunnel::Mode toLinphone(const LinphoneEnums::TunnelMode &mode);
LinphoneEnums::TunnelMode fromLinphone(const linphone::Tunnel::Mode &mode);

enum RecorderState {
	RecorderStateClosed = int(linphone::Recorder::State::Closed),
	RecorderStatePaused = int(linphone::Recorder::State::Paused),
	RecorderStateRunning = int(linphone::Recorder::State::Running)
};
Q_ENUM_NS(RecorderState)

linphone::Recorder::State toLinphone(const LinphoneEnums::RecorderState &state);
LinphoneEnums::RecorderState fromLinphone(const linphone::Recorder::State &state);

enum TransportType {
	TransportTypeDtls = int(linphone::TransportType::Dtls),
	TransportTypeTcp = int(linphone::TransportType::Tcp),
	TransportTypeTls = int(linphone::TransportType::Tls),
	TransportTypeUdp = int(linphone::TransportType::Udp)
};
Q_ENUM_NS(TransportType)

linphone::TransportType toLinphone(const LinphoneEnums::TransportType &type);
LinphoneEnums::TransportType fromLinphone(const linphone::TransportType &type);
QString toString(const LinphoneEnums::TransportType &type);
void fromString(const QString &transportType, LinphoneEnums::TransportType *transport);
} // namespace LinphoneEnums

Q_DECLARE_METATYPE(LinphoneEnums::CallStatus)
Q_DECLARE_METATYPE(LinphoneEnums::ChatMessageState)
Q_DECLARE_METATYPE(LinphoneEnums::ChatRoomState)
Q_DECLARE_METATYPE(LinphoneEnums::ConferenceLayout)
Q_DECLARE_METATYPE(LinphoneEnums::ConferenceInfoState)
Q_DECLARE_METATYPE(LinphoneEnums::ConferenceSchedulerState)
Q_DECLARE_METATYPE(LinphoneEnums::EventLogType)
Q_DECLARE_METATYPE(LinphoneEnums::FriendCapability)
Q_DECLARE_METATYPE(LinphoneEnums::MediaEncryption)
Q_DECLARE_METATYPE(LinphoneEnums::ParticipantDeviceState)
Q_DECLARE_METATYPE(LinphoneEnums::RecorderState)
Q_DECLARE_METATYPE(LinphoneEnums::TunnelMode)
Q_DECLARE_METATYPE(LinphoneEnums::TransportType)

Q_DECLARE_METATYPE(std::shared_ptr<linphone::Call>)
Q_DECLARE_METATYPE(linphone::Call::State)
Q_DECLARE_METATYPE(std::shared_ptr<linphone::Core>)
Q_DECLARE_METATYPE(linphone::Config::ConfiguringState)
Q_DECLARE_METATYPE(std::string)
Q_DECLARE_METATYPE(linphone::GlobalState)
Q_DECLARE_METATYPE(std::shared_ptr<linphone::ChatRoom>)
Q_DECLARE_METATYPE(linphone::ChatRoom::State)
Q_DECLARE_METATYPE(linphone::RegistrationState)
Q_DECLARE_METATYPE(linphone::VersionUpdateCheckResult)
Q_DECLARE_METATYPE(std::shared_ptr<linphone::CallLog>)
Q_DECLARE_METATYPE(std::shared_ptr<const linphone::CallStats>)
Q_DECLARE_METATYPE(std::shared_ptr<linphone::EventLog>)
Q_DECLARE_METATYPE(std::shared_ptr<linphone::ChatMessage>)

#endif
