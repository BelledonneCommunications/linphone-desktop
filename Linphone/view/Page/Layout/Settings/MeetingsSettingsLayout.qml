
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import UtilsCpp
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	contentModel: [
		{
            //: "Affichage"
            title: qsTr("settings_meetings_display_title"),
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
            spacing: Utils.getSizeWithScreenRatio(5)
			Text {
                //: "Mode d’affichage par défaut"
                text: qsTr("settings_meetings_default_layout_title")
				font {
                    pixelSize: Typography.p2l.pixelSize
                    weight: Typography.p2l.weight
				}
			}
			Text {
                //: "Le mode d’affichage des participants en réunions"
                text: qsTr("settings_meetings_default_layout_subtitle")
				font {
                    pixelSize: Typography.p1.pixelSize
                    weight: Typography.p1.weight
				}
			}
			ComboSetting {
				Layout.fillWidth: true
                Layout.topMargin: Utils.getSizeWithScreenRatio(12)
				Layout.preferredWidth: parent.width
				entries: SettingsCpp.conferenceLayouts
				propertyName: "conferenceLayout"
				propertyOwner: SettingsCpp
				textRole: 'display_name'
			}
		}
	}
}
