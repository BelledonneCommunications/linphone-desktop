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
// `MainWindow.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone
.import QtQuick.Window 2.2 as Window

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function handleActiveFocusItemChanged (activeFocusItem) {
  var smartSearchBar = window._smartSearchBar

  if (activeFocusItem == null && smartSearchBar) {
    smartSearchBar.closeMenu()
  }
}

function handleClosing (close) {
  if (Linphone.SettingsModel.exitOnClose) {
    Qt.quit()
    return
  }

  if (Qt.platform.os === 'osx') {
    close.accepted = false
    window.showMinimized()
  }
}

// -----------------------------------------------------------------------------

function lockView (info) {
  window._lockedInfo = info
}

function unlockView () {
  window._lockedInfo = undefined
}

function setView (view, props) {
  function apply (view, props) {
    Linphone.App.smartShowWindow(window)

    var item = mainLoader.item

    updateSelectedEntry(view, props)
    window._currentView = view
    item.contentLoader.setSource(view + '.qml', props || {})
  }

  var lockedInfo = window._lockedInfo
  if (!lockedInfo) {
    apply(view, props)
    return
  }

  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: lockedInfo.descriptionText,
  }, function (status) {
    if (status) {
      unlockView()
      apply(view, props)
    } else {
      updateSelectedEntry(window._currentView, props)
    }
  })
}

// -----------------------------------------------------------------------------

function openConferenceManager () {
  var App = Linphone.App
  var callsWindow = App.getCallsWindow()

  App.smartShowWindow(callsWindow)
  callsWindow.openConferenceManager()
}

function manageAccounts () {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ManageAccounts.qml'))
}

// -----------------------------------------------------------------------------

function updateSelectedEntry (view, props) {
  var item = mainLoader.item

  var menu = item.menu
  var timeline = item.timeline

  if (view === 'Home') {
    item.homeEntry.select()
    timeline.resetSelectedEntry()
  } else if (view === 'Contacts') {
    item.contactsEntry.select()
    timeline.resetSelectedEntry()
  } else {
    menu.resetSelectedEntry()

    if (view === 'Conversation') {
      timeline.setSelectedEntry(props.peerAddress, props.localAddress)
    } else if (view === 'ContactEdit') {
      timeline.resetSelectedEntry()
    }
  }
}

// -----------------------------------------------------------------------------

function handleAuthenticationRequested (authInfo, realm, sipAddress, userId) {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/AuthenticationRequest.qml'), {
    authInfo: authInfo,
    realm: realm,
    sipAddress: sipAddress,
    userId: userId,
    virtualWindowHash:Qt.md5('Dialogs/AuthenticationRequest.qml'+realm+sipAddress+userId)
  })
}
