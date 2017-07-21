import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  buttons: [
    TextButtonB {
      text: qsTr('ok')

      onClicked: exit(0)
    }
  ]

  centeredButtons: true
  objectName: '__manageAccounts'

  height: ManageAccountsStyle.height
  width: ManageAccountsStyle.width

  // ---------------------------------------------------------------------------

  Form {
    anchors.fill: parent
    orientation: Qt.Vertical

    FormLine {
      FormGroup {
        label: qsTr('selectPresenceLabel')

        ComboBox {
          currentIndex: Utils.findIndex(OwnPresenceModel.statuses, function (status) {
            return status.presenceStatus === OwnPresenceModel.presenceStatus
          })

          model: OwnPresenceModel.statuses
          iconRole: 'presenceIcon'
          textRole: 'presenceLabel'

          onActivated: OwnPresenceModel.presenceStatus = model[index].presenceStatus
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('selectAccountLabel')

        ComboBox {
          currentIndex: Utils.findIndex(AccountSettingsModel.accounts, function (account) {
            return account.sipAddress === AccountSettingsModel.sipAddress
          })

          model: AccountSettingsModel.accounts
          iconRole: (function (data) {
            var proxyConfig = data.proxyConfig
            if (!proxyConfig) {
              return ''
            }

            var description = AccountSettingsModel.getProxyConfigDescription(proxyConfig)
            return description.registerEnabled && description.registrationState !== AccountSettingsModel.RegistrationStateRegistered
              ? 'generic_error'
              : ''
          })
          textRole: 'sipAddress'

          onActivated: AccountSettingsModel.setDefaultProxyConfig(model[index].proxyConfig)
        }
      }
    }
  }
}
