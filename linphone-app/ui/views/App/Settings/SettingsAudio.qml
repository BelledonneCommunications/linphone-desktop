import QtQuick 2.7 as Core
import QtQuick.Controls 2.7 as Core
import QtQuick.Layouts 1.10 as Core

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

TabContainer {
  Core.Column {
    spacing: SettingsWindowStyle.forms.spacing
    width: parent.width

    // -------------------------------------------------------------------------
    // Audio parameters.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('audioTitle')
      width: parent.width

      //Warning if in call
      FormLine {
        visible: SettingsModel.isInCall

	FormGroup {
	  Core.RowLayout {
	    spacing: SettingsAudioStyle.warningMessage.iconSize
	    Icon {
	      icon: 'warning'
	      iconSize: SettingsAudioStyle.warningMessage.iconSize
	      anchors {
	        rightMargin: SettingsAudioStyle.warningMessage.iconSize
	        leftMargin: SettingsAudioStyle.warningMessage.iconSize
	      }
	    }
	    Core.Text {
	      text: qsTr('audioSettingsInCallWarning')
	    }
	  }
        }
      }

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
	  label: qsTr('playbackGainLabel')
	  enabled: !SettingsModel.isInCall

	  Slider {
	    id: playbackSlider
	    width: parent.width
	    enabled: !SettingsModel.isInCall

	    Core.Component.onCompleted: value = SettingsModel.playbackGain
	    onPositionChanged: SettingsModel.playbackGain = position

	    Core.ToolTip {
	      parent: playbackSlider.handle
	      visible: playbackSlider.pressed
	      text: (playbackSlider.value * 100).toFixed(0) + " %"
	    }
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
	  label: qsTr('captureGainLabel')

	  Slider {
	    id: captureSlider
	    width: parent.width
	    enabled: !SettingsModel.isInCall

	    Core.Component.onCompleted: value = SettingsModel.captureGain
	    onPositionChanged: SettingsModel.captureGain = position

	    Core.ToolTip {
	      parent: captureSlider.handle
	      visible: captureSlider.pressed
	      text: (captureSlider.value * 100).toFixed(0) + " %"
	    }
	  }
	}
      }

      FormLine {
        FormGroup {
          id: audioTestRow
	  label: qsTr('audioTestLabel')
	  visible: !SettingsModel.isInCall

	  Core.Slider {
	    id: audioTestSlider

	    enabled: false
	    width: parent.width
            anchors {
	      leftMargin: SettingsAudioStyle.ringPlayer.leftMargin
	    }

	    background: Core.Rectangle {
	      x: audioTestSlider.leftPadding
	      y: audioTestSlider.topPadding + audioTestSlider.availableHeight / 2 - height / 2
	      implicitWidth: 200
	      implicitHeight: 8
	      width: audioTestSlider.availableWidth
	      height: implicitHeight
	      radius: 2
	      color: "#bdbebf"

	      Core.Rectangle {
	        width: audioTestSlider.visualPosition * parent.width
  	        height: parent.height
		color: audioTestSlider.value > 0.8 ? "#ff0000" : "#21be2b"
		radius: 2
	      }
	    }

	    //Empty slider handle
	    handle: Core.Text {
	      text: ''
	      visible: false
	    }

	    Core.Timer {
	      interval: 50
	      repeat: true
	      running: SettingsModel.captureGraphRunning

	      onTriggered: parent.value = SettingsModel.getMicVolume()
	    }
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('ringerDeviceLabel')

          ComboBox {
            enabled: !SettingsModel.isInCall
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

              Core.Loader {
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
      visible: SettingsModel.showAudioCodecs || SettingsModel.developerSettingsEnabled
      width: parent.width

      FormLine {
        visible: SettingsModel.developerSettingsEnabled

        FormGroup {
          label: qsTr('showAudioCodecsLabel')

          Switch {
            checked: SettingsModel.showAudioCodecs

            onClicked: SettingsModel.showAudioCodecs = !checked
          }
        }
      }

      CodecsViewer {
        model: AudioCodecsModel
        width: parent.width
      }
    }
  }
}
