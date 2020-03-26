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

.import 'qrc:/ui/scripts/LinphoneUtils/linphone-utils.js' as LinphoneUtils
.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function removeAllEntries () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('removeAllEntriesDescription'),
  }, function (status) {
    if (status) {
      chatProxyModel.removeAllEntries()
    }
  })
}

function getAvatar () {
  var contact = conversation._sipAddressObserver.contact
  return contact ? contact.vcard.avatar : ''
}

function getEditIcon () {
  return conversation._sipAddressObserver.contact ? 'contact_edit' : 'contact_add'
}

function getEditTooltipText() {
    return conversation._sipAddressObserver.contact ? qsTr('tooltipContactEdit') : qsTr('tooltipContactAdd')
}

function getUsername () {
  return LinphoneUtils.getContactUsername(conversation._sipAddressObserver)
}

function updateChatFilter (button) {
  var ChatModel = Linphone.ChatModel
  if (button === 0) {
    chatProxyModel.setEntryTypeFilter(ChatModel.GenericEntry)
  } else if (button === 1) {
    chatProxyModel.setEntryTypeFilter(ChatModel.CallEntry)
  } else {
    chatProxyModel.setEntryTypeFilter(ChatModel.MessageEntry)
  }
}
