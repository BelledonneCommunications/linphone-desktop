import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp

ColumnLayout {
	id: mainItem
	property CallGui call
	property alias speakerVolume: speakerVolume.value
	property string speakerDevice: outputAudioDeviceCBox.currentText
	property alias micVolume: microVolume.value
	property string microDevice: inputAudioDeviceCBox.currentText
	property bool ringerDevicesVisible: false
	property bool backgroundVisible: true
    spacing: Math.round(40 * DefaultStyle.dp)

	RoundedPane {
		background.visible: mainItem.backgroundVisible
		Layout.alignment: Qt.AlignHCenter
		height: contentItem.implicitHeight + topPadding + bottomPadding
		Layout.fillWidth: true
        topPadding: background.visible ? Math.round(25 * DefaultStyle.dp) : 0
        bottomPadding: background.visible ? Math.round(25 * DefaultStyle.dp) : 0
        leftPadding: background.visible ? Math.round(25 * DefaultStyle.dp) : 0
        rightPadding: background.visible ? Math.round(25 * DefaultStyle.dp) : 0
		contentItem: ColumnLayout {
			spacing: mainItem.spacing
			ColumnLayout {
                spacing: Math.round(12 * DefaultStyle.dp)
				visible: mainItem.ringerDevicesVisible
				RowLayout {
                    spacing: Math.round(8 * DefaultStyle.dp)
					EffectImage {
						imageSource: AppIcons.bellRinger
						colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                        imageWidth: Math.round(24 * DefaultStyle.dp)
                        imageHeight: Math.round(24 * DefaultStyle.dp)
					}
					Text {
                        //: Ringtone - Incoming calls
                        text: qsTr("multimedia_settings_ringer_title")
						font: Typography.p2l
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					Layout.fillWidth: true
                    Layout.topMargin: Math.round(12 * DefaultStyle.dp)
					Layout.preferredWidth: parent.width
					entries: SettingsCpp.ringerDevices
					propertyName: "ringerDevice"
					propertyOwner: SettingsCpp
					textRole: 'display_name'
				}
				Item {
					Layout.fillHeight: true
				}
			}
			ColumnLayout {
                spacing: Math.round(12 * DefaultStyle.dp)
				RowLayout {
                    spacing: Math.round(8 * DefaultStyle.dp)
					EffectImage {
						imageSource: AppIcons.speaker
						colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                        imageWidth: Math.round(24 * DefaultStyle.dp)
                        imageHeight: Math.round(24 * DefaultStyle.dp)
					}
					Text {
                        //: "Haut-parleurs"
                        text: qsTr("multimedia_settings_speaker_title")
						font: Typography.p2l
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					id: outputAudioDeviceCBox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
                    Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
					entries: SettingsCpp.playbackDevices
					propertyName: "playbackDevice"
					propertyOwner: SettingsCpp
					textRole: 'display_name'
					Connections {
						enabled: mainItem.call
						target: outputAudioDeviceCBox
						function onCurrentValueChanged() {
							SettingsCpp.lSetPlaybackDevice(outputAudioDeviceCBox.currentValue)
						}
					}
				}
				Slider {
					id: speakerVolume
					Layout.fillWidth: true
					from: 0.0
					to: 1.0
					value: SettingsCpp.playbackGain
					onMoved: {
						if (mainItem.call) SettingsCpp.lSetPlaybackGain(value)
						else SettingsCpp.playbackGain = value
					}
				}
			}
			ColumnLayout {
                spacing: Math.round(12 * DefaultStyle.dp)
				RowLayout {
                    spacing: Math.round(8 * DefaultStyle.dp)
					EffectImage {
						imageSource: AppIcons.microphone
						colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                        imageWidth: Math.round(24 * DefaultStyle.dp)
                        imageHeight: Math.round(24 * DefaultStyle.dp)
					}
					Text {
                        //: "Microphone"
                        text: qsTr("multimedia_settings_microphone_title")
						font: Typography.p2l
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					id: inputAudioDeviceCBox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
                    Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
					entries: SettingsCpp.captureDevices
					propertyName: "captureDevice"
					propertyOwner: SettingsCpp
					textRole: 'display_name'
					Connections {
						enabled: mainItem.call
						target: inputAudioDeviceCBox
						function onCurrentValueChanged() {
							SettingsCpp.lSetCaptureDevice(inputAudioDeviceCBox.currentValue)
						}
					}
				}
				Slider {
					id: microVolume
					Layout.fillWidth: true
					from: 0.0
					to: 1.0
					value: SettingsCpp.captureGain
					onMoved: {
						if (mainItem.call) SettingsCpp.lSetCaptureGain(value)
						else SettingsCpp.captureGain = value
					}
				}
				Timer {
					id: audioTestSliderTimer
					interval: 50
					repeat: true
					running: false
					onTriggered: {
						SettingsCpp.updateMicVolume()
					}
				}
				Slider {
					id: audioTestSlider
					Layout.fillWidth: true
					enabled: false
                    Layout.preferredHeight: Math.round(10 * DefaultStyle.dp)

					background: Rectangle {
						x: audioTestSlider.leftPadding
						y: audioTestSlider.topPadding + audioTestSlider.availableHeight / 2 - height / 2
                        implicitWidth: Math.round(200 * DefaultStyle.dp)
                        implicitHeight: Math.round(10 * DefaultStyle.dp)
						width: audioTestSlider.availableWidth
						height: implicitHeight
                        radius: Math.round(2 * DefaultStyle.dp)
						color: DefaultStyle.grey_850

						Rectangle {
							width: audioTestSlider.visualPosition * parent.width
							height: parent.height
							gradient: Gradient {
								orientation: Gradient.Horizontal
								GradientStop { position: 0.0; color: DefaultStyle.vue_meter_light_green }
								GradientStop { position: 1.0; color: DefaultStyle.vue_meter_dark_green}
							}
                            radius: Math.round(2 * DefaultStyle.dp)
						}
					}
					handle: Item {visible: false}
				}
			}
            ColumnLayout {
                spacing: Math.round(12 * DefaultStyle.dp)
                visible: SettingsCpp.videoEnabled
                RowLayout {
                    spacing: Math.round(8 * DefaultStyle.dp)
                    EffectImage {
                        imageSource: AppIcons.videoCamera
                        colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                        imageWidth: Math.round(24 * DefaultStyle.dp)
                        imageHeight: Math.round(24 * DefaultStyle.dp)
                    }
                    Text {
                        //: "Caméra"
                        text: qsTr("multimedia_settings_camera_title")
                        font: Typography.p2l
                        Layout.fillWidth: true
                    }
                }
				ComboSetting {
					id: videoDevicesCbox
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
                    Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
					entries: SettingsCpp.videoDevices
					propertyName: "videoDevice"
					propertyOwner: SettingsCpp
					Connections {
						enabled: mainItem.call
						target: videoDevicesCbox
						function onCurrentValueChanged() {
							SettingsCpp.lSetVideoDevice(videoDevicesCbox.currentValue)
						}
					}
				}
			}
			Connections {
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
