
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp 1.0
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	contentModel: [
		{
			title: "",
			subTitle: "",
			contentComponent: genericParametersComponent
		},
		{
            //: "Périphériques"
            title: qsTr("settings_call_devices_title"),
            //: "Vous pouvez modifier les périphériques de sortie audio, le microphone et la caméra de capture."
            subTitle: qsTr("settings_call_devices_subtitle"),
			contentComponent: multiMediaParametersComponent,
			customWidth: 540,
			customRightMargin: 36
		}
	]

	onSave: {
		SettingsCpp.save()
	}
	onUndo: SettingsCpp.undo()

	FileDialog {
		id: fileDialog
		currentFolder: SettingsCpp.ringtoneFolder
		onAccepted: SettingsCpp.ringtonePath = Utils.getSystemPathFromUri(selectedFile)
		nameFilters: ["WAV files (*.wav)", "MKV files (*.mkv)"]
		options: FileDialog.ReadOnly
	}

	// Generic call parameters
	//////////////////////////

    Component {
        id: genericParametersComponent
        ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(20)
            SwitchSetting {
                //: "Annulateur d'écho"
                titleText: qsTr("settings_calls_echo_canceller_title")
                //: "Évite que de l'écho soit entendu par votre correspondant"
                subTitleText: qsTr("settings_calls_echo_canceller_subtitle")
                propertyName: "echoCancellationEnabled"
                propertyOwner: SettingsCpp
            }
            SwitchSetting {
                Layout.fillWidth: true
                //: "Activer l’enregistrement automatique des appels"
                titleText: qsTr("settings_calls_auto_record_title")
                propertyName: "automaticallyRecordCallsEnabled"
                propertyOwner: SettingsCpp
                visible: !SettingsCpp.disableCallRecordings
            }
            SwitchSetting {
                //: Tonalités
                titleText: qsTr("settings_call_enable_tones_title")
                //: Activer les tonalités
                subTitleText: qsTr("settings_call_enable_tones_subtitle")
                propertyName: "callToneIndicationsEnabled"
                propertyOwner: SettingsCpp
            }
            SwitchSetting {
                //: "Autoriser la vidéo"
                titleText: qsTr("settings_calls_enable_video_title")
                propertyName: "videoEnabled"
                propertyOwner: SettingsCpp
            }
			DecoratedTextField {
				visible: !SettingsCpp.disableCommandLine
				Layout.fillWidth: true
				propertyName: "commandLine"
				propertyOwner: SettingsCpp
				//: Command line
				title: qsTr("settings_calls_command_line_title")
				placeHolder: qsTr("settings_calls_command_line_title_place_holder")
				useTitleAsPlaceHolder: false
				toValidate: true
			}
			RowLayout {
				ColumnLayout {
					Text {
						//: "Change ringtone"
						text: qsTr("settings_calls_change_ringtone_title")
						font: Typography.p2l
						Layout.fillWidth: true
					}
					RowLayout {
						spacing: Utils.getSizeWithScreenRatio(3)
						Text {
							//: Current ringtone :
							text: qsTr("settings_calls_current_ringtone_filename")
							font: Typography.p1
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
						}
						Text {
							text: SettingsCpp.ringtoneName.length !== 0 ? SettingsCpp.ringtoneName : ""
							font {
								pixelSize: Typography.p1.pixelSize
								// weight: Typography.p1.weight
								italic: true
							}
							color: DefaultStyle.main2_600
							Layout.fillWidth: true
						}
					}
				}
				Item{Layout.fillWidth: true}
				RoundButton {
					style: ButtonStyle.noBackground
					icon.source: AppIcons.arrowSquareOut
					onClicked: {
						fileDialog.open()
					}
					//: Choose ringtone file
					Accessible.name:qsTr("choose_ringtone_file_accessible_name")
				}
			}
		}
	}

	// Multimedia parameters
	////////////////////////

	Component {
		id: multiMediaParametersComponent
		MultimediaSettings {
			ringerDevicesVisible: true
			backgroundVisible: false
            spacing: Utils.getSizeWithScreenRatio(20)
		}
	}
}
