/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#include "LinphoneEnums.hpp"
#include "Constants.hpp"

#include <QQmlEngine>
#include <QString>

// =============================================================================

void LinphoneEnums::registerMetaTypes() {
	qRegisterMetaType<LinphoneEnums::CallState>();
	qRegisterMetaType<LinphoneEnums::CallStatus>();
	qRegisterMetaType<LinphoneEnums::SecurityLevel>();
	qRegisterMetaType<LinphoneEnums::ChatMessageState>();
	qRegisterMetaType<LinphoneEnums::ChatRoomState>();
	qRegisterMetaType<LinphoneEnums::ConferenceLayout>();
	qRegisterMetaType<LinphoneEnums::ConferenceInfoState>();
	qRegisterMetaType<LinphoneEnums::ConferenceSchedulerState>();
	qRegisterMetaType<LinphoneEnums::EventLogType>();
	qRegisterMetaType<LinphoneEnums::FriendCapability>();
	qRegisterMetaType<LinphoneEnums::MediaEncryption>();
	qRegisterMetaType<LinphoneEnums::ParticipantDeviceState>();
	qRegisterMetaType<LinphoneEnums::RecorderState>();
	qRegisterMetaType<LinphoneEnums::RegistrationState>();
	qRegisterMetaType<LinphoneEnums::TunnelMode>();
	qRegisterMetaType<LinphoneEnums::TransportType>();
	qRegisterMetaType<LinphoneEnums::VideoSourceScreenSharingType>();
	qmlRegisterUncreatableMetaObject(LinphoneEnums::staticMetaObject, Constants::MainQmlUri, 1, 0, "LinphoneEnums",
	                                 "Only enums");
}

linphone::MediaEncryption LinphoneEnums::toLinphone(const LinphoneEnums::MediaEncryption &data) {
	return static_cast<linphone::MediaEncryption>(data);
}
LinphoneEnums::MediaEncryption LinphoneEnums::fromLinphone(const linphone::MediaEncryption &data) {
	return static_cast<LinphoneEnums::MediaEncryption>(data);
}
QString LinphoneEnums::toString(LinphoneEnums::MediaEncryption encryption) {
	switch (encryption) {
		case LinphoneEnums::MediaEncryption::Dtls:
			return QObject::tr("DTLS");
		case LinphoneEnums::MediaEncryption::None:
			return QObject::tr("None");
		case LinphoneEnums::MediaEncryption::Srtp:
			return QObject::tr("SRTP");
		case LinphoneEnums::MediaEncryption::Zrtp:
			//: "ZRTP - Post quantique"
			return QObject::tr("media_encryption_post_quantum");
		default:
			return QString();
	}
}

QVariantList LinphoneEnums::mediaEncryptionsToVariant(QList<LinphoneEnums::MediaEncryption> list) {
	QVariantList variantList;
	for (auto &item : list)
		variantList.append(LinphoneEnums::toVariant(item));
	return variantList;
}

QVariantMap LinphoneEnums::toVariant(LinphoneEnums::MediaEncryption encryption) {
	QVariantMap map;
	if (encryption == LinphoneEnums::MediaEncryption::None) {
		map.insert("id", QVariant::fromValue(encryption));
		map.insert("display_name", toString(encryption));
	} else if (encryption == LinphoneEnums::MediaEncryption::Srtp) {
		map.insert("id", QVariant::fromValue(encryption));
		map.insert("display_name", toString(encryption));
	} else if (encryption == LinphoneEnums::MediaEncryption::Zrtp) {
		map.insert("id", QVariant::fromValue(encryption));
		map.insert("display_name", toString(encryption));
	} else if (encryption == LinphoneEnums::MediaEncryption::Dtls) {
		map.insert("id", QVariant::fromValue(encryption));
		map.insert("display_name", toString(encryption));
	}
	return map;
}

linphone::Friend::Capability LinphoneEnums::toLinphone(const LinphoneEnums::FriendCapability &data) {
	return static_cast<linphone::Friend::Capability>(data);
}
LinphoneEnums::FriendCapability LinphoneEnums::fromLinphone(const linphone::Friend::Capability &data) {
	return static_cast<LinphoneEnums::FriendCapability>(data);
}

