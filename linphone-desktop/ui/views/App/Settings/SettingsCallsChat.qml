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
        visible: !!encryption.encryptions.length

        FormGroup {
          label: qsTr('encryptionLabel')

          ExclusiveButtons {
            id: encryption

            property var encryptions: (function () {
              var encryptions = SettingsModel.supportedMediaEncryptions
              if (encryptions.length) {
                encryptions.unshift([ SettingsModel.MediaEncryptionNone, qsTr('noEncryption') ])
              }

              return encryptions
            })()

            texts: encryptions.map(function (value) {
              return value[1]
            })

            onClicked: SettingsModel.mediaEncryption = encryptions[button][0]

            Binding {
              property: 'selectedButton'
              target: encryption
              value: SettingsModel.mediaEncryption
            }
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

          TextField {
            text: SettingsModel.fileTransferUrl

            onEditingFinished: SettingsModel.fileTransferUrl = text
          }
        }
      }

      FormLine {
        visible: SettingsModel.limeIsSupported

        FormGroup {
          label: qsTr('encryptWithLimeLabel')

          ExclusiveButtons {
            id: lime

            property var limeStates: ([
              [ SettingsModel.LimeStateDisabled, qsTr('limeDisabled') ],
              [ SettingsModel.LimeStateMandatory, qsTr('limeRequired') ],
              [ SettingsModel.LimeStatePreferred, qsTr('limePreferred') ]
            ])

            texts: limeStates.map(function (value) {
              return value[1]
            })

            onClicked: SettingsModel.limeState = limeStates[button][0]

            Binding {
              property: 'selectedButton'
              target: lime
              value: SettingsModel.limeState
            }
          }
        }
      }
    }
  }
}
