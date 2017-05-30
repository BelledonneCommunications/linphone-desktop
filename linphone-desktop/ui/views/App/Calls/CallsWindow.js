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
    descriptionText: qsTr('acceptClosingDescription')
  }, function (status) {
    if (status) {
      forceClose = true
      window.close()
    }
  })

  close.accepted = false
}

// -----------------------------------------------------------------------------

function openConferenceManager () {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ConferenceManager.qml'))
}

// -----------------------------------------------------------------------------

function getContent () {
  var call = window.call
  if (call == null) {
    return conference
  }

  var status = call.status
  if (status == null) {
    return calls.conferenceModel.count > 0 ? conference : null
  }

  var CallModel = Linphone.CallModel
  if (status === CallModel.CallStatusIncoming) {
    return incomingCall
  }

  if (status === CallModel.CallStatusOutgoing) {
    return outgoingCall
  }

  if (status === CallModel.CallStatusEnded) {
    return endedCall
  }

  return incall
}

// -----------------------------------------------------------------------------

function handleCallTransferAsked (call) {
  if (!call) {
    return
  }

  window.detachVirtualWindow()
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/CallTransfer.qml'), {
    call: call
  })
}
