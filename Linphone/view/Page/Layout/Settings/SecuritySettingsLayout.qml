
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone
import UtilsCpp

AbstractSettingsLayout {
	width: parent?.width
	contentModel: [
		{
			title: "",
			subTitle: "",
			contentComponent: content
		}
	]
	onSave: {
		SettingsCpp.save()
	}
	onUndo: SettingsCpp.undo()
	
	Component {
		id: content
		ColumnLayout {
            spacing: Math.round(40 * DefaultStyle.dp)
			SwitchSetting {
				titleText: qsTr("Chiffrer tous les fichiers")
				subTitleText: qsTr("Attention, vous ne pourrez pas revenir en arrière !")
				propertyName: "vfsEnabled"
				propertyOwner: SettingsCpp
			}
		}
	}
}
