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
          qsTr('editHeader'),
          qsTr('deleteHeader')
        ]

        Repeater {
          model: AccountSettingsModel.accounts.slice(1)

          delegate: FormTableLine {
            title: modelData.sipAddress

            FormTableEntry {
              ActionButton {
                isCustom: true
                backgroundRadius: 4
                colorSet: SettingsWindowStyle.buttons.editProxy

                onClicked: Logic.editAccount(modelData)
              }
            }

            FormTableEntry {
              ActionButton {
                isCustom: true
                backgroundRadius: 4
                colorSet: SettingsWindowStyle.buttons.deleteProxy

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

    // -------------------------------------------------------------------------
    // Assistant.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('assistantTitle')
      
      width: parent.width
	  
	  FormLine {
        FormGroup {
          label: 'Registration URL'

          TextField {
            text: SettingsModel.assistantRegistrationUrl

            onEditingFinished: SettingsModel.assistantRegistrationUrl = text
          }
        }
      }

	  FormLine {
        FormGroup {
          label: 'Login URL'

          TextField {
            text: SettingsModel.assistantLoginUrl

            onEditingFinished: SettingsModel.assistantLoginUrl = text
          }
        }
      }

      FormLine {
		  visible: SettingsModel.developerSettingsEnabled
        FormGroup {
          label: qsTr('createAppSipAccountEnabledLabel')

          Switch {
            checked: SettingsModel.createAppSipAccountEnabled

            onClicked: SettingsModel.createAppSipAccountEnabled = !checked
          }
        }

        FormGroup {
          label: qsTr('useAppSipAccountEnabledLabel')

          Switch {
            checked: SettingsModel.useAppSipAccountEnabled

            onClicked: SettingsModel.useAppSipAccountEnabled = !checked
          }
        }
      }

      FormLine {
		  visible: SettingsModel.developerSettingsEnabled
        FormGroup {
          label: qsTr('useOtherSipAccountEnabledLabel')

          Switch {
            checked: SettingsModel.useOtherSipAccountEnabled

            onClicked: SettingsModel.useOtherSipAccountEnabled = !checked
          }
        }

        FormGroup {
          label: qsTr('fetchRemoteConfigurationEnabledLabel')

          Switch {
            checked: SettingsModel.fetchRemoteConfigurationEnabled

            onClicked: SettingsModel.fetchRemoteConfigurationEnabled = !checked
          }
        }
      }

      FormLine {
		  visible: SettingsModel.developerSettingsEnabled
        FormGroup {
          label: qsTr('assistantSupportsPhoneNumbersLabel')

          Switch {
            checked: SettingsModel.assistantSupportsPhoneNumbers

            onClicked: SettingsModel.assistantSupportsPhoneNumbers = !checked
          }
        }
      }
    }
  }
}
