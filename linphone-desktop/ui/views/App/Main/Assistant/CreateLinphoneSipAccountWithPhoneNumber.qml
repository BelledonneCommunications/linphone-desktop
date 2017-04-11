import QtQuick 2.7

import Common 1.0
import Linphone 1.0

// =============================================================================

AssistantAbstractView {
  id: view

  property alias usernameError: username.error

  title: qsTr('createLinphoneSipAccountTitle')

  Form {
    anchors.fill: parent

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

    FormLine {
      FormGroup {
        label: qsTr('usernameLabel')

        TextField {
          id: username

          onTextChanged: assistantModel.setUsername(text)
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Assistant.
  // ---------------------------------------------------------------------------

  AssistantModel {
    id: assistantModel

    onUsernameChanged: usernameError = error

    onCreateStatusChanged: {
      requestBlock.stop(error)
      if (!error.length) {
        // TODO.
      }
    }
  }
}
