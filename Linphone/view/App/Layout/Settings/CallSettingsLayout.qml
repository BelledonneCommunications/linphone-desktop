
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import SettingsCpp 1.0

GenericSettingsLayout {
	Layout.fillWidth: true
	Layout.fillHeight: true
	Component {
		id: settings
		ColumnLayout {
			spacing: 40 * DefaultStyle.dp
			SwitchSetting {
				titleText: qsTr("Activer la vidéo")
				propertyName: "videoEnabled"
			}
			SwitchSetting {
				titleText: qsTr("Utiliser l'annulateur d'écho")
				subTitleText: qsTr("Évite que de l'écho soit entendu par votre correspondant")
				propertyName: "echoCancellationEnabled"
			}
			SwitchSetting {
				titleText: qsTr("Démarrer l'enregistrement des appels automatiquement")
				propertyName: "automaticallyRecordCallsEnabled"
			}
			ColumnLayout {
				Layout.fillWidth: true
				RowLayout {
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
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					model: SettingsCpp.videoDevices
					propertyName: "videoDevice"
				}
			}
			ColumnLayout {
				Layout.fillWidth: true
				RowLayout {
					Layout.fillWidth: true
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
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					model: SettingsCpp.playbackDevices
					propertyName: "playbackDevice"
				}
				Slider {
					id: speakerVolume
					Layout.fillWidth: true
					from: 0.0
					to: 1.0
					value: SettingsCpp.playbackGain
					onMoved: {
						SettingsCpp.setPlaybackGain(value)
					}
				}
			}
			ColumnLayout {
				Layout.fillWidth: true
				RowLayout {
					Layout.fillWidth: true
					EffectImage {
						imageSource: AppIcons.speaker
						colorizationColor: DefaultStyle.main1_500_main
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						imageWidth: 24 * DefaultStyle.dp
						imageHeight: 24 * DefaultStyle.dp
					}
					Text {
						text: qsTr("Sonnerie")
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					model: SettingsCpp.playbackDevices
					propertyName: "ringerDevice"
				}
			}
			ColumnLayout {
				Layout.fillWidth: true
				RowLayout {
					Layout.fillWidth: true
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
						Layout.fillWidth: true
					}
				}
				ComboSetting {
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					model: SettingsCpp.captureDevices
					propertyName: "captureDevice"
				}
				Slider {
					id: microVolume
					Layout.fillWidth: true
					from: 0.0
					to: 1.0
					value: SettingsCpp.captureGain
					onMoved: {
						SettingsCpp.setCaptureGain(value)
					}
				}
				Timer {
					id: audioTestSliderTimer
					running: false
					interval: 50
					repeat: true
					onTriggered: SettingsCpp.updateMicVolume()
				}
				Slider {
					id: audioTestSlider
					visible: !SettingsCpp.isInCall
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
								GradientStop { position: 1.0; color: DefaultStyle.vue_meter_dark_green }
							}
							radius: 2 * DefaultStyle.dp
						}
					}
					handle: Item {visible: false}
				}
			}
			Connections {
				target: SettingsCpp
				onMicVolumeChanged: {
					audioTestSlider.value = volume
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
	component: settings
}
