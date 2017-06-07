// =============================================================================
// `CallsWindow.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function handleClosing (close) {
  var callsList = Linphone.CallsListModel

  window.detachVirtualWindow()

  if (callsList.getRunningCallsNumber() === 0) {
    return
  }

  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('acceptClosingDescription')
  }, function (status) {
    if (status) {
      callsList.terminateAllCalls()
      window.close()
    }
  })

  close.accepted = false
}

// -----------------------------------------------------------------------------

function openCallSipAddress () {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/CallSipAddress.qml'))
}

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

function windowMustBeClosed () {
  return Linphone.CallsListModel.rowCount() === 0 && !window.virtualWindowVisible
}

function tryToCloseWindow () {
  if (windowMustBeClosed()) {
    // Workaround, it's necessary to use a timeout because at last call termination
    // a segfault is emit in `QOpenGLContext::functions() const ()`.
    Utils.setTimeout(window, 0, function () { windowMustBeClosed() && window.close() })
  }
}
