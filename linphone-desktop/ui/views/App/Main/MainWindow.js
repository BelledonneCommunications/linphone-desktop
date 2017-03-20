// =============================================================================
// `MainWindow.qml` Logic.
// =============================================================================

.import QtQuick.Window 2.2 as Window

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

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

    collapse.setCollapsed(true)
    updateSelectedEntry(view, props)
    window._currentView = view
    contentLoader.setSource(view + '.qml', props || {})
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
