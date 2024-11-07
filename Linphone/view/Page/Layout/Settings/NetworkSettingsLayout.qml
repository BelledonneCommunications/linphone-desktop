
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone

AbstractSettingsLayout {
	width: parent?.width
	contentModel: [
		{
			title: qsTr("Réseau"),
			subTitle: "",
			contentComponent: content
		}
	]
	Component {
		id: content
		ColumnLayout {
			spacing: 40 * DefaultStyle.dp
			SwitchSetting {
				Layout.fillWidth: true
				titleText: qsTr("Autoriser l'IPv6")
				propertyName: "ipv6Enabled"
				propertyOwner: SettingsCpp
			}
		}
	}
}