linphone::EventLog::Type LinphoneEnums::toLinphone(const LinphoneEnums::EventLogType &data) {
	return static_cast<linphone::EventLog::Type>(data);
}
LinphoneEnums::EventLogType LinphoneEnums::fromLinphone(const linphone::EventLog::Type &data) {
	return static_cast<LinphoneEnums::EventLogType>(data);
}

linphone::ChatMessage::State LinphoneEnums::toLinphone(const LinphoneEnums::ChatMessageState &data) {
	return static_cast<linphone::ChatMessage::State>(data);
}
LinphoneEnums::ChatMessageState LinphoneEnums::fromLinphone(const linphone::ChatMessage::State &data) {
	return static_cast<LinphoneEnums::ChatMessageState>(data);
}

linphone::ChatRoom::State LinphoneEnums::toLinphone(const LinphoneEnums::ChatRoomState &data) {
	return static_cast<linphone::ChatRoom::State>(data);
}

LinphoneEnums::ChatRoomState LinphoneEnums::fromLinphone(const linphone::ChatRoom::State &data) {
	return static_cast<LinphoneEnums::ChatRoomState>(data);
}

linphone::Call::State LinphoneEnums::toLinphone(const LinphoneEnums::CallState &data) {
	return static_cast<linphone::Call::State>(data);
}
LinphoneEnums::CallState LinphoneEnums::fromLinphone(const linphone::Call::State &data) {
	return static_cast<LinphoneEnums::CallState>(data);
}

linphone::Call::Status LinphoneEnums::toLinphone(const LinphoneEnums::CallStatus &data) {
	return static_cast<linphone::Call::Status>(data);
}
LinphoneEnums::CallStatus LinphoneEnums::fromLinphone(const linphone::Call::Status &data) {
	return static_cast<LinphoneEnums::CallStatus>(data);
}

QString LinphoneEnums::toString(const LinphoneEnums::CallStatus &data) {
	switch (data) {
		case LinphoneEnums::CallStatus::Declined:
			return "Declined";
		case LinphoneEnums::CallStatus::Missed:
			return "Missed";
		case LinphoneEnums::CallStatus::Success:
			return "Success";
		case LinphoneEnums::CallStatus::Aborted:
			return "Aborted";
		case LinphoneEnums::CallStatus::EarlyAborted:
			return "EarlyAborted";
		case LinphoneEnums::CallStatus::AcceptedElsewhere:
			return "AcceptedElsewhere";
		case LinphoneEnums::CallStatus::DeclinedElsewhere:
			return "DeclinedElsewhere";
		default:
			return QString();
	}
}

linphone::SecurityLevel LinphoneEnums::toLinphone(const LinphoneEnums::SecurityLevel &level) {
	return static_cast<linphone::SecurityLevel>(level);
}

LinphoneEnums::SecurityLevel LinphoneEnums::fromLinphone(const linphone::SecurityLevel &level) {
	return static_cast<LinphoneEnums::SecurityLevel>(level);
}

LinphoneEnums::CallDir LinphoneEnums::fromLinphone(const linphone::Call::Dir &data) {
	return static_cast<LinphoneEnums::CallDir>(data);
}

linphone::Call::Dir LinphoneEnums::toLinphone(const LinphoneEnums::CallDir &data) {
	return static_cast<linphone::Call::Dir>(data);
}

QString LinphoneEnums::toString(const LinphoneEnums::CallDir &data) {
	switch (data) {
		case LinphoneEnums::CallDir::Incoming:
			//: "Entrant"
			return QObject::tr("incoming");
		case LinphoneEnums::CallDir::Outgoing:
			//: "Sortant"
			return QObject::tr("outgoing");
		default:
			return QString();
	}
}

LinphoneEnums::Reason LinphoneEnums::fromLinphone(const linphone::Reason &data) {
	return static_cast<LinphoneEnums::Reason>(data);
}

linphone::Reason LinphoneEnums::toLinphone(const LinphoneEnums::Reason &data) {
	return static_cast<linphone::Reason>(data);
}

linphone::Conference::Layout LinphoneEnums::toLinphone(const LinphoneEnums::ConferenceLayout &layout) {
	if (layout != LinphoneEnums::ConferenceLayout::AudioOnly) return static_cast<linphone::Conference::Layout>(layout);
	else return linphone::Conference::Layout::Grid; // Audio Only mode
}

