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
}


linphone::MediaEncryption LinphoneEnums::toLinphone(const LinphoneEnums::MediaEncryption& encryption){
	return static_cast<linphone::MediaEncryption>(encryption);
}
LinphoneEnums::MediaEncryption LinphoneEnums::fromLinphone(const linphone::MediaEncryption& encryption){
	return static_cast<LinphoneEnums::MediaEncryption>(encryption); 
}

linphone::FriendCapability LinphoneEnums::toLinphone(const LinphoneEnums::FriendCapability& capability){
	return static_cast<linphone::FriendCapability>(capability);
}
LinphoneEnums::FriendCapability LinphoneEnums::fromLinphone(const linphone::FriendCapability& capability){
	return static_cast<LinphoneEnums::FriendCapability>(capability); 
}

linphone::EventLog::Type LinphoneEnums::toLinphone(const LinphoneEnums::EventLogType& capability){
	return static_cast<linphone::EventLog::Type>(capability);
}
LinphoneEnums::EventLogType LinphoneEnums::fromLinphone(const linphone::EventLog::Type& capability){
	return static_cast<LinphoneEnums::EventLogType>(capability); 
}