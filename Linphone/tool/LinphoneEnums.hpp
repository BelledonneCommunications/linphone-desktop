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
Q_CLASSINFO("RegisterEnumClassesUnscoped", "false") // Avoid name clashes

void registerMetaTypes();

enum class MediaEncryption {
	None = int(linphone::MediaEncryption::None),
	Dtls = int(linphone::MediaEncryption::DTLS),
	Srtp = int(linphone::MediaEncryption::SRTP),
	Zrtp = int(linphone::MediaEncryption::ZRTP)
};
Q_ENUM_NS(MediaEncryption)

linphone::MediaEncryption toLinphone(const LinphoneEnums::MediaEncryption &encryption);
LinphoneEnums::MediaEncryption fromLinphone(const linphone::MediaEncryption &encryption);

enum class FriendCapability {
	None = int(linphone::Friend::Capability::None),
	GroupChat = int(linphone::Friend::Capability::GroupChat),
	LimeX3Dh = int(linphone::Friend::Capability::LimeX3Dh),
	EphemeralMessages = int(linphone::Friend::Capability::EphemeralMessages)
};
Q_ENUM_NS(FriendCapability)

linphone::Friend::Capability toLinphone(const LinphoneEnums::FriendCapability &capability);
LinphoneEnums::FriendCapability fromLinphone(const linphone::Friend::Capability &capability);

enum class EventLogType {
	None = int(linphone::EventLog::Type::None),
	ConferenceCreated = int(linphone::EventLog::Type::ConferenceCreated),
	ConferenceTerminated = int(linphone::EventLog::Type::ConferenceTerminated),
	ConferenceCallStarted = int(linphone::EventLog::Type::ConferenceCallStarted),
	ConferenceCallEnded = int(linphone::EventLog::Type::ConferenceCallEnded),
	ConferenceChatMessage = int(linphone::EventLog::Type::ConferenceChatMessage),
	ConferenceParticipantAdded = int(linphone::EventLog::Type::ConferenceParticipantAdded),
	ConferenceParticipantRemoved = int(linphone::EventLog::Type::ConferenceParticipantRemoved),
	ConferenceParticipantSetAdmin = int(linphone::EventLog::Type::ConferenceParticipantSetAdmin),
	ConferenceParticipantUnsetAdmin = int(linphone::EventLog::Type::ConferenceParticipantUnsetAdmin),
	ConferenceParticipantDeviceAdded = int(linphone::EventLog::Type::ConferenceParticipantDeviceAdded),
	ConferenceParticipantDeviceRemoved = int(linphone::EventLog::Type::ConferenceParticipantDeviceRemoved),
	ConferenceParticipantDeviceMediaAvailabilityChanged =
	    int(linphone::EventLog::Type::ConferenceParticipantDeviceMediaAvailabilityChanged),
	ConferenceSubjectChanged = int(linphone::EventLog::Type::ConferenceSubjectChanged),
	ConferenceAvailableMediaChanged = int(linphone::EventLog::Type::ConferenceAvailableMediaChanged),
	ConferenceSecurityEvent = int(linphone::EventLog::Type::ConferenceSecurityEvent),
	ConferenceEphemeralMessageLifetimeChanged =
	    int(linphone::EventLog::Type::ConferenceEphemeralMessageLifetimeChanged),
	ConferenceEphemeralMessageEnabled = int(linphone::EventLog::Type::ConferenceEphemeralMessageEnabled),
	ConferenceEphemeralMessageDisabled = int(linphone::EventLog::Type::ConferenceEphemeralMessageDisabled)
};
Q_ENUM_NS(EventLogType)

linphone::EventLog::Type toLinphone(const LinphoneEnums::EventLogType &capability);
LinphoneEnums::EventLogType fromLinphone(const linphone::EventLog::Type &data);

enum class ChatMessageState {
	StateIdle = int(linphone::ChatMessage::State::Idle),
	StateInProgress = int(linphone::ChatMessage::State::InProgress),
	StateDelivered = int(linphone::ChatMessage::State::Delivered),
	StateNotDelivered = int(linphone::ChatMessage::State::NotDelivered),
	StateFileTransferError = int(linphone::ChatMessage::State::FileTransferError),
	StateFileTransferDone = int(linphone::ChatMessage::State::FileTransferDone),
	StateDeliveredToUser = int(linphone::ChatMessage::State::DeliveredToUser),
	StateDisplayed = int(linphone::ChatMessage::State::Displayed),
	StateFileTransferInProgress = int(linphone::ChatMessage::State::FileTransferInProgress)
};
Q_ENUM_NS(ChatMessageState)

