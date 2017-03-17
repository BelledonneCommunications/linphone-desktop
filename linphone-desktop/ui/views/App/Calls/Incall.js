// =============================================================================
// `Incall.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function handleVideoRequested () {
  var call = incall.call
  var dialog

  // Close dialog after 10s.
  var timeout = Utils.setTimeout(incall, 10000, function () {
    call.statusChanged.disconnect(endedHandler)
    dialog.close()
    call.rejectVideoRequest()
  })

  // Close dialog if call is ended.
  var endedHandler = function (status) {
    if (status === Linphone.CallModel.CallStatusEnded) {
      Utils.clearTimeout(timeout)
      call.statusChanged.disconnect(endedHandler)
      dialog.close()
    }
  }

  call.statusChanged.connect(endedHandler)

  dialog = Utils.openConfirmDialog(window, {
    descriptionText: qsTr('acceptVideoDescription'),
    exitHandler: function (status) {
      Utils.clearTimeout(timeout)
      call.statusChanged.disconnect(endedHandler)

      if (status) {
        call.acceptVideoRequest()
      } else {
        call.rejectVideoRequest()
      }
    },
    properties: {
      modality: Qt.NonModal
    },
    title: qsTr('acceptVideoTitle')
  })
}
