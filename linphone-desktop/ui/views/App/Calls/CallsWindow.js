// =============================================================================
// `CallsWindow.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

var forceClose = false

function handleClosing (close) {
  var callsList = Linphone.CallsListModel

  window.detachVirtualWindow()

  if (forceClose || callsList.getRunningCallsNumber() === 0) {
    forceClose = false
    callsList.terminateAllCalls()
    return
  }

  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('acceptClosingDescription'),
  }, function (status) {
    if (status) {
      forceClose = true
      window.close()
    }
  })

  close.accepted = false
}

function openConferenceManager () {
  window.attachVirtualWindow(Qt.resolvedUrl('ConferenceManager.qml'))
}
