
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	contentModel: [
		{
			title: qsTr("Affichage"),
			subTitle: "",
			contentComponent: confDisplayParametersComponent,
			hideTopMargin: true
		}
	]

	Component {
		id: confDisplayParametersComponent
		ColumnLayout {
			spacing: 5 * DefaultStyle.dp
			Text {
				text: qsTr("Mode d’affichage par défaut")
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 700 * DefaultStyle.dp
				}
			}
			Text {
				text: qsTr("Le mode d’affichage des participants en réunions")
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
			}
			ComboSetting {
				Layout.fillWidth: true
				Layout.topMargin: 12 * DefaultStyle.dp
				Layout.preferredWidth: parent.width
				entries: SettingsCpp.conferenceLayouts
				propertyName: "conferenceLayout"
				propertyOwner: SettingsCpp
				textRole: 'display_name'
			}
		}
	}
}
