import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
  Column {
    spacing: SettingsWindowStyle.forms.spacing
    width: parent.width

    // -------------------------------------------------------------------------
    // Video parameters.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('videoCaptureTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('videoInputDeviceLabel')

          ComboBox {
            currentIndex: Utils.findIndex(model, function (device) {
              return device === SettingsModel.videoDevice
            })
            model: SettingsModel.videoDevices

            onActivated: SettingsModel.videoDevice = model[index]
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('videoPresetLabel')

          ComboBox {
            currentIndex: {
              var preset = SettingsModel.videoPreset

              return Number(Utils.findIndex(model, function (value) {
                return preset === value.value
              }))
            }

            model: [{
              key: qsTr('presetDefault'),
              value: 'default'
            }, {
              key: qsTr('presetHighFps'),
              value: 'high-fps'
            }, {
              key: qsTr('presetCustom'),
              value: 'custom'
            }]

            textRole: 'key'

            onActivated: SettingsModel.videoPreset = model[index].value
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('videoSizeLabel')

          ComboBox {
            currentIndex: Utils.findIndex(model, function (definition) {
              return definition.value.name === SettingsModel.videoDefinition.name
            })
            model: SettingsModel.supportedVideoDefinitions.map(function (definition) {
              return {
                key: definition.name + ' (' + definition.width + 'x' + definition.height + ')',
                value: definition
              }
            })

            textRole: 'key'

            onActivated: SettingsModel.videoDefinition = model[index].value
          }
        }

        FormGroup {
          label: qsTr('videoFramerateLabel')

          NumericField {
            maxValue: 60
            minValue: 1
            readOnly: SettingsModel.videoPreset !== 'custom'
            text: SettingsModel.videoFramerate

            onEditingFinished: SettingsModel.videoFramerate = text
          }
        }
      }

      FormEmptyLine {}
    }

    TextButtonB {
      anchors.right: parent.right
      text: qsTr('showCameraPreview')

      onClicked: console.log('TODO')
    }

    // -------------------------------------------------------------------------
    // Video Codecs.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('videoCodecsTitle')
      width: parent.width

      CodecsViewer {
        model: VideoCodecsModel
        width: parent.width
      }
    }
  }
}
