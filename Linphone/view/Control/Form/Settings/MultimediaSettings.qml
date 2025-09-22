import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

ColumnLayout {
	id: mainItem
	property CallGui call
	property alias speakerVolume: speakerVolume.value
	property string speakerDevice: outputAudioDeviceCBox.currentText
	property alias micVolume: microVolume.value
	property string microDevice: inputAudioDeviceCBox.currentText
	property bool ringerDevicesVisible: false
	property bool backgroundVisible: true
    spacing: Utils.getSizeWithScreenRatio(40)

	RoundedPane {
		background.visible: mainItem.backgroundVisible
		Layout.alignment: Qt.AlignHCenter
		height: contentItem.implicitHeight + topPadding + bottomPadding
		Layout.fillWidth: true
        topPadding: background.visible ? Utils.getSizeWithScreenRatio(25) : 0
        bottomPadding: background.visible ? Utils.getSizeWithScreenRatio(25) : 0
        leftPadding: background.visible ? Utils.getSizeWithScreenRatio(25) : 0
        rightPadding: background.visible ? Utils.getSizeWithScreenRatio(25) : 0
		contentItem: ColumnLayout {
			spacing: mainItem.spacing
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(12)
				visible: mainItem.ringerDevicesVisible
				RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(8)
					EffectImage {
						imageSource: AppIcons.bellRinger
						colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                        imageWidth: Utils.getSizeWithScreenRatio(24)
                        imageHeight: Utils.getSizeWithScreenRatio(24)
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
                    Layout.topMargin: Utils.getSizeWithScreenRatio(12)
					Layout.preferredWidth: parent.width
					entries: SettingsCpp.ringerDevices
					propertyName: "ringerDevice"
					propertyOwner: SettingsCpp
					textRole: 'display_name'
					//: Choose %1
					Accessible.name: qsTr("choose_something_accessible_name").arg(qsTr("multimedia_settings_ringer_title"))
				}
				Item {
					Layout.fillHeight: true
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(12)
				RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(8)
					EffectImage {
						imageSource: AppIcons.speaker
						colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                        imageWidth: Utils.getSizeWithScreenRatio(24)
                        imageHeight: Utils.getSizeWithScreenRatio(24)
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
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
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
					Accessible.name: qsTr("choose_something_accessible_name").arg(qsTr("multimedia_settings_speaker_title"))
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
					//: %1 volume
					Accessible.name: qsTr("device_volume_accessible_name").arg(qsTr("multimedia_settings_speaker_title"))
				}
			}
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(12)
				RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(8)
					EffectImage {
						imageSource: AppIcons.microphone
						colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                        imageWidth: Utils.getSizeWithScreenRatio(24)
                        imageHeight: Utils.getSizeWithScreenRatio(24)
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
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
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
					Accessible.name: qsTr("choose_something_accessible_name").arg(qsTr("multimedia_settings_microphone_title"))
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
					//: %1 volume
					Accessible.name: qsTr("device_volume_accessible_name").arg(qsTr("multimedia_settings_microphone_title"))
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
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(10)

					background: Rectangle {
						x: audioTestSlider.leftPadding
						y: audioTestSlider.topPadding + audioTestSlider.availableHeight / 2 - height / 2
                        implicitWidth: Utils.getSizeWithScreenRatio(200)
                        implicitHeight: Utils.getSizeWithScreenRatio(10)
						width: audioTestSlider.availableWidth
						height: implicitHeight
                        radius: Utils.getSizeWithScreenRatio(2)
						color: DefaultStyle.grey_850

						Rectangle {
							width: audioTestSlider.visualPosition * parent.width
							height: parent.height
							gradient: Gradient {
								orientation: Gradient.Horizontal
								GradientStop { position: 0.0; color: DefaultStyle.vue_meter_light_green }
								GradientStop { position: 1.0; color: DefaultStyle.vue_meter_dark_green}
							}
                            radius: Utils.getSizeWithScreenRatio(2)
						}
					}
					handle: Item {visible: false}
				}
			}
            ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(12)
                visible: SettingsCpp.videoEnabled
                RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(8)
                    EffectImage {
                        imageSource: AppIcons.videoCamera
                        colorizationColor: DefaultStyle.main1_500_main
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                        imageWidth: Utils.getSizeWithScreenRatio(24)
                        imageHeight: Utils.getSizeWithScreenRatio(24)
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
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
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
					Accessible.name: qsTr("choose_something_accessible_name").arg(qsTr("multimedia_settings_camera_title"))
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
