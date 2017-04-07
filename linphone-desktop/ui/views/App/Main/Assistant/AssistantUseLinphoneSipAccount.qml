import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: requestBlock.execute
  mainActionEnabled: {
    var item = loader.item
    return item && item.mainActionEnabled && !requestBlock.loading
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

      dealWithErrors: true
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
      property bool mainActionEnabled: username.length &&
        password.text &&
        !usernameError.length &&
        !passwordError.length

      property alias usernameError: username.error
      property alias passwordError: password.error

      dealWithErrors: true
      orientation: Qt.Vertical

      FormLine {
        FormGroup {
          label: qsTr('usernameLabel')

          TextField {
            id: username

            onTextChanged: assistantModel.setUsername(text)
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('passwordLabel')

          TextField {
            id: password

            onTextChanged: assistantModel.setPassword(text)
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent

    Loader {
      id: loader

      sourceComponent: checkBox.checked ? emailAddressForm : phoneNumberForm
      width: parent.width
    }

    CheckBoxText {
      id: checkBox

      text: qsTr('useUsernameToLogin')
      width: AssistantUseLinphoneSipAccountStyle.checkBox.width

      onClicked: requestBlock.stop('')
    }

    RequestBlock {
      id: requestBlock

      action: assistantModel.login
      width: parent.width
    }
  }

  // ---------------------------------------------------------------------------

  AssistantModel {
    id: assistantModel

    onUsernameChanged: loader.item.usernameError = error
    onPasswordChanged: loader.item.passwordError = error

    onLoginStatusChanged: {
      requestBlock.stop(error)
      if (!error.length) {
        window.setView('Home')
      }
    }
  }
}
