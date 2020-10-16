import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
  Column {
    spacing: SettingsWindowStyle.forms.spacing
    width: parent.width

    // -------------------------------------------------------------------------
    // General.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('generalTitle')
      visible: SettingsModel.developerSettingsEnabled
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('showNetworkSettingsLabel')

          Switch {
            checked: SettingsModel.showNetworkSettings

            onClicked: SettingsModel.showNetworkSettings = !checked
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Transport.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('transportTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('sendDtmfsLabel')

          ExclusiveButtons {
            selectedButton: Number(!SettingsModel.useSipInfoForDtmfs)
            texts: [
              'SIP INFO',
              'RFC 2833'
            ]

            onClicked: SettingsModel.useSipInfoForDtmfs = !button
          }
        }

        FormGroup {
          label: qsTr('allowIpV6Label')

          Switch {
            checked: SettingsModel.ipv6Enabled

            onClicked: SettingsModel.ipv6Enabled = !checked
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
            step: 100

            text: SettingsModel.downloadBandwidth

            onEditingFinished: SettingsModel.downloadBandwidth = text
          }
        }

        FormGroup {
          label: qsTr('uploadSpeedLimitLabel')

          NumericField {
            minValue: 0
            maxValue: 100000
            step: 100
            text: SettingsModel.uploadBandwidth

            onEditingFinished: SettingsModel.uploadBandwidth = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('enableAdaptiveRateControlLabel')

          Switch {
            checked: SettingsModel.adaptiveRateControlEnabled
            onClicked: SettingsModel.adaptiveRateControlEnabled = !checked
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Presence.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('presenceTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('rlsUriLabel')

          ExclusiveButtons {
            selectedButton: Number(!SettingsModel.rlsUriEnabled)
            texts: [
              qsTr('rlsUriAuto'),
              qsTr('rlsUriDisabled')
            ]

            onClicked: SettingsModel.rlsUriEnabled = !button
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Network protocol and ports.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('networkProtocolAndPortsTitle')
      width: parent.width

      FormTable {
        titles: []


        FormTableLine {
          title: qsTr('sipUdpPortLabel')
          

          FormTableEntry {
            NumericField {
              minValue: 1
              maxValue: 65535
              readOnly: !fixSipUdpPort.checked

              text: SettingsModel.udpPort

              onEditingFinished: SettingsModel.udpPort = text
              
              TextField{
                readOnly: true
                horizontalAlignment: TextInput.AlignHCenter
                visible:SettingsModel.udpPort<=0
                text:(SettingsModel.udpPort===-1?qsTr('RandomPort'):SettingsModel.udpPort===-2?qsTr('NotBoundPort'):SettingsModel.udpPort===0?qsTr('DeactivatedTransport'):"")
              }
            }
          }

          FormTableEntry {
            Switch {
              id: fixSipUdpPort

              readonly property int defaultPort: 5060

              checked: SettingsModel.udpPort > 0

              onClicked: SettingsModel.udpPort = (checked ? -2 : defaultPort)
            }
          }
        }

        FormTableLine {
          title: qsTr('sipTcpPortLabel')

          FormTableEntry {
            NumericField {
              minValue: 1
              maxValue: 65535
              readOnly: !fixSipTcpPort.checked

              text: SettingsModel.tcpPort

              onEditingFinished: SettingsModel.tcpPort = text
              
              TextField{
                readOnly: true
                horizontalAlignment: TextInput.AlignHCenter
                visible: SettingsModel.tcpPort<=0
                text:(SettingsModel.tcpPort===-1?qsTr('RandomPort'):SettingsModel.tcpPort===-2?qsTr('NotBoundPort'):SettingsModel.tcpPort===0?qsTr('DeactivatedTransport'):"")
             }
            }
          }

          FormTableEntry {
            Switch {
              id: fixSipTcpPort

              readonly property int defaultPort: 5060

              checked: SettingsModel.tcpPort > 0 

              onClicked: SettingsModel.tcpPort = (checked ? -2 : defaultPort)
            }
          }
        }

        FormTableLine {
          id: audioRtpUdpPort

          readonly property int defaultPort: 7078

          title: qsTr('audioRtpUdpPortLabel')

          FormTableEntry {
            PortField {
              readOnly: randomAudioRtpUdpPort.checked
              supportsRange: true
              text: SettingsModel.audioPortRange.join(':')

              onEditingFinished: SettingsModel.audioPortRange = [ portA, portB ]
            }
          }

          FormTableEntry {
            Switch {
              id: randomAudioRtpUdpPort

              checked: SettingsModel.audioPortRange[0] === -1

              onClicked: SettingsModel.audioPortRange = checked
                ? [ audioRtpUdpPort.defaultPort, -1 ]
                : [ -1, -1 ]
            }
          }
        }

        FormTableLine {
          id: videoRtpUdpPort

          readonly property int defaultPort: 9078

          title: qsTr('videoRtpUdpPortLabel')
          visible: SettingsModel.videoSupported

          FormTableEntry {
            PortField {
              readOnly: randomVideoRtpUdpPort.checked
              supportsRange: true
              text: SettingsModel.videoPortRange.join(':')

              onEditingFinished: SettingsModel.videoPortRange = [ portA, portB ]
            }
          }

          FormTableEntry {
            Switch {
              id: randomVideoRtpUdpPort

              checked: SettingsModel.videoPortRange[0] === -1

              onClicked: SettingsModel.videoPortRange = checked
                ? [ videoRtpUdpPort.defaultPort, -1 ]
                : [ -1, -1 ]
            }
          }
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

            checked: SettingsModel.iceEnabled

            onClicked: SettingsModel.iceEnabled = !checked
          }
        }

        FormGroup {
          label: qsTr('stunServerLabel')

          TextField {
            readOnly: !enableIce.checked

            text: SettingsModel.stunServer

            onEditingFinished: SettingsModel.stunServer = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('enableTurnLabel')

          Switch {
            id: enableTurn

            enabled: enableIce.checked
            checked: SettingsModel.turnEnabled

            onClicked: SettingsModel.turnEnabled = !checked
          }
        }

        FormGroup {
          label: qsTr('turnUserLabel')

          TextField {
            id: turnUser

            readOnly: !enableTurn.checked || !enableTurn.enabled
            text: SettingsModel.turnUser

            onEditingFinished: SettingsModel.turnUser = text
          }
        }
      }

      FormLine {
        FormGroup {}

        FormGroup {
          label: qsTr('turnPasswordLabel')

          TextField {
            readOnly: !enableTurn.checked || !enableTurn.enabled || !turnUser.text.length
            text: SettingsModel.turnPassword

            onEditingFinished: SettingsModel.turnPassword = text
          }
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

          HexField {
            text: SettingsModel.dscpSip
            onEditingFinished: SettingsModel.dscpSip = value
          }
        }

        FormGroup {}
      }

      FormLine {
        FormGroup {
          label: qsTr('audioRtpStreamFieldLabel')

          HexField {
            text: SettingsModel.dscpAudio
            onEditingFinished: SettingsModel.dscpAudio = value
          }
        }

        FormGroup {
          label: qsTr('videoRtpStreamFieldLabel')
          visible: SettingsModel.videoSupported

          HexField {
            text: SettingsModel.dscpVideo
            onEditingFinished: SettingsModel.dscpVideo = value
          }
        }
      }
    }
  }
}
