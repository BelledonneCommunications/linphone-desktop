
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import SettingsCpp 1.0

GenericSettingsLayout {
	component: settings
	width: parent.width
	Component {
		id: settings
		ColumnLayout {
			width: parent.width
			RowLayout {
				ColumnLayout {
					Layout.fillWidth: true
					Item {
						Layout.preferredWidth: 341 * DefaultStyle.dp
					}
				}
				ColumnLayout {
					Layout.rightMargin: 25 * DefaultStyle.dp
					Layout.topMargin: 36 * DefaultStyle.dp
					Layout.leftMargin: 64 * DefaultStyle.dp
					Layout.fillWidth: true
					spacing: 40 * DefaultStyle.dp
					SwitchSetting {
						titleText: qsTr("Annulateur d'écho")
						subTitleText: qsTr("Évite que de l'écho soit entendu par votre correspondant")
						propertyName: "echoCancellationEnabled"
					}
					SwitchSetting {
						Layout.fillWidth: true
						titleText: qsTr("Activer l’enregistrement automatique des appels")
						subTitleText: qsTr("Enregistrer tous les appels par défaut")
						propertyName: "automaticallyRecordCallsEnabled"
					}
				}
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 1 * DefaultStyle.dp
				color: DefaultStyle.main2_500main
				Layout.topMargin: 38 * DefaultStyle.dp
				Layout.bottomMargin: 16 * DefaultStyle.dp
			}
			RowLayout {
				ColumnLayout {
					Layout.fillWidth: true
					ColumnLayout {
						Layout.preferredWidth: 341 * DefaultStyle.dp
						Text {
							text: qsTr("Périphériques")
							font: Typography.p2
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
							Layout.fillWidth: true
						}
						Text {
							text: qsTr("Vous pouvez modifier les périphériques de sortie audio, le microphone et la caméra de capture.")
							font: Typography.p1
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
							Layout.fillWidth: true
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 20 * DefaultStyle.dp
					Layout.rightMargin: 44 * DefaultStyle.dp
					Layout.topMargin: 20 * DefaultStyle.dp
					Layout.leftMargin: 64 * DefaultStyle.dp

					ColumnLayout {
						Layout.fillWidth: true
						spacing: 0
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
								text: qsTr("Audio")
								Layout.leftMargin: 9
								font: Typography.p2l
								color: DefaultStyle.main2_600
								Layout.fillWidth: true
							}
						}
						ComboSetting {
							Layout.fillWidth: true
							Layout.topMargin: 12 * DefaultStyle.dp
							Layout.preferredWidth: parent.width
							model: SettingsCpp.playbackDevices
							propertyName: "playbackDevice"
						}
						Slider {
							id: speakerVolume
							Layout.fillWidth: true
							Layout.topMargin: 22 * DefaultStyle.dp
							from: 0.0
							to: 1.0
							value: SettingsCpp.playbackGain
							onMoved: {
								SettingsCpp.lSetPlaybackGain(value)
							}
						}
						Item {
							Layout.fillHeight: true
						}
					}
					ColumnLayout {
						Layout.fillWidth: true
						spacing: 0
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
								font: Typography.p2l
								color: DefaultStyle.main2_600
								Layout.fillWidth: true
								Layout.leftMargin: 9
							}
						}
						ComboSetting {
							Layout.fillWidth: true
							Layout.topMargin: 12 * DefaultStyle.dp
							Layout.bottomMargin: 22 * DefaultStyle.dp
							Layout.preferredWidth: parent.width
							model: SettingsCpp.captureDevices
							propertyName: "captureDevice"
						}
						Slider {
							id: microVolume
							Layout.fillWidth: true
							Layout.bottomMargin: 19 * DefaultStyle.dp
							from: 0.0
							to: 1.0
							value: SettingsCpp.captureGain
							onMoved: {
								SettingsCpp.lSetCaptureGain(value)
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
						Item {
							Layout.fillHeight: true
						}
					}
					ColumnLayout {
						Layout.fillWidth: true
						spacing: 0
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
								font: Typography.p2l
								color: DefaultStyle.main2_600
								Layout.fillWidth: true
								Layout.leftMargin: 9
							}
						}
						ComboSetting {
							Layout.fillWidth: true
							Layout.topMargin: 12 * DefaultStyle.dp
							Layout.preferredWidth: parent.width
							model: SettingsCpp.videoDevices
							propertyName: "videoDevice"
						}
						Item {
							Layout.fillHeight: true
						}
					}
					Connections {
						target: SettingsCpp
						function onMicVolumeChanged(volume) { audioTestSlider.value = volume}
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
		}
	}
}
