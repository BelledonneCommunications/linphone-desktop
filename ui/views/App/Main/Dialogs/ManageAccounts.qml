import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'ManageAccount.js' as Logic

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

  height: SettingsModel.rlsUriEnabled ? ManageAccountsStyle.height : ManageAccountsStyle.heightWithoutPresence
  width: ManageAccountsStyle.width

  // ---------------------------------------------------------------------------

  Form {
    anchors.fill: parent
    orientation: Qt.Vertical

    FormLine {
      visible: SettingsModel.rlsUriEnabled

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

        ScrollableListViewField {
          width: parent.width
          height: ManageAccountsStyle.accountSelector.height

          radius: 0

          ScrollableListView {
            id: view

            property string textRole: 'sipAddress' // Used by delegate.

            anchors.fill: parent
            model: AccountSettingsModel.accounts

            onModelChanged: currentIndex = Utils.findIndex(AccountSettingsModel.accounts, function (account) {
              return account.sipAddress === AccountSettingsModel.sipAddress
            })

            delegate: CommonItemDelegate {
              id: item

              container: view
              flattenedModel: modelData
              itemIcon: Logic.getItemIcon(flattenedModel)
              width: parent.width

              onClicked: {
                container.currentIndex = index
                AccountSettingsModel.setDefaultProxyConfig(flattenedModel.proxyConfig)
              }

              MessageCounter {
                anchors.fill: parent
                count: flattenedModel.unreadMessageCount
              }
            }
          }
        }
      }
    }
  }
}
