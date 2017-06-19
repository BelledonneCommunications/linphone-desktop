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

  if (view === 'Home' || view === 'Contacts') {
    menu.setSelectedEntry(view === 'Home' ? 0 : 1)
    timeline.resetSelectedEntry()
  } else if (view === 'Conversation') {
    menu.resetSelectedEntry()
    timeline.setSelectedEntry(props.sipAddress)
  } else if (view === 'ContactEdit') {
    menu.resetSelectedEntry()
    timeline.resetSelectedEntry()
  }
}

// -----------------------------------------------------------------------------

function handleAuthenticationRequested (authInfo, realm, sipAddress, userId) {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/AuthenticationRequest.qml'), {
    authInfo: authInfo,
    realm: realm,
    sipAddress: sipAddress,
    userId: userId
  })
}
