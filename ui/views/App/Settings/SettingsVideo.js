// =============================================================================
// `SettingsVideo.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

// =============================================================================

function showVideoPreview (account) {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/SettingsVideoPreview.qml'))
}

function updateVideoPreview () {
  var count = Linphone.CallsListModel.rowCount()
  if (count === 0) {
    showCameraPreview.enabled = true
  } else if (count === 1) {
    showCameraPreview.enabled = false
    window.detachVirtualWindow()
  }
}

function hideVideoPreview () {
  window.detachVirtualWindow()
}
