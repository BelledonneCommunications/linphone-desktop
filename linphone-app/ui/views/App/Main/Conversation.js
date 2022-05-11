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
// =============================================================================
// `Conversation.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone
.import UtilsCpp 1.0 as UtilsCpp

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function removeAllEntries () {
  window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('removeAllEntriesDescription'),
  }, function (status) {
    if (status) {
      chatRoomProxyModel.removeAllEntries()
    }
  })
}

function getAvatar () {
  var contact = conversation._sipAddressObserver ? conversation._sipAddressObserver.contact : null
  return contact ? contact.vcard.avatar : ''
}

function getEditTooltipText() {
    return conversation._sipAddressObserver && conversation._sipAddressObserver.contact ? qsTr('tooltipContactEdit') : qsTr('tooltipContactAdd')
}

function updateChatFilter (button) {
  var ChatRoomModel = Linphone.ChatRoomModel
  if (button === 0) {
    chatRoomProxyModel.setEntryTypeFilter(ChatRoomModel.GenericEntry)
  } else if (button === 1) {
    chatRoomProxyModel.setEntryTypeFilter(ChatRoomModel.CallEntry)
  } else {
    chatRoomProxyModel.setEntryTypeFilter(ChatRoomModel.MessageEntry)
  }
}

function openConferenceManager (params) {
  var App = Linphone.App
  var callsWindow = App.getCallsWindow()

  App.smartShowWindow(callsWindow)
  callsWindow.openConferenceManager(params)
}
