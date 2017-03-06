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

  height: ManageAccountsStyle.height
  width: ManageAccountsStyle.width

  minimumHeight: ManageAccountsStyle.height
  minimumWidth: ManageAccountsStyle.width
  maximumHeight: ManageAccountsStyle.height
  maximumWidth: ManageAccountsStyle.width

  // ---------------------------------------------------------------------------

  Form {
    orientation: Qt.Vertical

    anchors {
      left: parent.left
      leftMargin: ManageAccountsStyle.leftMargin
      right: parent.right
      rightMargin: ManageAccountsStyle.rightMargin
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
