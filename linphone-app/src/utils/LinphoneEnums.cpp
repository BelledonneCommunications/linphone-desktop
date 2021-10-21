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

#include <QString>

#include "LinphoneEnums.hpp"

// =============================================================================

void LinphoneEnums::registerMetaTypes(){
	qRegisterMetaType<LinphoneEnums::MediaEncryption>();
	qRegisterMetaType<LinphoneEnums::FriendCapability>();
	qRegisterMetaType<LinphoneEnums::EventLogType>();
	qRegisterMetaType<LinphoneEnums::ChatMessageState>();
}


linphone::MediaEncryption LinphoneEnums::toLinphone(const LinphoneEnums::MediaEncryption& data){
	return static_cast<linphone::MediaEncryption>(data);
}
LinphoneEnums::MediaEncryption LinphoneEnums::fromLinphone(const linphone::MediaEncryption& data){
	return static_cast<LinphoneEnums::MediaEncryption>(data); 
}

linphone::FriendCapability LinphoneEnums::toLinphone(const LinphoneEnums::FriendCapability& data){
	return static_cast<linphone::FriendCapability>(data);
}
LinphoneEnums::FriendCapability LinphoneEnums::fromLinphone(const linphone::FriendCapability& data){
	return static_cast<LinphoneEnums::FriendCapability>(data); 
}

linphone::EventLog::Type LinphoneEnums::toLinphone(const LinphoneEnums::EventLogType& data){
	return static_cast<linphone::EventLog::Type>(data);
}
LinphoneEnums::EventLogType LinphoneEnums::fromLinphone(const linphone::EventLog::Type& data){
	return static_cast<LinphoneEnums::EventLogType>(data); 
}

linphone::ChatMessage::State LinphoneEnums::toLinphone(const LinphoneEnums::ChatMessageState& data){
	return static_cast<linphone::ChatMessage::State>(data);
}
LinphoneEnums::ChatMessageState LinphoneEnums::fromLinphone(const linphone::ChatMessage::State& data){
	return static_cast<LinphoneEnums::ChatMessageState>(data); 
}

linphone::Call::Status LinphoneEnums::toLinphone(const LinphoneEnums::CallStatus& data){
	return static_cast<linphone::Call::Status>(data);
}
LinphoneEnums::CallStatus LinphoneEnums::fromLinphone(const linphone::Call::Status& data){
	return static_cast<LinphoneEnums::CallStatus>(data); 
}

linphone::Tunnel::Mode LinphoneEnums::toLinphone(const LinphoneEnums::TunnelMode& data){
	return static_cast<linphone::Tunnel::Mode>(data);
}
LinphoneEnums::TunnelMode LinphoneEnums::fromLinphone(const linphone::Tunnel::Mode& data){
	return static_cast<LinphoneEnums::TunnelMode>(data);
}