linphone::ChatMessage::State toLinphone(const LinphoneEnums::ChatMessageState &data);
LinphoneEnums::ChatMessageState fromLinphone(const linphone::ChatMessage::State &data);

enum class ChatRoomState {
	None = int(linphone::ChatRoom::State::None),
	Instantiated = int(linphone::ChatRoom::State::Instantiated),
	CreationPending = int(linphone::ChatRoom::State::CreationPending),
	Created = int(linphone::ChatRoom::State::Created),
	CreationFailed = int(linphone::ChatRoom::State::CreationFailed),
	TerminationPending = int(linphone::ChatRoom::State::TerminationPending),
	Terminated = int(linphone::ChatRoom::State::Terminated),
	TerminationFailed = int(linphone::ChatRoom::State::TerminationFailed),
	Deleted = int(linphone::ChatRoom::State::Deleted),
};
Q_ENUM_NS(ChatRoomState)

linphone::ChatRoom::State toLinphone(const LinphoneEnums::ChatRoomState &data);
LinphoneEnums::ChatRoomState fromLinphone(const linphone::ChatRoom::State &data);

enum class CallState {
	Idle = int(linphone::Call::State::Idle),
	IncomingReceived = int(linphone::Call::State::IncomingReceived),
	PushIncomingReceived = int(linphone::Call::State::PushIncomingReceived),
	OutgoingInit = int(linphone::Call::State::OutgoingInit),
	OutgoingProgress = int(linphone::Call::State::OutgoingProgress),
	OutgoingRinging = int(linphone::Call::State::OutgoingRinging),
	OutgoingEarlyMedia = int(linphone::Call::State::OutgoingEarlyMedia),
	Connected = int(linphone::Call::State::Connected),
	StreamsRunning = int(linphone::Call::State::StreamsRunning),
	Pausing = int(linphone::Call::State::Pausing),
	Paused = int(linphone::Call::State::Paused),
	Resuming = int(linphone::Call::State::Resuming),
	Referred = int(linphone::Call::State::Referred),
	Error = int(linphone::Call::State::Error),
	End = int(linphone::Call::State::End),
	PausedByRemote = int(linphone::Call::State::PausedByRemote),
	UpdatedByRemote = int(linphone::Call::State::UpdatedByRemote),
	IncomingEarlyMedia = int(linphone::Call::State::IncomingEarlyMedia),
	Updating = int(linphone::Call::State::Updating),
	Released = int(linphone::Call::State::Released),
	EarlyUpdatedByRemote = int(linphone::Call::State::EarlyUpdatedByRemote),
	EarlyUpdating = int(linphone::Call::State::EarlyUpdating)
};
Q_ENUM_NS(CallState)
linphone::Call::State toLinphone(const LinphoneEnums::CallState &data);
LinphoneEnums::CallState fromLinphone(const linphone::Call::State &data);

enum class CallStatus {
	Declined = int(linphone::Call::Status::Declined),
	Missed = int(linphone::Call::Status::Missed),
	Success = int(linphone::Call::Status::Success),
	Aborted = int(linphone::Call::Status::Aborted),
	EarlyAborted = int(linphone::Call::Status::EarlyAborted),
	AcceptedElsewhere = int(linphone::Call::Status::AcceptedElsewhere),
	DeclinedElsewhere = int(linphone::Call::Status::DeclinedElsewhere)
};
Q_ENUM_NS(CallStatus)

linphone::Call::Status toLinphone(const LinphoneEnums::CallStatus &data);
LinphoneEnums::CallStatus fromLinphone(const linphone::Call::Status &data);
QString toString(const LinphoneEnums::CallStatus &data);

