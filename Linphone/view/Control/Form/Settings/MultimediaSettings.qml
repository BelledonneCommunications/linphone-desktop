import QtQuick
import QtQuick.Controls.Basic as Control
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
	property bool ringerDevicesVisible: false
	property bool backgroundVisible: true
	spacing: 40 * DefaultStyle.dp

	RoundedPane {
		background.visible: mainItem.backgroundVisible
		Layout.alignment: Qt.AlignHCenter
		height: contentItem.implicitHeight + topPadding + bottomPadding
		Layout.fillWidth: true
		topPadding: background.visible ? 25 * DefaultStyle.dp : 0
		bottomPadding: background.visible ? 25 * DefaultStyle.dp : 0
		leftPadding: background.visible ? 25 * DefaultStyle.dp : 0
		rightPadding: background.visible ? 25 * DefaultStyle.dp : 0
		contentItem: ColumnLayout {
			spacing: mainItem.spacing
			ColumnLayout {
				spacing: 12 * DefaultStyle.dp
				RowLayout {
					spacing: 8 * DefaultStyle.dp
					EffectImage {
						imageSource: AppIcons.bellRinger
						colorizationColor: DefaultStyle.main1_500_main
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						imageWidth: 24 * DefaultStyle.dp
						imageHeight: 24 * DefaultStyle.dp
					}
					Text {
						text: qsTr("Sonnerie - Appels entrants")
						font: Typography.p2l
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					Layout.fillWidth: true
					Layout.topMargin: 12 * DefaultStyle.dp
					Layout.preferredWidth: parent.width
					entries: SettingsCpp.ringerDevices
					propertyName: "ringerDevice"
					propertyOwner: SettingsCpp
				}
				Item {
					Layout.fillHeight: true
				}
			}
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
						font: Typography.p2l
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					id: outputAudioDeviceCBox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					Layout.preferredHeight: 49 * DefaultStyle.dp
					entries: SettingsCpp.playbackDevices
					propertyName: "playbackDevice"
					propertyOwner: SettingsCpp
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
						font: Typography.p2l
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					id: inputAudioDeviceCBox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					Layout.preferredHeight: 49 * DefaultStyle.dp
					entries: SettingsCpp.captureDevices
					propertyName: "captureDevice"
					propertyOwner: SettingsCpp
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
					id: audioTestSliderTimer
					interval: 50
					repeat: true
					running: false
					onTriggered: {
						if (mainItem.call) audioTestSlider.value = mainItem.call.core.microVolume
						else SettingsCpp.updateMicVolume()
					}
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
						color: DefaultStyle.grey_850

						Rectangle {
							width: audioTestSlider.visualPosition * parent.width
							height: parent.height
							gradient: Gradient {
								orientation: Gradient.Horizontal
								GradientStop { position: 0.0; color: DefaultStyle.vue_meter_light_green }
								GradientStop { position: 1.0; color: DefaultStyle.vue_meter_dark_green}
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
						font: Typography.p2l
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					id: videoDevicesCbox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					Layout.preferredHeight: 49 * DefaultStyle.dp
					entries: SettingsCpp.videoDevices
					propertyName: "videoDevice"
					propertyOwner: SettingsCpp
				}
			}
			Connections {
				enabled: !mainItem.call
				target: SettingsCpp
				onMicVolumeChanged: (value) => {
					audioTestSlider.value = value
				}
			}
			Component.onCompleted: {
				SettingsCpp.accessCallSettings()
				audioTestSliderTimer.running = true
			}
			Component.onDestruction: {
				audioTestSliderTimer.running = false
				SettingsCpp.closeCallSettings()
			}
		}
	}
	Item {
		Layout.fillHeight: true
	}
}
