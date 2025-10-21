
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

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
            spacing: Utils.getSizeWithScreenRatio(40)
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
