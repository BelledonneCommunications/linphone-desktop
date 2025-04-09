
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import SettingsCpp 1.0
import UtilsCpp

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

	// Generic call parameters
	//////////////////////////

    Component {
        id: genericParametersComponent
        ColumnLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
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
		}
	}

	// Multimedia parameters
	////////////////////////

	Component {
		id: multiMediaParametersComponent
		MultimediaSettings {
			ringerDevicesVisible: true
			backgroundVisible: false
            spacing: Math.round(20 * DefaultStyle.dp)
		}
	}
}
