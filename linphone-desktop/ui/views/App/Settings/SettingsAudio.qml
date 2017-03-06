import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

// =============================================================================

TabContainer {
  Form {
    title: qsTr('audioTitle')
    width: parent.width

    FormLine {
      FormGroup {
        label: qsTr('playbackDeviceLabel')

        ComboBox {
          currentIndex: Utils.findIndex(model, function (device) {
            return device === SettingsModel.playbackDevice
          })
          model: SettingsModel.audioDevices

          onActivated: SettingsModel.playbackDevice = model[index]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('captureDeviceLabel')

        ComboBox {
          currentIndex: Utils.findIndex(model, function (device) {
            return device === SettingsModel.captureDevice
          })
          model: SettingsModel.audioDevices

          onActivated: SettingsModel.captureDevice = model[index]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('ringerDeviceLabel')

        ComboBox {
          currentIndex: Utils.findIndex(model, function (device) {
            return device === SettingsModel.ringerDevice
          })
          model: SettingsModel.audioDevices

          onActivated: SettingsModel.ringerDevice = model[index]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('ringLabel')

        FileChooserButton {
          selectedFile: SettingsModel.ringPath

          onAccepted: SettingsModel.ringPath = selectedFile
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('echoCancellationLabel')

        Switch {
          checked: SettingsModel.echoCancellationEnabled

          onClicked: SettingsModel.echoCancellationEnabled = !checked
        }
      }
    }
  }
}
