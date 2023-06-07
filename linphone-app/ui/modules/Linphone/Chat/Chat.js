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
.import UtilsCpp 1.0 as UtilsCpp

// =============================================================================

function initView () {
	chat.bindToEnd = true
	chat.positionViewAtEnd()
}

function getComponentFromEntry (chatEntry) {
	if(!chatEntry) return ''
	if (chatEntry.type === Linphone.ChatRoomModel.CallEntry) {
		return 'Event.qml'
	}
	
	if (chatEntry.type === Linphone.ChatRoomModel.NoticeEntry) {
		return 'Notice.qml'
	}
	
	return chatEntry.isOutgoing ? 'OutgoingMessage.qml' : 'IncomingMessage.qml'
}

function handleFilesDropped (files) {
	chat.bindToEnd = true
	files.forEach(chatMessagePreview.addFile)
}

function handleMoreEntriesLoaded (n) {
	chat.positionViewAtIndex(n - 1, QtQuick.ListView.Beginning)
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
	if(container.proxyModel)
		container.proxyModel.sendMessage(text)
}
