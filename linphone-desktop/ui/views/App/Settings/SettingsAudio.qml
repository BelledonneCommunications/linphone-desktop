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
          model: SettingsModel.audioDevices

          Component.onCompleted: currentIndex = Utils.findIndex(model, function (device) {
            return device === SettingsModel.playbackDevice
          })

          onActivated: SettingsModel.playbackDevice = model[index]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('captureDeviceLabel')

        ComboBox {
          model: SettingsModel.audioDevices

          Component.onCompleted: currentIndex = Utils.findIndex(model, function (device) {
            return device === SettingsModel.captureDevice
          })

          onActivated: SettingsModel.captureDevice = model[index]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('ringerDeviceLabel')

        ComboBox {
          model: SettingsModel.audioDevices

          Component.onCompleted: currentIndex = Utils.findIndex(model, function (device) {
            return device === SettingsModel.ringerDevice
          })

          onActivated: SettingsModel.ringerDevice = model[index]
        }
      }
    }
  }
}
