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
            minValue: 500
            maxValue: 3001
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

      FormHeader {
        FormHeaderGroup {
          text: qsTr('portHeader')
        }

        FormHeaderEntry {
          text: qsTr('randomPortHeader')
        }

        FormHeaderEntry {
          text: qsTr('enabledPortHeader')
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('sipUdpPortLabel')

          NumericField {
            minValue: 0
            maxValue: 65535
            readOnly: randomSipUdpPort.checked || !enableSipUdpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: randomSipUdpPort

            enabled: enableSipUdpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: enableSipUdpPort
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('sipTcpPortLabel')

          NumericField {
            minValue: 0
            maxValue: 65535
            readOnly: randomSipTcpPort.checked || !enableSipTcpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: randomSipTcpPort

            enabled: enableSipTcpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: enableSipTcpPort
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('audioRtpUdpPortLabel')

          NumericField {
            minValue: 0
            maxValue: 65535
            readOnly: randomAudioRtpUdpPort.checked || !enableAudioRtpUdpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: randomAudioRtpUdpPort

            enabled: enableAudioRtpUdpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: enableAudioRtpUdpPort
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('videoRtpUdpPortLabel')

          NumericField {
            minValue: 0
            maxValue: 65535
            readOnly: randomVideoRtpUdpPort.checked || !enableVideoRtpUdpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: randomVideoRtpUdpPort

            enabled: enableVideoRtpUdpPort.checked
          }
        }

        FormEntry {
          Switch {
            id: enableVideoRtpUdpPort
          }
        }
      }

      FormEmptyLine {}

      FormLine {
        FormGroup {
          label: qsTr('enableTlsLabel')

          Switch {}
        }
      }
    }

    // -------------------------------------------------------------------------
    // DSCP fields.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('dscpFieldsTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('sipFieldLabel')

          TextField {}
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('audioRtpStreamFieldLabel')

          TextField {}
        }

        FormGroup {
          label: qsTr('videoRtpStreamFieldLabel')

          TextField {}
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

            enabled: enableIce.checked
          }
        }

        FormGroup {
          label: qsTr('turnUserLabel')

          TextField {
            readOnly: !enableTurn.checked || !enableTurn.enabled
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
            readOnly: !enableTurn.checked || !enableTurn.enabled
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Bandwidth control.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('bandwidthControlTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('downloadSpeedLimitLabel')

          NumericField {
            minValue: 0
            maxValue: 100000
          }
        }

        FormGroup {
          label: qsTr('uploadSpeedLimitLabel')

          NumericField {
            minValue: 0
            maxValue: 100000
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('enableAdaptiveRateControlLabel')

          Switch {}
        }
      }
    }
  }
}
