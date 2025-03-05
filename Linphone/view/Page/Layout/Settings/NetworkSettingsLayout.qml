
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
            //: "Réseau"
            title: qsTr("settings_network_title"),
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
				Layout.fillWidth: true
                //: "Autoriser l'IPv6"
                titleText: qsTr("settings_network_allow_ipv6")
				propertyName: "ipv6Enabled"
				propertyOwner: SettingsCpp
			}
		}
	}
}
