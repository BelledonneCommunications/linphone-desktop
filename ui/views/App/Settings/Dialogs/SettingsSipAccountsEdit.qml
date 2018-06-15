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

  TabContainer {
    anchors.fill: parent

    Column {
      width: parent.width

      Form {
        title: qsTr('mainSipAccountSettingsTitle')
        width: parent.width

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

      // -----------------------------------------------------------------------
      // NAT and Firewall.
      // -----------------------------------------------------------------------

      Form {
        title: qsTr('natAndFirewallTitle')
        width: parent.width

        FormLine {
          FormGroup {
            label: qsTr('enableIceLabel')

            Switch {
              id: iceEnabled

              onClicked: checked = !checked
            }
          }

          FormGroup {
            label: qsTr('stunServerLabel')

            TextField {
              id: stunServer

              readOnly: !iceEnabled.checked
            }
          }
        }

        FormLine {
          FormGroup {
            label: qsTr('enableTurnLabel')

            Switch {
              id: turnEnabled

              enabled: iceEnabled.checked

              onClicked: checked = !checked
            }
          }

          FormGroup {
            label: qsTr('turnUserLabel')

            TextField {
              id: turnUser

              readOnly: !turnEnabled.checked || !turnEnabled.enabled
            }
          }
        }

        FormLine {
          FormGroup {}

          FormGroup {
            label: qsTr('turnPasswordLabel')

            TextField {
              id: turnPassword
              readOnly: !turnEnabled.checked || !turnEnabled.enabled || !turnUser.text.length
            }
          }
        }
      }
    }
  }
}