LinphoneEnums::ConferenceLayout LinphoneEnums::fromLinphone(const linphone::Conference::Layout &layout) {
	return static_cast<LinphoneEnums::ConferenceLayout>(layout);
}

QString LinphoneEnums::toString(LinphoneEnums::ConferenceLayout layout) {
	//: "Participant actif"
	if (layout == LinphoneEnums::ConferenceLayout::ActiveSpeaker) return QObject::tr("conference_layout_active_speaker");
	//: "Mosaïque"
	else if (layout == LinphoneEnums::ConferenceLayout::Grid) return QObject::tr("conference_layout_grid");
	//: "Audio uniquement"
	else return QObject::tr("conference_layout_audio_only");
}

QVariantList LinphoneEnums::conferenceLayoutsToVariant(QList<LinphoneEnums::ConferenceLayout> list) {
	QVariantList variantList;
	for (auto &item : list)
		variantList.append(LinphoneEnums::toVariant(item));
	return variantList;
}

QVariantMap LinphoneEnums::toVariant(LinphoneEnums::ConferenceLayout layout) {
	QVariantMap map;
	if (layout == LinphoneEnums::ConferenceLayout::ActiveSpeaker) {
		map.insert("id", QVariant::fromValue(layout));
		map.insert("display_name", toString(layout));
	} else {
		map.insert("id", QVariant::fromValue(layout));
		map.insert("display_name", toString(layout));
	}
	return map;
}

linphone::ConferenceInfo::State LinphoneEnums::toLinphone(const LinphoneEnums::ConferenceInfoState &state) {
	return static_cast<linphone::ConferenceInfo::State>(state);
}

LinphoneEnums::ConferenceInfoState LinphoneEnums::fromLinphone(const linphone::ConferenceInfo::State &state) {
	return static_cast<LinphoneEnums::ConferenceInfoState>(state);
}

linphone::ConferenceScheduler::State LinphoneEnums::toLinphone(const LinphoneEnums::ConferenceSchedulerState &state) {
	return static_cast<linphone::ConferenceScheduler::State>(state);
}

LinphoneEnums::ConferenceSchedulerState LinphoneEnums::fromLinphone(const linphone::ConferenceScheduler::State &state) {
	return static_cast<LinphoneEnums::ConferenceSchedulerState>(state);
}

linphone::ConsolidatedPresence LinphoneEnums::toLinphone(const LinphoneEnums::ConsolidatedPresence &data) {
	return static_cast<linphone::ConsolidatedPresence>(data);
}
LinphoneEnums::ConsolidatedPresence LinphoneEnums::fromLinphone(const linphone::ConsolidatedPresence &data) {
	return static_cast<LinphoneEnums::ConsolidatedPresence>(data);
}

linphone::MagicSearch::Aggregation LinphoneEnums::toLinphone(const LinphoneEnums::MagicSearchAggregation &data) {
	return static_cast<linphone::MagicSearch::Aggregation>(data);
}
LinphoneEnums::MagicSearchAggregation LinphoneEnums::fromLinphone(const linphone::MagicSearch::Aggregation &data) {
	return static_cast<LinphoneEnums::MagicSearchAggregation>(data);
}

linphone::MagicSearch::Source LinphoneEnums::toLinphone(const LinphoneEnums::MagicSearchSource &data) {
	return static_cast<linphone::MagicSearch::Source>(data);
}
LinphoneEnums::MagicSearchSource LinphoneEnums::fromLinphone(const linphone::MagicSearch::Source &data) {
	return static_cast<LinphoneEnums::MagicSearchSource>(data);
}

linphone::LogLevel LinphoneEnums::toLinphone(const QtMsgType &data) {
	switch (data) {
		case QtDebugMsg:
			return linphone::LogLevel::Debug;
		case QtWarningMsg:
			return linphone::LogLevel::Warning;
		case QtCriticalMsg:
			return linphone::LogLevel::Error;
		case QtFatalMsg:
			return linphone::LogLevel::Fatal;
		case QtInfoMsg:
			return linphone::LogLevel::Message;
		default:
			return linphone::LogLevel::Trace;
	}
}

