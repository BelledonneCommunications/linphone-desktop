import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

import 'SettingsSipAccountsEdit.js' as Logic

// =============================================================================

DialogPlus {
  id: dialog

  property var account // Optional.

  property bool _sipAddressOk: false
  property bool _serverAddressOk: false
  property bool _routeOk: false

  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    },
    TextButtonB {
      enabled: Logic.formIsValid()
      text: qsTr('confirm')

      onClicked: Logic.validProxyConfig()
    }
  ]

  centeredButtons: true

  height: SettingsSipAccountsEditStyle.height
  width: SettingsSipAccountsEditStyle.width

  // ---------------------------------------------------------------------------

  Component.onCompleted: Logic.initForm(account)

  // ---------------------------------------------------------------------------

  Form {
    anchors.fill: parent

    FormLine {
      FormGroup {
        label: qsTr('sipAddressLabel') + '*'

        TextField {
          id: sipAddress

          error: dialog._sipAddressOk ? '' : qsTr('invalidSipAddress')

          onTextChanged: Logic.handleSipAddressChanged(text)
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('serverAddressLabel') + '*'

        TextField {
          id: serverAddress

          error: dialog._serverAddressOk ? '' : qsTr('invalidServerAddress')

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

          enabled: dialog._serverAddressOk
          model: [ 'UDP', 'TCP', 'TLS', 'DTLS' ]

          onActivated: Logic.handleTransportChanged(model[index])
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('routeLabel')

        TextField {
          id: route

          error: dialog._routeOk ? '' : qsTr('invalidRoute')

          onTextChanged: Logic.handleRouteChanged(text)
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
