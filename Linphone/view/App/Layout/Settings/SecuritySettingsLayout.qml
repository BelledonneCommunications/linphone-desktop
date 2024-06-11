
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control

import Linphone

GenericSettingsLayout {
	Layout.fillWidth: true
	Layout.fillHeight: true
	Component {
		id: settings
		ColumnLayout {
			spacing: 40 * DefaultStyle.dp
			SwitchSetting {
				titleText: qsTr("Chiffrer tous les fichiers")
				subTitleText: qsTr("Attention, vous ne pourrez pas revenir en arrière !")
				propertyName: "vfsEnabled"
			}
		}
		
	}
	component: settings
}
