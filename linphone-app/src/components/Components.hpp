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

#ifndef COMPONENTS_H_
#define COMPONENTS_H_

#include "assistant/AssistantModel.hpp"
#include "authentication/AuthenticationNotifier.hpp"
#include "call/CallModel.hpp"
#include "calls/CallsListModel.hpp"
#include "calls/CallsListProxyModel.hpp"
#include "camera/Camera.hpp"
#include "camera/CameraPreview.hpp"
#include "chat/ChatProxyModel.hpp"
#include "codecs/AudioCodecsModel.hpp"
#include "codecs/VideoCodecsModel.hpp"
#include "conference/ConferenceAddModel.hpp"
#include "conference/ConferenceModel.hpp"
#include "contact/ContactModel.hpp"
#include "contact/VcardModel.hpp"
#include "contacts/ContactsListModel.hpp"
#include "contacts/ContactsListProxyModel.hpp"
#include "contacts/ContactsImporterModel.hpp"
#include "contacts/ContactsImporterPluginsManager.hpp"
#include "contacts/ContactsImporterListModel.hpp"
#include "contacts/ContactsImporterListProxyModel.hpp"
#include "core/CoreHandlers.hpp"
#include "core/CoreManager.hpp"
#include "file/FileDownloader.hpp"
#include "file/FileExtractor.hpp"
#include "history/HistoryProxyModel.hpp"
#include "ldap/LdapModel.hpp"
#include "ldap/LdapListModel.hpp"
#include "ldap/LdapProxyModel.hpp"
#include "notifier/Notifier.hpp"
#include "presence/OwnPresenceModel.hpp"
#include "settings/AccountSettingsModel.hpp"
#include "settings/SettingsModel.hpp"
#include "sip-addresses/SipAddressesModel.hpp"
#include "sip-addresses/SipAddressesProxyModel.hpp"
#include "sip-addresses/SearchSipAddressesModel.hpp"
#include "sound-player/SoundPlayer.hpp"
#include "telephone-numbers/TelephoneNumbersModel.hpp"
#include "timeline/TimelineModel.hpp"
#include "url-handlers/UrlHandlers.hpp"

#include "other/colors/Colors.hpp"
#include "other/clipboard/Clipboard.hpp"
#include "other/desktop-tools/DesktopTools.hpp"
#include "other/text-to-speech/TextToSpeech.hpp"
#include "other/units/Units.hpp"

#endif // COMPONENTS_H_
