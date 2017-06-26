// =============================================================================
// `SettingsAdvanced.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function cleanLogs () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('cleanLogsDescription'),
  }, function (status) {
    if (status) {
      Linphone.CoreManager.cleanLogs()
    }
  })
}

function handleLogsUploaded (url) {
  if (url.length && Utils.startsWith(url, 'http')) {
    sendLogsBlock.stop('')
    Qt.openUrlExternally(
      'mailto:' + encodeURIComponent(Linphone.SettingsModel.logsEmail) +
      '?subject=' + encodeURIComponent('Desktop Linphone Log') +
      '&body=' + encodeURIComponent(url)
    )
  } else {
    sendLogsBlock.stop(qsTr('logsUploadFailed'))
  }
}
