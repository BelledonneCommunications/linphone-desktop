import QtQuick 2.7
import QtQuick.Layouts 1.3

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

  Column {
    anchors {
      fill: parent
      leftMargin: ManageAccountsStyle.leftMargin
      rightMargin: ManageAccountsStyle.rightMargin
    }

    spacing: ManageAccountsStyle.input.spacing

    Text {
      color: ManageAccountsStyle.input.legend.color
      elide: Text.ElideRight

      font {
        bold: true
        pointSize: ManageAccountsStyle.input.legend.fontSize
      }

      text: qsTr('selectAccountLabel')
    }

    ComboBox {
      id: email

      currentIndex: Utils.findIndex(AccountSettingsModel.accounts, function (account) {
        return account.sipAddress === AccountSettingsModel.sipAddress
      })

      model: AccountSettingsModel.accounts
      textRole: 'sipAddress'

      onActivated: AccountSettingsModel.setDefaultProxyConfig(model[index].proxyConfig)
    }
  }
}
