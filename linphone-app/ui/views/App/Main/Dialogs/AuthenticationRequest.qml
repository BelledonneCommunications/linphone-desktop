import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import UtilsCpp 1.0
import App.Styles 1.0

import 'AuthenticationRequest.js' as Logic

// =============================================================================

DialogPlus {
  id: dialog

  property alias realm: realm.text
  property alias sipAddress: identity.hiddenText
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

  buttonsAlignment: Qt.AlignCenter
  descriptionText: qsTr('authenticationRequestDescription')

  height: AuthenticationRequestStyle.height + 60
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
			property string hiddenText
			text: UtilsCpp.toDisplayString(identity.hiddenText, SettingsModel.sipDisplayMode)
          readOnly: true
        }
      }
    }

    FormLine {
		visible: SettingsModel.sipDisplayMode == UtilsCpp.SIP_DISPLAY_ALL
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
