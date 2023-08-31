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
#include "components/chat-events/ChatCallModel.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/chat-events/ChatNoticeModel.hpp"
#include "components/chat-reaction/ChatReactionProxyModel.hpp"
#include "chat-room/ChatRoomProxyModel.hpp"
#include "codecs/AudioCodecsModel.hpp"
#include "codecs/VideoCodecsModel.hpp"
#include "conference/ConferenceAddModel.hpp"
#include "conference/ConferenceModel.hpp"
#include "conference/ConferenceProxyModel.hpp"
#include "conferenceInfo/ConferenceInfoModel.hpp"
#include "conferenceInfo/ConferenceInfoProxyModel.hpp"
#include "conferenceScheduler/ConferenceScheduler.hpp"
#include "contact/ContactModel.hpp"
#include "contact/VcardModel.hpp"
#include "contacts/ContactsListModel.hpp"
#include "contacts/ContactsListProxyModel.hpp"
#include "contacts/ContactsImporterModel.hpp"
#include "contacts/ContactsImporterPluginsManager.hpp"
#include "contacts/ContactsImporterListModel.hpp"
#include "contacts/ContactsImporterListProxyModel.hpp"
#include "content/ContentListModel.hpp"
#include "content/ContentModel.hpp"
#include "content/ContentProxyModel.hpp"
#include "core/CoreHandlers.hpp"
#include "core/CoreManager.hpp"
#include "file/FileDownloader.hpp"
#include "file/FileExtractor.hpp"
#include "file/TemporaryFile.hpp"
#include "file/FileMediaModel.hpp"
#include "history/HistoryProxyModel.hpp"
#include "ldap/LdapModel.hpp"
#include "ldap/LdapListModel.hpp"
#include "ldap/LdapProxyModel.hpp"
#include "notifier/Notifier.hpp"
#include "participant/ParticipantListModel.hpp"
#include "participant/ParticipantModel.hpp"
#include "participant/ParticipantProxyModel.hpp"
#include "participant/ParticipantDeviceListModel.hpp"
#include "participant/ParticipantDeviceModel.hpp"
#include "participant/ParticipantDeviceProxyModel.hpp"
#include "participant-imdn/ParticipantImdnStateModel.hpp"
#include "participant-imdn/ParticipantImdnStateListModel.hpp"
#include "participant-imdn/ParticipantImdnStateProxyModel.hpp"
#include "presence/OwnPresenceModel.hpp"
#include "recorder/RecorderModel.hpp"
#include "recorder/RecorderManager.hpp"
#include "recorder/RecordingListModel.hpp"
#include "recorder/RecordingProxyModel.hpp"
#include "settings/AccountSettingsModel.hpp"
#include "settings/SettingsModel.hpp"
#include "search/SearchResultModel.hpp"
#include "sip-addresses/SipAddressesModel.hpp"
#include "sip-addresses/SipAddressesProxyModel.hpp"
#include "search/SearchSipAddressesModel.hpp"
#include "search/SearchSipAddressesProxyModel.hpp"
#include "sound-player/SoundPlayer.hpp"
#include "telephone-numbers/TelephoneNumbersModel.hpp"
#include "timeline/TimelineModel.hpp"
#include "timeline/TimelineProxyModel.hpp"
#include "timeline/TimelineListModel.hpp"
#include "tunnel/TunnelModel.hpp"
#include "tunnel/TunnelConfigModel.hpp"
#include "tunnel/TunnelConfigListModel.hpp"
#include "tunnel/TunnelConfigProxyModel.hpp"
#include "url-handlers/UrlHandlers.hpp"

#include "other/colors/ColorModel.hpp"
#include "other/colors/ColorListModel.hpp"
#include "other/colors/ColorProxyModel.hpp"
#include "other/colors/ImageColorsProxyModel.hpp"
#include "other/clipboard/Clipboard.hpp"
#include "other/desktop-tools/DesktopTools.hpp"
#include "other/images/ImageModel.hpp"
#include "other/images/ImageListModel.hpp"
#include "other/images/ImageProxyModel.hpp"
#include "other/text-to-speech/TextToSpeech.hpp"
#include "other/timeZone/TimeZoneModel.hpp"
#include "other/timeZone/TimeZoneListModel.hpp"
#include "other/timeZone/TimeZoneProxyModel.hpp"
#include "other/units/Units.hpp"

#endif // COMPONENTS_H_
