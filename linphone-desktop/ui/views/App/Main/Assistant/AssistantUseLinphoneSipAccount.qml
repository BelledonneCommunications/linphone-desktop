import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: (function () {
    console.log('TODO')
  })

  mainActionEnabled: {
    var item = loader.item
    return item && item.mainActionEnabled
  }

  mainActionLabel: qsTr('confirmAction')

  title: qsTr('useLinphoneSipAccountTitle')

  // ---------------------------------------------------------------------------
  // Login with phone number.
  // ---------------------------------------------------------------------------

  Component {
    id: phoneNumberForm

    Form {
      property bool mainActionEnabled: country.currentIndex !== -1 && phoneNumber.text

      orientation: Qt.Vertical

      FormLine {
        FormGroup {
          label: qsTr('countryLabel')

          ComboBox {
            id: country
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('phoneNumberLabel')

          TextField {
            id: phoneNumber
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Login with email address.
  // ---------------------------------------------------------------------------

  Component {
    id: emailAddressForm

    Form {
      property bool mainActionEnabled: username.length && password.text

      orientation: Qt.Vertical

      FormLine {
        FormGroup {
          label: qsTr('usernameLabel')

          TextField {
            id: username
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('passwordLabel')

          TextField {
            id: password
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent
    spacing: AssistantUseLinphoneSipAccountStyle.spacing

    Loader {
      id: loader

      sourceComponent: checkBox.checked ? emailAddressForm : phoneNumberForm
      width: parent.width
    }

    CheckBoxText {
      id: checkBox

      text: qsTr('useUsernameToLogin')
      width: AssistantUseLinphoneSipAccountStyle.checkBox.width
    }
  }
}
