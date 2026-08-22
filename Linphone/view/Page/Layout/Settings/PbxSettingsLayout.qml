import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import SettingsCpp 1.0
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width

	contentModel: [
		{
			title: "",
			subTitle: "",
			contentComponent: parametersComponent
		}
	]

	onSave: SettingsCpp.save()
	onUndo: SettingsCpp.undo()

	Component {
		id: parametersComponent
		ColumnLayout {
			spacing: Utils.getSizeWithScreenRatio(20)
			Text {
				Layout.fillWidth: true
				wrapMode: Text.WordWrap
				//: "Utilisé pour le statut BLF en ligne/hors ligne et l'import des interlocuteurs"
				text: qsTr("settings_pbx_description")
				font {
					pixelSize: Typography.p2l.pixelSize
					weight: Typography.p2l.weight
				}
			}
			DecoratedTextField {
				id: pbxApiBaseUrlField
				Layout.fillWidth: true
				propertyName: "pbxApiBaseUrl"
				propertyOwner: SettingsCpp
				//: "URL du PBX"
				title: qsTr("settings_pbx_base_url_title")
				placeHolder: "https://pbx.example.com"
				useTitleAsPlaceHolder: false
			}
			DecoratedTextField {
				id: pbxApiKeyField
				Layout.fillWidth: true
				propertyName: "pbxApiKey"
				propertyOwner: SettingsCpp
				//: "Clé API"
				title: qsTr("settings_pbx_api_key_title")
				useTitleAsPlaceHolder: true
				hidden: true
			}
		}
	}
}
