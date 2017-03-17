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
  title: qsTr('manageAccountsTitle')

  height: ManageAccountsWindowStyle.height
  width: ManageAccountsWindowStyle.width

  minimumHeight: ManageAccountsWindowStyle.height
  minimumWidth: ManageAccountsWindowStyle.width
  maximumHeight: ManageAccountsWindowStyle.height
  maximumWidth: ManageAccountsWindowStyle.width

  // ---------------------------------------------------------------------------

  Form {
    orientation: Qt.Vertical

    anchors {
      left: parent.left
      leftMargin: ManageAccountsWindowStyle.leftMargin
      right: parent.right
      rightMargin: ManageAccountsWindowStyle.rightMargin
    }

    FormLine {
      FormGroup {
        label: qsTr('selectPresenceLabel')

        ComboBox {
          currentIndex: Utils.findIndex(PresenceStatusModel.statuses, function (status) {
            return status.presenceStatus == PresenceStatusModel.presenceStatus
          })

          model: PresenceStatusModel.statuses
          iconRole: 'presenceIcon'
          textRole: 'presenceLabel'

          onActivated: PresenceStatusModel.presenceStatus = model[index].presenceStatus
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
          textRole: 'sipAddress'

          onActivated: AccountSettingsModel.setDefaultProxyConfig(model[index].proxyConfig)
        }
      }
    }
  }
}
