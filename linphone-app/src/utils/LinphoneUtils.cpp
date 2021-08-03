/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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
#include <QQmlEngine>

#include "LinphoneUtils.hpp"
#include "utils/Utils.hpp"
#include "components/core/CoreManager.hpp"

#include "components/contacts/ContactsListModel.hpp"
#include "components/contact/ContactModel.hpp"

// =============================================================================

linphone::TransportType LinphoneUtils::stringToTransportType (const QString &transport) {
  if (transport == QLatin1String("TCP"))
    return linphone::TransportType::Tcp;
  if (transport == QLatin1String("UDP"))
    return linphone::TransportType::Udp;
  if (transport == QLatin1String("TLS"))
    return linphone::TransportType::Tls;

  return linphone::TransportType::Dtls;
}

std::shared_ptr<linphone::Address> LinphoneUtils::interpretUrl(const QString& address){
	return CoreManager::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(address));
}
/*
bool LinphoneUtils::hasCapability(const QString& address, const LinphoneEnums::FriendCapability& capability){
	auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(address);
	if(contact)
		return contact->hasCapability(capability);
	else
		return false;
}
*/