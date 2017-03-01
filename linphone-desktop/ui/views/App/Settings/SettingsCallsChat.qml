import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
  Column {
    anchors.fill: parent
    spacing: SettingsWindowStyle.forms.spacing

    Form {
      title: qsTr('callsTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('encryptionLabel')

          ExclusiveButtons {
            property var _resolveButton
            texts: [
              qsTr('noEncryption'), // 0.
              'SRTP',               // 1.
              'ZRTP',               // 2.
              'DTLS'                // 3.
            ]

            Component.onCompleted: {
              var map = _resolveButton = {}
              map[SettingsModel.MediaEncryptionNone] = 0
              map[SettingsModel.MediaEncryptionSrtp] = 1
              map[SettingsModel.MediaEncryptionZrtp] = 2
              map[SettingsModel.MediaEncryptionDtls] = 3

              selectedButton = Utils.invert(map)[SettingsModel.mediaEncryption]
            }

            onClicked: SettingsModel.mediaEncryption = _resolveButton[button]
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('autoAnswerLabel')

          Switch {
            id: autoAnswer
          }
        }

        FormGroup {
          label: qsTr('autoAnswerDelayLabel')

          NumericField {
            readOnly: !autoAnswer.checked
          }
        }
      }
    }

    Form {
      title: qsTr('chatTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('fileServerLabel')

          TextField {}
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('encryptWithLimeLabel')

          ExclusiveButtons {
            texts: [
              qsTr('limeDisabled'),
              qsTr('limeRequired'),
              qsTr('limePreferred')
            ]
          }
        }
      }
    }
  }
}
