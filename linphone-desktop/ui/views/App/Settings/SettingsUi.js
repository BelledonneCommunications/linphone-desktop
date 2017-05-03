// =============================================================================
// `SettingsUi.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function cleanAvatars () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('cleanAvatarsDescription'),
  }, function (status) {
    if (status) {
      Linphone.ContactsListModel.cleanAvatars()
    }
  })
}
