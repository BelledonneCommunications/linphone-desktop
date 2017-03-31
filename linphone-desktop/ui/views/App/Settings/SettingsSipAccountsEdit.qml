import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'SettingsSipAccountsEdit.js' as Logic

// =============================================================================

DialogPlus {
  id: dialog

  property var account // Optional.

  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    },
    TextButtonB {
      enabled: sipAddress.length > 0 && serverAddress.length > 0
      text: qsTr('confirm')

      onClicked: {
        Logic.validProxyConfig()
        exit(1)
      }
    }
  ]

  centeredButtons: true

  height: SettingsSipAccountsEditStyle.height
  width: SettingsSipAccountsEditStyle.width

  // ---------------------------------------------------------------------------

  Component.onCompleted: Logic.initForm(account)

  // ---------------------------------------------------------------------------

  Form {
    anchors {
      left: parent.left
      leftMargin: SettingsSipAccountsEditStyle.leftMargin
      right: parent.right
      rightMargin: SettingsSipAccountsEditStyle.rightMargin
    }

    FormLine {
      FormGroup {
        label: qsTr('sipAddressLabel') + '*'

        TextField {
          id: sipAddress
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('serverAddressLabel') + '*'

        TextField {
          id: serverAddress

          onTextChanged: Logic.handleServerAddressChanged(text)
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('registrationDurationLabel')

        NumericField {
          id: registrationDuration
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('transportLabel')

        ComboBox {
          id: transport

          model: [ 'UDP', 'TCP', 'TLS' ]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('routeLabel')

        TextField {
          id: route
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('contactParamsLabel')

        TextField {
          id: contactParams
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('avpfIntervalLabel')

        NumericField {
          id: avpfInterval

          maxValue: 5
          minValue: 1
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('registerEnabledLabel')

        Switch {
          id: registerEnabled

          onClicked: checked = !checked
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('publishPresenceLabel')

        Switch {
          id: publishPresence

          onClicked: checked = !checked
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('avpfEnabledLabel')

        Switch {
          id: avpfEnabled

          onClicked: checked = !checked
        }
      }
    }
  }
}
