import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

import 'AuthenticationRequest.js' as Logic

// =============================================================================

DialogPlus {
  id: dialog

  property alias realm: realm.text
  property alias sipAddress: identity.text
  property alias userId: userId.text

  property var authInfo

  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    },
    TextButtonB {
      enabled: password.length > 0
      text: qsTr('confirm')

      onClicked: {
        Logic.confirmPassword()
        exit(1)
      }
    }
  ]

  centeredButtons: true
  descriptionText: qsTr('authenticationRequestDescription')

  height: AuthenticationRequestStyle.height
  width: AuthenticationRequestStyle.width

  // ---------------------------------------------------------------------------

  Form {
    anchors.fill: parent
    orientation: Qt.Vertical

    FormLine {
      FormGroup {
        label: qsTr('identityLabel')

        TextField {
          id: identity

          readOnly: true
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('realmLabel')

        TextField {
          id: realm

          readOnly: true
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('userIdLabel')

        TextField {
          id: userId
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('passwordLabel')

        PasswordField {
          id: password
        }
      }
    }
  }
}
