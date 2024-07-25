
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control
import SettingsCpp 1.0
import Linphone

AbstractDetailsLayout {
	Component {
		id: settings
		Column {
			spacing: 40 * DefaultStyle.dp
			SwitchSetting {
				titleText: qsTr("Chiffrer tous les fichiers")
				subTitleText: qsTr("Attention, vous ne pourrez pas revenir en arrière !")
				propertyName: "vfsEnabled"
				propertyOwner: SettingsCpp
			}
		}
	}
	component: settings
}
