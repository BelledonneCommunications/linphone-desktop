
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
			title: qsTr("Périphériques"),
			subTitle: qsTr("Vous pouvez modifier les périphériques de sortie audio, le microphone et la caméra de capture."),
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
			spacing: 20 * DefaultStyle.dp
			SwitchSetting {
				titleText: qsTr("Annulateur d'écho")
				subTitleText: qsTr("Évite que de l'écho soit entendu par votre correspondant")
				propertyName: "echoCancellationEnabled"
				propertyOwner: SettingsCpp
			}
			SwitchSetting {
				Layout.fillWidth: true
				titleText: qsTr("Activer l’enregistrement automatique des appels")
				subTitleText: qsTr("Enregistrer tous les appels par défaut")
				propertyName: "automaticallyRecordCallsEnabled"
				propertyOwner: SettingsCpp
				visible: !SettingsCpp.disableCallRecordings
			}
			SwitchSetting {
				titleText: qsTr("Tonalités")
				subTitleText: qsTr("Activer les tonalités")
				propertyName: "callToneIndicationsEnabled"
				propertyOwner: SettingsCpp
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
			spacing: 20 * DefaultStyle.dp
		}
	}
}
