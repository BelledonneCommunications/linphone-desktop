import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
	property var call
	property bool fixedSize : true

	property int fitHeight: MultimediaParametersDialogStyle.height+30
	property int fitWidth: MultimediaParametersDialogStyle.width
	// ---------------------------------------------------------------------------

	buttons: [
		TextButtonB {
			text: qsTr('ok')

			onClicked: {
				if(call)
					call.updateStreams()
				exit(0)
			}
		}
	]

	buttonsAlignment: Qt.AlignCenter
	onVisibleChanged: if(visible) {SettingsModel.reloadDevices()}
	Component.onCompleted: {
							SettingsModel.stopCaptureGraph()
							SettingsModel.reloadDevices()
							SettingsModel.startCaptureGraph()
							if( fixedSize){
							   height = fitHeight
							   width = fitWidth
						   }
	}
	Component.onDestruction: SettingsModel.stopCaptureGraph()
	onCallChanged: !call && exit(0)

	//: 'Multimedia parameters' : Menu title to show multimedia devices configuration.
	title: qsTr('menuMultimedia')
	// ---------------------------------------------------------------------------

	Column {
		anchors.fill: parent
		anchors.topMargin: MultimediaParametersDialogStyle.column.spacing
		spacing: MultimediaParametersDialogStyle.column.spacing

		RowLayout {
			spacing: MultimediaParametersDialogStyle.column.entry.spacing
			width: parent.width

			Icon {
				Layout.alignment: Qt.AlignTop
				Layout.preferredHeight: ComboBoxStyle.background.height

				icon: MultimediaParametersDialogStyle.column.entry.speaker.icon
				overwriteColor: MultimediaParametersDialogStyle.column.entry.speaker.colorModel.color
				iconSize: MultimediaParametersDialogStyle.column.entry.speaker.iconSize
			}

			Column {
				Layout.fillWidth: true

				spacing: MultimediaParametersDialogStyle.column.entry.spacing2

				ComboBox {
					currentIndex: Utils.findIndex(model, function (device) {
						return device === SettingsModel.playbackDevice
					})
					model: SettingsModel.playbackDevices
					width: parent.width

					onActivated: SettingsModel.playbackDevice = model[index]
				}

				Slider {
					id: playbackSlider
					width: parent.width
					property bool initialized: false

					value: call ? call.speakerVolumeGain : SettingsModel.playbackGain
					onPositionChanged: {
										if( initialized){
											if(call)
												call.speakerVolumeGain = position
											else
												SettingsModel.playbackGain = position
										}
									}
					Component.onCompleted: initialized = true

					ToolTip {
						parent: playbackSlider.handle
						visible: playbackSlider.pressed
						text: (playbackSlider.value * 100).toFixed(0) + " %"
					}
				}
			}
		}

		RowLayout {
			spacing: MultimediaParametersDialogStyle.column.entry.spacing
			width: parent.width

			Icon {
				Layout.alignment: Qt.AlignTop
				Layout.preferredHeight: ComboBoxStyle.background.height

				icon: MultimediaParametersDialogStyle.column.entry.micro.icon
				overwriteColor: MultimediaParametersDialogStyle.column.entry.micro.colorModel.color
				iconSize: MultimediaParametersDialogStyle.column.entry.micro.iconSize
			}

			Column {
				Layout.fillWidth: true

				spacing: MultimediaParametersDialogStyle.column.entry.spacing2

				ComboBox {
					currentIndex: Utils.findIndex(model, function (device) {
						return device === SettingsModel.captureDevice
					})
					model: SettingsModel.captureDevices
					width: parent.width

					onActivated: SettingsModel.captureDevice = model[index]
				}

				Slider {
					id: captureSlider
					width: parent.width
					value: call ? call.microVolumeGain : SettingsModel.captureGain
					property bool initialized: false

					onPositionChanged: if(initialized){
											if(call)
												call.microVolumeGain = position
											else
												SettingsModel.captureGain = position
										}
					Component.onCompleted: initialized = true

					ToolTip {
						parent: captureSlider.handle
						visible: captureSlider.pressed
						text: "+ " + (captureSlider.value * 100).toFixed(0) + " %"
					}
				}
				Slider {
					id: audioTestSlider

					enabled: false
					width: parent.width
					height: 8

					background: Rectangle {
						x: audioTestSlider.leftPadding
						y: audioTestSlider.topPadding + audioTestSlider.availableHeight / 2 - height / 2
						implicitWidth: 200
						implicitHeight: 8
						width: audioTestSlider.availableWidth
						height: implicitHeight
						radius: 2
						color: SettingsAudioStyle.sliderBackgroundColor.color

						Rectangle {
							width: audioTestSlider.visualPosition * parent.width
							height: parent.height
							color: audioTestSlider.value > 0.8 ? SettingsAudioStyle.sliderHighColor.color : SettingsAudioStyle.sliderLowColor.color
							radius: 2
						}
					}

					//Empty slider handle
					handle: Text {text: ''; visible: false }

					Timer {
						interval: 50
						repeat: true
						running: SettingsModel.captureGraphRunning || call || false

						onTriggered: call ? parent.value = call.microVu : parent.value = SettingsModel.getMicVolume()
					}
				}
			}
		}

		RowLayout {
			spacing: MultimediaParametersDialogStyle.column.entry.spacing
			width: parent.width
			visible: SettingsModel.videoAvailable

			Icon {
				icon: MultimediaParametersDialogStyle.column.entry.camera.icon
				overwriteColor: MultimediaParametersDialogStyle.column.entry.camera.colorModel.color
				iconSize: MultimediaParametersDialogStyle.column.entry.speaker.iconSize
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
