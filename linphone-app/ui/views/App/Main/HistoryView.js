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
      historyProxyModel.removeAllEntries()
    }
  })
}

function getAvatar () {
  var contact = historyView._sipAddressObserver.contact
  return contact ? contact.vcard.avatar : ''
}

function getEditIcon () {
  return historyView._sipAddressObserver && historyView._sipAddressObserver.contact ? 'contact_edit' : 'contact_add'
}

function getEditTooltipText() {
    return historyView._sipAddressObserver && historyView._sipAddressObserver.contact ? qsTr('tooltipContactEdit') : qsTr('tooltipContactAdd')
}

function getUsername () {
  return LinphoneUtils.getContactUsername(historyView._sipAddressObserver)
}

function updateHistoryFilter (button) {
  var HistoryModel = Linphone.HistoryModel
  if (button === 0) {
    historyProxyModel.setEntryTypeFilter(HistoryModel.GenericEntry)
  } else if (button === 1) {
    historyProxyModel.setEntryTypeFilter(HistoryModel.CallEntry)
  }
}
