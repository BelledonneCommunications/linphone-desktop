import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0

ColumnLayout {
	id: mainItem
	property CallGui call
	property alias speakerVolume: speakerVolume.value
	property string speakerDevice: outputAudioDeviceCBox.currentText
	property alias micVolume: microVolume.value
	property string microDevice: inputAudioDeviceCBox.currentText

	RoundedPane {
		Layout.alignment: Qt.AlignHCenter
		Control.StackView.onActivated: {
			rightPanelTitle.text = qsTr("Paramètres")
		}
		height: contentItem.implicitHeight + topPadding + bottomPadding
		Layout.fillWidth: true
		topPadding: 25 * DefaultStyle.dp
		bottomPadding: 25 * DefaultStyle.dp
		leftPadding: 25 * DefaultStyle.dp
		rightPadding: 25 * DefaultStyle.dp
		contentItem: ColumnLayout {
			spacing: 40 * DefaultStyle.dp
			ColumnLayout {
				spacing: 12 * DefaultStyle.dp
				RowLayout {
					spacing: 8 * DefaultStyle.dp
					EffectImage {
						imageSource: AppIcons.speaker
						colorizationColor: DefaultStyle.main1_500_main
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						imageWidth: 24 * DefaultStyle.dp
						imageHeight: 24 * DefaultStyle.dp
					}
					Text {
						text: qsTr("Haut-parleurs")
						font.pixelSize: 14 * DefaultStyle.dp
						Layout.fillWidth: true
					}
				}
				ComboBox {
					id: outputAudioDeviceCBox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					Layout.preferredHeight: 49 * DefaultStyle.dp
					model: SettingsCpp.playbackDevices
					onCurrentTextChanged: {
						if (mainItem.call) mainItem.call.core.lSetOutputAudioDevice(currentText)
						SettingsCpp.lSetPlaybackDevice(currentText)
					}
				}
				Slider {
					id: speakerVolume
					Layout.fillWidth: true
					from: 0.0
					to: 1.0
					value: mainItem.call ? mainItem.call.core.speakerVolumeGain : SettingsCpp.playbackGain
					onMoved: {
						if (mainItem.call) mainItem.call.core.lSetSpeakerVolumeGain(value)
						SettingsCpp.lSetPlaybackGain(value)
					}
				}
			}
			ColumnLayout {
				spacing: 12 * DefaultStyle.dp
				RowLayout {
					spacing: 8 * DefaultStyle.dp
					EffectImage {
						imageSource: AppIcons.microphone
						colorizationColor: DefaultStyle.main1_500_main
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						imageWidth: 24 * DefaultStyle.dp
						imageHeight: 24 * DefaultStyle.dp
					}
					Text {
						text: qsTr("Microphone")
						font.pixelSize: 14 * DefaultStyle.dp
						Layout.fillWidth: true
					}
				}
				ComboBox {
					id: inputAudioDeviceCBox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					Layout.preferredHeight: 49 * DefaultStyle.dp
					model: SettingsCpp.captureDevices
					onCurrentTextChanged: {
						if (mainItem.call) mainItem.call.core.lSetInputAudioDevice(currentText)
						SettingsCpp.lSetCaptureDevice(currentText)
					}
				}
				Slider {
					id: microVolume
					Layout.fillWidth: true
					from: 0.0
					to: 1.0
					value: mainItem.call ? mainItem.call.core.microphoneVolumeGain : SettingsCpp.captureGain
					onMoved: {
						if (mainItem.call) mainItem.call.core.lSetMicrophoneVolumeGain(value)
						SettingsCpp.lSetCaptureGain(value)
					}
				}
				Timer {
					interval: 50
					repeat: true
					running: mainItem.call || false
					onTriggered: audioTestSlider.value = (mainItem.call && mainItem.call.core.microVolume)
				}
				Slider {
					id: audioTestSlider
					Layout.fillWidth: true
					enabled: false
					Layout.preferredHeight: 10 * DefaultStyle.dp

					background: Rectangle {
						x: audioTestSlider.leftPadding
						y: audioTestSlider.topPadding + audioTestSlider.availableHeight / 2 - height / 2
						implicitWidth: 200 * DefaultStyle.dp
						implicitHeight: 10 * DefaultStyle.dp
						width: audioTestSlider.availableWidth
						height: implicitHeight
						radius: 2 * DefaultStyle.dp
						color: "#D9D9D9"

						Rectangle {
							width: audioTestSlider.visualPosition * parent.width
							height: parent.height
							gradient: Gradient {
								orientation: Gradient.Horizontal
								GradientStop { position: 0.0; color: "#6FF88D" }
								GradientStop { position: 1.0; color: "#00D916" }
							}
							radius: 2 * DefaultStyle.dp
						}
					}
					handle: Item {visible: false}
				}
			}
			ColumnLayout {
				spacing: 12 * DefaultStyle.dp
				RowLayout {
					spacing: 8 * DefaultStyle.dp
					EffectImage {
						imageSource: AppIcons.videoCamera
						colorizationColor: DefaultStyle.main1_500_main
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						imageWidth: 24 * DefaultStyle.dp
						imageHeight: 24 * DefaultStyle.dp
					}
					Text {
						text: qsTr("Caméra")
						font.pixelSize: 14 * DefaultStyle.dp
						Layout.fillWidth: true
					}
				}
				ComboBox {
					id: videoDevicesCbox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					Layout.preferredHeight: 49 * DefaultStyle.dp
					model: SettingsCpp.videoDevices
					currentIndex: SettingsCpp.videoDeviceIndex
					onCurrentTextChanged: {
						SettingsCpp.lSetVideoDevice(currentText)
					}
				}
			}
		}
	}
	Item {
		Layout.fillHeight: true
	}
}
