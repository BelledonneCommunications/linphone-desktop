// =============================================================================
// `Conversation.qml` Logic.
// =============================================================================

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function removeAllEntries () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('removeAllEntriesDescription'),
  }, function (status) {
    if (status) {
      chatProxyModel.removeAllEntries()
    }
  })
}
