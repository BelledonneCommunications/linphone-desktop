import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  id: view

  property alias emailError: email.error
  property alias passwordError: password.error
  property alias usernameError: username.error

  title: qsTr('createLinphoneSipAccountTitle')

  mainAction: requestBlock.execute
  mainActionEnabled: email.text.length
    && password.text.length
    && passwordConfirmation.text === password.text
    && username.text.length
    && !emailError.length
    && !passwordError.length
    && !requestBlock.loading
    && !usernameError.length
  mainActionLabel: qsTr('confirmAction')

  Column {
    anchors.fill: parent

    Form {
      dealWithErrors: true
      orientation: Qt.Vertical
      width: parent.width

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
          label: qsTr('emailLabel')

          TextField {
            id: email

            onTextChanged: assistantModel.email = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('passwordLabel')

          TextField {
            id: password

            onTextChanged: assistantModel.password = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('passwordConfirmationLabel')

          TextField {
            id: passwordConfirmation

            onTextChanged: error = password.text !== text
              ? qsTr('passwordConfirmationError')
              : ''
          }
        }
      }
    }

    RequestBlock {
      id: requestBlock

      action: assistantModel.create
      width: parent.width
    }
  }

  // ---------------------------------------------------------------------------
  // Assistant.
  // ---------------------------------------------------------------------------

  AssistantModel {
    id: assistantModel

    onEmailChanged: emailError = error
    onPasswordChanged: passwordError = error
    onUsernameChanged: usernameError = error

    onCreateStatusChanged: {
      requestBlock.stop(error)
      if (!error.length) {
        assistant.pushView('ActivateLinphoneSipAccountWithEmail', {
          assistantModel: assistantModel
        })
      }
    }
  }
}
