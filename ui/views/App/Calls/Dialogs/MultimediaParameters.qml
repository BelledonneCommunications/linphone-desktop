import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  buttons: [
    TextButtonB {
      text: qsTr('ok')

      onClicked: exit(0)
    }
  ]

  centeredButtons: true

  height: MultimediaParametersStyle.height
  width: MultimediaParametersStyle.width

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent
    spacing: MultimediaParametersStyle.column.spacing

    RowLayout {
      spacing: MultimediaParametersStyle.column.entry.spacing
      width: parent.width

      Icon {
        icon: 'speaker'
        iconSize: MultimediaParametersStyle.column.entry.iconSize
      }

      ComboBox {
        Layout.fillWidth: true

        currentIndex: Utils.findIndex(model, function (device) {
          return device === SettingsModel.playbackDevice
        })
        model: SettingsModel.playbackDevices

        onActivated: SettingsModel.playbackDevice = model[index]
      }
    }

    RowLayout {
      spacing: MultimediaParametersStyle.column.entry.spacing
      width: parent.width

      Icon {
        icon: 'micro'
        iconSize: MultimediaParametersStyle.column.entry.iconSize
      }

      ComboBox {
        Layout.fillWidth: true

        currentIndex: Utils.findIndex(model, function (device) {
          return device === SettingsModel.captureDevice
        })
        model: SettingsModel.captureDevices

        onActivated: SettingsModel.captureDevice = model[index]
      }
    }

    RowLayout {
      spacing: MultimediaParametersStyle.column.entry.spacing
      width: parent.width

      Icon {
        icon: 'camera'
        iconSize: MultimediaParametersStyle.column.entry.iconSize
      }

      ComboBox {
        Layout.fillWidth: true

        currentIndex: Number(Utils.findIndex(model, function (device) {
          return device === SettingsModel.videoDevice
        }))
        model: SettingsModel.videoDevices

        onActivated: SettingsModel.videoDevice = model[index]
      }
    }
  }
}
