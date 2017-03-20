import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

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
          label: qsTr('defaultDisplaynameLabel')

          TextField {
            text: AccountSettingsModel.primaryDisplayname

            onEditingFinished: AccountSettingsModel.primaryDisplayname = text
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
  }
}
