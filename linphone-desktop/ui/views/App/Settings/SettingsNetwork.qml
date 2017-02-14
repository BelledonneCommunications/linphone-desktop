import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
  Column {
    spacing: SettingsWindowStyle.forms.spacing
    width: parent.width

    // -------------------------------------------------------------------------
    // Transport.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('transportTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('forceMtuLabel')

          Switch {
            id: forceMtu
          }
        }

        FormGroup {
          label: qsTr('mtuLabel')

          NumericField {
            readOnly: !forceMtu.checked
          }
        }
      }

      FormGroup {
        label: qsTr('sendDtmfsLabel')

        Switch {}
      }

      FormGroup {
        label: qsTr('allowIpV6Label')

        Switch {}
      }
    }

    // -------------------------------------------------------------------------
    // Network protocol and ports.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('networkProtocolAndPortsTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('sipUdpPortLabel')

          NumericField {
            readOnly: randomSipUdpPort.checked
          }
        }

        FormGroup {
          label: qsTr('randomSipUdpPortLabel')

          Switch {
            id: randomSipUdpPort
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('sipTcpPortLabel')

          NumericField {
            readOnly: randomSipTcpPort.checked
          }
        }

        FormGroup {
          label: qsTr('randomSipTcpPortLabel')

          Switch {
            id: randomSipTcpPort
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('audioRtpUdpPortLabel')

          NumericField {
            readOnly: randomAudioRtpUdpPort.checked
          }
        }

        FormGroup {
          label: qsTr('randomAudioRtpUdpPortLabel')

          Switch {
            id: randomAudioRtpUdpPort
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('videoRtpUdpPortLabel')

          NumericField {
            readOnly: randomVideoRtpUdpPort.checked || !enableVideoRtpUdpPort.checked
          }
        }

        FormGroup {
          label: qsTr('randomVideoRtpUdpPortLabel')

          Switch {
            id: randomVideoRtpUdpPort
          }
        }

        Switch {
          id: enableVideoRtpUdpPort
        }
      }
    }

    // -------------------------------------------------------------------------
    // NAT and Firewall.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('natAndFirewallTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('enableIceLabel')

          Switch {
            id: enableIce
          }
        }

        FormGroup {
          label: qsTr('stunServerLabel')

          TextField {
            readOnly: !enableIce.checked
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('enableTurnLabel')

          Switch {
            id: enableTurn
          }
        }

        FormGroup {
          label: qsTr('turnUserLabel')

          TextField {
            readOnly: !enableTurn.checked
          }
        }
      }

      FormLine {
        FormGroup {
          label: ''
        }

        FormGroup {
          label: qsTr('turnPasswordLabel')

          TextField {
            echoMode: TextInput.Password
            readOnly: !enableTurn.checked
          }
        }
      }
    }
  }
}
