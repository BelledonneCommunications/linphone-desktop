import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'SettingsSipAccounts.js' as Logic

// =============================================================================

TabContainer {
  Column {
    spacing: SettingsWindowStyle.forms.spacing
    width: parent.width

    // -------------------------------------------------------------------------
    // Default identity.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('defaultIdentityTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('defaultDisplayNameLabel')

          TextField {
            text: AccountSettingsModel.primaryDisplayName

            onEditingFinished: AccountSettingsModel.primaryDisplayName = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('defaultUsernameLabel')

          TextField {
            text: AccountSettingsModel.primaryUsername

            onEditingFinished: AccountSettingsModel.primaryUsername = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('defaultSipAddressLabel')

          TextField {
            readOnly: true
            text: AccountSettingsModel.primarySipAddress
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Proxy accounts.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('proxyAccountsTitle')
      width: parent.width

      FormTable {
        legendLineWidth: SettingsWindowStyle.sipAccounts.legendLineWidth

        titles: [
          qsTr('editionHeader'),
          qsTr('deleteHeader')
        ]

        Repeater {
          model: AccountSettingsModel.accounts.slice(1)

          delegate: FormTableLine {
            title: modelData.sipAddress

            FormTableEntry {
              ActionButton {
                icon: 'edit'
                iconSize: SettingsWindowStyle.sipAccounts.iconSize

                onClicked: Logic.editAccount(modelData)
              }
            }

            FormTableEntry {
              ActionButton {
                icon: 'delete'
                iconSize: SettingsWindowStyle.sipAccounts.iconSize

                onClicked: Logic.deleteAccount(modelData)
              }
            }
          }
        }
      }

      FormEmptyLine {}
    }

    Row {
      anchors.right: parent.right

      spacing: SettingsWindowStyle.sipAccounts.buttonsSpacing

      TextButtonB {
        text: qsTr('eraseAllPasswords')

        onClicked: Logic.eraseAllPasswords()
      }

      TextButtonB {
        text: qsTr('addAccount')

        onClicked: Logic.editAccount()
      }
    }
  }
}
