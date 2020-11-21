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
// `Chat.qml` Logic.
// =============================================================================

.import QtQuick 2.7 as QtQuick

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/LinphoneUtils/linphone-utils.js' as LinphoneUtils

// =============================================================================

function initView () {
  chat.tryToLoadMoreEntries = false
  chat.bindToEnd = true
}

function loadMoreEntries () {
  if (chat.atYBeginning && !chat.tryToLoadMoreEntries) {
    chat.tryToLoadMoreEntries = true
    chat.positionViewAtBeginning()
    container.proxyModel.loadMoreEntries()
  }
}

function getComponentFromEntry (chatEntry) {
  if (chatEntry.fileName) {
    return 'FileMessage.qml'
  }

  if (chatEntry.type === Linphone.ChatModel.CallEntry) {
    return 'Event.qml'
  }

  return chatEntry.isOutgoing ? 'OutgoingMessage.qml' : 'IncomingMessage.qml'
}

function getIsComposingMessage () {
  if (!container.proxyModel.isRemoteComposing || !Linphone.SettingsModel.chatEnabled) {
    return ''
  }

  var sipAddressObserver = chat.sipAddressObserver
  return qsTr('isComposing').replace(
    '%1',
    LinphoneUtils.getContactUsername(sipAddressObserver)
  )
}

function handleFilesDropped (files) {
  chat.bindToEnd = true
  files.forEach(container.proxyModel.sendFileMessage)
}

function handleMoreEntriesLoaded (n) {
  chat.positionViewAtIndex(n - 1, QtQuick.ListView.Beginning)
  chat.tryToLoadMoreEntries = false
}

function handleMovementEnded () {
  if (chat.atYEnd) {
    chat.bindToEnd = true
  }
}

function handleMovementStarted () {
  chat.bindToEnd = false
}

function handleTextChanged (text) {
  container.proxyModel.compose(text)
}

function sendMessage (text) {
  textArea.text = ''
  chat.bindToEnd = true
  container.proxyModel.sendMessage(text)
}
