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
  history.tryToLoadMoreEntries = false
  history.bindToEnd = true
}

function loadMoreEntries () {
  if (history.atYBeginning && !history.tryToLoadMoreEntries) {
    history.tryToLoadMoreEntries = true
    history.positionViewAtBeginning()
    container.proxyModel.loadMoreEntries()
  }
}

function getComponentFromEntry (historyEntry) {

  if (historyEntry.type === Linphone.HistoryModel.CallEntry) {
    return 'Event.qml'
  }

  return ''
}

function handleMoreEntriesLoaded (n) {
  history.positionViewAtIndex(n - 1, QtQuick.ListView.Beginning)
  history.tryToLoadMoreEntries = false
}

function handleMovementEnded () {
  if (history.atYEnd) {
    history.bindToEnd = true
  }
}

function handleMovementStarted () {
  history.bindToEnd = false
}