enum class ConferenceLayout {
	Grid = int(linphone::Conference::Layout::Grid),
	ActiveSpeaker = int(linphone::Conference::Layout::ActiveSpeaker),
	AudioOnly = Grid + ActiveSpeaker + 1,
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

enum class ConferenceSchedulerState {
	AllocationPending = int(linphone::ConferenceScheduler::State::AllocationPending),
	Error = int(linphone::ConferenceScheduler::State::Error),
	Idle = int(linphone::ConferenceScheduler::State::Idle),
	Ready = int(linphone::ConferenceScheduler::State::Ready),
	Updating = int(linphone::ConferenceScheduler::State::Updating)
};
Q_ENUM_NS(ConferenceSchedulerState)

linphone::ConferenceScheduler::State toLinphone(const LinphoneEnums::ConferenceSchedulerState &state);
LinphoneEnums::ConferenceSchedulerState fromLinphone(const linphone::ConferenceScheduler::State &state);

linphone::LogLevel toLinphone(const QtMsgType &data);
QtMsgType fromLinphone(const linphone::LogLevel &data);

enum class ParticipantDeviceState {
	Joining = int(linphone::ParticipantDevice::State::Joining),
	Present = int(linphone::ParticipantDevice::State::Present),
	Leaving = int(linphone::ParticipantDevice::State::Leaving),
	Left = int(linphone::ParticipantDevice::State::Left),
	ScheduledForJoining = int(linphone::ParticipantDevice::State::ScheduledForJoining),
	ScheduledForLeaving = int(linphone::ParticipantDevice::State::ScheduledForLeaving),
	OnHold = int(linphone::ParticipantDevice::State::OnHold),
	Alerting = int(linphone::ParticipantDevice::State::Alerting),
	MutedByFocus = int(linphone::ParticipantDevice::State::MutedByFocus),

};
Q_ENUM_NS(ParticipantDeviceState)

linphone::ParticipantDevice::State toLinphone(const LinphoneEnums::ParticipantDeviceState &state);
LinphoneEnums::ParticipantDeviceState fromLinphone(const linphone::ParticipantDevice::State &state);

enum class RegistrationState {
	None = int(linphone::RegistrationState::None),
	Progress = int(linphone::RegistrationState::Progress),
	Ok = int(linphone::RegistrationState::Ok),
	Cleared = int(linphone::RegistrationState::Cleared),
	Failed = int(linphone::RegistrationState::Failed),
	Refreshing = int(linphone::RegistrationState::Refreshing)
};
Q_ENUM_NS(RegistrationState)

linphone::RegistrationState toLinphone(const LinphoneEnums::RegistrationState &data);
LinphoneEnums::RegistrationState fromLinphone(const linphone::RegistrationState &data);

enum class TunnelMode {
	Disable = int(linphone::Tunnel::Mode::Disable),
	Enable = int(linphone::Tunnel::Mode::Enable),
	Auto = int(linphone::Tunnel::Mode::Auto)
};
Q_ENUM_NS(TunnelMode)

linphone::Tunnel::Mode toLinphone(const LinphoneEnums::TunnelMode &mode);
LinphoneEnums::TunnelMode fromLinphone(const linphone::Tunnel::Mode &mode);

enum class RecorderState {
	Closed = int(linphone::Recorder::State::Closed),
	Paused = int(linphone::Recorder::State::Paused),
	Running = int(linphone::Recorder::State::Running)
};
Q_ENUM_NS(RecorderState)

linphone::Recorder::State toLinphone(const LinphoneEnums::RecorderState &state);
LinphoneEnums::RecorderState fromLinphone(const linphone::Recorder::State &state);

enum class TransportType {
	Dtls = int(linphone::TransportType::Dtls),
	Tcp = int(linphone::TransportType::Tcp),
	Tls = int(linphone::TransportType::Tls),
	Udp = int(linphone::TransportType::Udp)
};
Q_ENUM_NS(TransportType)

linphone::TransportType toLinphone(const LinphoneEnums::TransportType &type);
LinphoneEnums::TransportType fromLinphone(const linphone::TransportType &type);
QString toString(const LinphoneEnums::TransportType &type);
void fromString(const QString &transportType, LinphoneEnums::TransportType *transport);
} // namespace LinphoneEnums
/*
Q_DECLARE_METATYPE(LinphoneEnums::CallState)
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
Q_DECLARE_METATYPE(LinphoneEnums::RegistrationState)
Q_DECLARE_METATYPE(LinphoneEnums::TunnelMode)
Q_DECLARE_METATYPE(LinphoneEnums::TransportType)
*/
#endif
