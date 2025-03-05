
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
                //: "Chiffrer tous les fichiers"
                titleText: qsTr("settings_security_enable_vfs_title")
                //: "Attention, vous ne pourrez pas revenir en arrière !"
                subTitleText: qsTr("settings_security_enable_vfs_subtitle")
				propertyName: "vfsEnabled"
				propertyOwner: SettingsCpp
			}
		}
	}
}
