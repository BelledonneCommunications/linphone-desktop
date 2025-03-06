
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import UtilsCpp
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

	onSave: {
		SettingsCpp.save()
	}
	onUndo: SettingsCpp.undo()

	Component {
		id: confDisplayParametersComponent
		ColumnLayout {
            spacing: Math.round(5 * DefaultStyle.dp)
			Text {
				text: qsTr("Mode d’affichage par défaut")
				font {
                    pixelSize: Typography.p2l.pixelSize
                    weight: Typography.p2l.weight
				}
			}
			Text {
				text: qsTr("Le mode d’affichage des participants en réunions")
				font {
                    pixelSize: Typography.p1.pixelSize
                    weight: Typography.p1.weight
				}
			}
			ComboSetting {
				Layout.fillWidth: true
                Layout.topMargin: Math.round(12 * DefaultStyle.dp)
				Layout.preferredWidth: parent.width
				entries: SettingsCpp.conferenceLayouts
				propertyName: "conferenceLayout"
				propertyOwner: SettingsCpp
				textRole: 'display_name'
			}
		}
	}
}
