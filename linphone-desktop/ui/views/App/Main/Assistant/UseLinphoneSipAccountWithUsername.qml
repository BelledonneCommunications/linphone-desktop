import Common 1.0

// =============================================================================

Form {
  property alias passwordError: password.error
  property alias usernameError: username.error

  property bool mainActionEnabled: password.text &&
    username.length &&
    !passwordError.length &&
    !usernameError.length

  dealWithErrors: true
  orientation: Qt.Vertical

  FormLine {
    FormGroup {
      label: qsTr('usernameLabel')

      TextField {
        id: username

        onTextChanged: assistantModel.username = text
      }
    }
  }

  FormLine {
    FormGroup {
      label: qsTr('passwordLabel')

      PasswordField {
        id: password

        onTextChanged: assistantModel.password = text
      }
    }
  }
}