QtMsgType LinphoneEnums::fromLinphone(const linphone::LogLevel &data) {
	switch (data) {
		case linphone::LogLevel::Debug:
			return QtDebugMsg;
		case linphone::LogLevel::Trace:
			return QtInfoMsg;
		case linphone::LogLevel::Message:
			return QtInfoMsg;
		case linphone::LogLevel::Warning:
			return QtWarningMsg;
		case linphone::LogLevel::Error:
			return QtCriticalMsg;
		case linphone::LogLevel::Fatal:
			return QtFatalMsg;
		default:
			return QtInfoMsg;
	}
}

linphone::ParticipantDevice::State LinphoneEnums::toLinphone(const LinphoneEnums::ParticipantDeviceState &state) {
	return static_cast<linphone::ParticipantDevice::State>(state);
}

LinphoneEnums::ParticipantDeviceState LinphoneEnums::fromLinphone(const linphone::ParticipantDevice::State &state) {
	return static_cast<LinphoneEnums::ParticipantDeviceState>(state);
}

linphone::Participant::Role LinphoneEnums::toLinphone(const LinphoneEnums::ParticipantRole &role) {
	return static_cast<linphone::Participant::Role>(role);
}

LinphoneEnums::ParticipantRole LinphoneEnums::fromLinphone(const linphone::Participant::Role &role) {
	return static_cast<LinphoneEnums::ParticipantRole>(role);
}

linphone::Tunnel::Mode LinphoneEnums::toLinphone(const LinphoneEnums::TunnelMode &data) {
	return static_cast<linphone::Tunnel::Mode>(data);
}
LinphoneEnums::TunnelMode LinphoneEnums::fromLinphone(const linphone::Tunnel::Mode &data) {
	return static_cast<LinphoneEnums::TunnelMode>(data);
}

linphone::Recorder::State LinphoneEnums::toLinphone(const LinphoneEnums::RecorderState &data) {
	return static_cast<linphone::Recorder::State>(data);
}
LinphoneEnums::RecorderState LinphoneEnums::fromLinphone(const linphone::Recorder::State &data) {
	return static_cast<LinphoneEnums::RecorderState>(data);
}

linphone::RegistrationState LinphoneEnums::toLinphone(const LinphoneEnums::RegistrationState &data) {
	return static_cast<linphone::RegistrationState>(data);
}

LinphoneEnums::RegistrationState LinphoneEnums::fromLinphone(const linphone::RegistrationState &data) {
	return static_cast<LinphoneEnums::RegistrationState>(data);
}

linphone::TransportType LinphoneEnums::toLinphone(const LinphoneEnums::TransportType &type) {
	return static_cast<linphone::TransportType>(type);
}
LinphoneEnums::TransportType LinphoneEnums::fromLinphone(const linphone::TransportType &type) {
	return static_cast<LinphoneEnums::TransportType>(type);
}
QString LinphoneEnums::toString(const LinphoneEnums::TransportType &type) {
	switch (type) {
		case TransportType::Tcp:
			return "TCP";
		case TransportType::Udp:
			return "UDP";
		case TransportType::Tls:
			return "TLS";
		case TransportType::Dtls:
			return "DTLS";
		default:
			return QString();
	}
}
void LinphoneEnums::fromString(const QString &transportType, LinphoneEnums::TransportType *transport) {
	if (transportType.toUpper() == QLatin1String("TCP")) *transport = TransportType::Tcp;
	else if (transportType.toUpper() == QLatin1String("UDP")) *transport = TransportType::Udp;
	else if (transportType.toUpper() == QLatin1String("TLS")) *transport = TransportType::Tls;
	else if (transportType.toUpper() == QLatin1String("DTLS")) *transport = TransportType::Dtls;
	else *transport = TransportType::Udp;
}

linphone::VideoSourceScreenSharingType
LinphoneEnums::toLinphone(const LinphoneEnums::VideoSourceScreenSharingType &type) {
	return static_cast<linphone::VideoSourceScreenSharingType>(type);
}
LinphoneEnums::VideoSourceScreenSharingType
LinphoneEnums::fromLinphone(const linphone::VideoSourceScreenSharingType &type) {
	return static_cast<LinphoneEnums::VideoSourceScreenSharingType>(type);
}
