// =============================================================================
// `MainWindow.qml` Logic.
// =============================================================================

.import QtQuick.Window 2.2 as Window

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function handleActiveFocusItemChanged (activeFocusItem) {
  var smartSearchBar = window._smartSearchBar

  if (activeFocusItem == null && smartSearchBar) {
    smartSearchBar.hideMenu()
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
    if (window.visibility === Window.Minimized) {
      window.visibility = Window.AutomaticVisibility
    } else {
      window.setVisible(true)
    }

    var item = mainLoader.item

    item.collapse.setCollapsed(true)
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

function manageAccounts () {
  window.attachVirtualWindow(Qt.resolvedUrl('ManageAccounts.qml'))
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
  window.attachVirtualWindow(Qt.resolvedUrl('AuthenticationRequest.qml'), {
    authInfo: authInfo,
    realm: realm,
    sipAddress: sipAddress,
    userId: userId
  })
}
