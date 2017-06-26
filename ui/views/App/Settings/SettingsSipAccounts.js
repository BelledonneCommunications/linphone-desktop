// =============================================================================
// `SettingsSipAccounts.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function editAccount (account) {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/SettingsSipAccountsEdit.qml'), {
    account: account
  })
}

function deleteAccount (account) {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('deleteAccountDescription'),
  }, function (status) {
    if (status) {
      Linphone.AccountSettingsModel.removeProxyConfig(account.proxyConfig)
    }
  })
}

function eraseAllPasswords () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('eraseAllPasswordsDescription'),
  }, function (status) {
    if (status) {
      Linphone.AccountSettingsModel.eraseAllPasswords()
    }
  })
}
