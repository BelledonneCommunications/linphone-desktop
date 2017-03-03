import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

// =============================================================================

TabContainer {
  Form {
    title: qsTr('videoCaptureTitle')
    width: parent.width

    FormLine {
      FormGroup {
        label: qsTr('videoInputDeviceLabel')

        ComboBox {
          model: SettingsModel.videoDevices

          Component.onCompleted: currentIndex = Utils.findIndex(model, function (device) {
            return device === SettingsModel.videoDevice
          })

          onActivated: SettingsModel.videoDevice = model[index]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('videoPresetLabel')

        ComboBox {
          model: ListModel {
            id: presets

            ListElement {
              key: qsTr('presetDefault')
              value: 'default'
            }

            ListElement {
              key: qsTr('presetHighFps')
              value: 'high-fps'
            }

            ListElement {
              key: qsTr('presetCustom')
              value: 'custom'
            }
          }

          textRole: 'key'

          Component.onCompleted: {
            var preset = SettingsModel.videoPreset
            currentIndex = Number(Utils.findIndex([ 'default', 'high-fps', 'custom' ], function (value) {
              return preset === value
            }))
          }

          onActivated: SettingsModel.videoPreset = presets.get(index).value
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('videoSizeLabel')

        ComboBox {
          // TODO
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
  }
}
