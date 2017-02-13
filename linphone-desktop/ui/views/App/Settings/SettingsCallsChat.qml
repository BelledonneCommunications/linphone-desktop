import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
  Column {
    anchors.fill: parent
    spacing: SettingsWindowStyle.forms.spacing

    Form {
      title: qsTr('callsTitle')
      width: parent.width

      FormGroup {
        label: qsTr('encryptionLabel')

        ExclusiveButtons {
          texts: [
            qsTr('noEncryption'),
            'SRTP',
            'ZRTP',
            'DTLS'
          ]
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

      FormGroup {
        label: qsTr('fileServerLabel')

        TextField {}
      }

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
