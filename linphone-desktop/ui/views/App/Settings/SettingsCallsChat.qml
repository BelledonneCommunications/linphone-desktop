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
              value: {
                var toFound = SettingsModel.mediaEncryption
                return Number(
                  Utils.findIndex(encryption.encryptions, function (value) {
                    return toFound === value[0]
                  })
                )
              }
            }
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('autoAnswerLabel')

          Switch {
            id: autoAnswer

            checked: SettingsModel.autoAnswerStatus

            onClicked: SettingsModel.autoAnswerStatus = !checked
          }
        }

        FormGroup {
          label: qsTr('autoAnswerDelayLabel')

          NumericField {
            readOnly: !autoAnswer.checked

            minValue: 0
            maxValue: 30000
            step: 1000

            text: SettingsModel.autoAnswerDelay

            onEditingFinished: SettingsModel.autoAnswerDelay = text
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
        visible: false // TODO: Use `SettingsModel.limeIsSupported` binding in V2.

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
              value: {
                var toFound = SettingsModel.limeState
                return Number(
                  Utils.findIndex(lime.limeStates, function (value) {
                    return toFound === value[0]
                  })
                )
              }
            }
          }
        }
      }
    }
  }
}
