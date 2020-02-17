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
// `Timeline.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

// =============================================================================

function setSelectedEntry (peerAddress, localAddress) {
  if (localAddress != null && localAddress !== Linphone.AccountSettingsModel.sipAddress) {
    resetSelectedEntry()
    return
  }

  var model = timeline.model
  var n = view.count

  timeline._selectedSipAddress = peerAddress

  for (var i = 0; i < n; i++) {
    if (peerAddress === model.data(model.index(i, 0)).sipAddress) {
      view.currentIndex = i
      return
    }
  }
}

function resetSelectedEntry () {
  view.currentIndex = -1
  timeline._selectedSipAddress = ''
}

// -----------------------------------------------------------------------------

function handleDataChanged (topLeft, bottomRight, roles) {
  var index = view.currentIndex
  var model = timeline.model
  var sipAddress = timeline._selectedSipAddress

  if (
    index !== -1 &&
    sipAddress !== model.data(model.index(index, 0)).sipAddress
  ) {
    setSelectedEntry(sipAddress)
  }
}

function handleRowsAboutToBeRemoved (parent, first, last) {
  var index = view.currentIndex
  if (index >= first && index <= last) {
    view.currentIndex = -1
  }
}

function handleCountChanged (_) {
  var sipAddress = timeline._selectedSipAddress
  if (sipAddress.length > 0) {
    setSelectedEntry(sipAddress)
  }
}
