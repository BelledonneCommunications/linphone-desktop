import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'SettingsVideo.js' as Logic

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
            currentIndex: Number(Utils.findIndex(model, function (device) {
              return device === SettingsModel.videoDevice
            })) // Number cast => Index is null if app does not support video.
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
            currentIndex: Number(Utils.findIndex(model, function (definition) {
              return definition.value.name === SettingsModel.videoDefinition.name
            })) // Number cast => Index is null if app does not support video.
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
          visible: SettingsModel.videoPreset === 'custom'

          NumericField {
            maxValue: 60
            minValue: 1
            text: SettingsModel.videoFramerate

            onEditingFinished: SettingsModel.videoFramerate = text
          }
        }
      }

      FormEmptyLine {}
    }

    TextButtonB {
      id: showCameraPreview

      anchors.right: parent.right
      enabled: CallsListModel.rowCount() === 0

      text: qsTr('showCameraPreview')

      onClicked: Logic.showVideoPreview()

      Connections {
        target: CallsListModel

        onRowsInserted: Logic.updateVideoPreview()
        onRowsRemoved: Logic.updateVideoPreview()
      }

      Connections {
        target: window

        onClosing: Logic.hideVideoPreview()
      }
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
