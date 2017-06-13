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
    // Audio parameters.
    // -------------------------------------------------------------------------

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
            model: SettingsModel.playbackDevices

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
            model: SettingsModel.captureDevices

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
            model: SettingsModel.playbackDevices

            onActivated: SettingsModel.ringerDevice = model[index]
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('ringLabel')

          FileChooserButton {
            selectedFile: SettingsModel.ringPath

            onAccepted: {
              var item = ringPlayer.item
              if (item) {
                item.stop()
              }

              SettingsModel.ringPath = selectedFile
            }

            ActionSwitch {
              anchors {
                left: parent.right
                leftMargin: SettingsAudioStyle.ringPlayer.leftMargin
              }

              enabled: {
                var item = ringPlayer.item
                return item && item.playbackState === SoundPlayer.PlayingState
              }

              icon: 'pause'

              onClicked: {
                var item = ringPlayer.item
                if (!item) {
                  return
                }

                if (enabled) {
                  item.stop()
                } else {
                  item.play()
                }
              }

              Loader {
                id: ringPlayer

                active: window.visible
                sourceComponent: SoundPlayer {
                  source: SettingsModel.ringPath
                }
              }
            }
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

    // -------------------------------------------------------------------------
    // Audio Codecs.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('audioCodecsTitle')
      width: parent.width

      CodecsViewer {
        model: AudioCodecsModel
        width: parent.width
      }
    }
  }
}
