
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone

AbstractSettingsLayout {
	width: parent?.width
	contentModel: [
		{
			title: "",
			subTitle: "",
			contentComponent: content
		}
	]
	Component {
		id: content
		ColumnLayout {
			spacing: 40 * DefaultStyle.dp
			SwitchSetting {
				titleText: qsTr("Chiffrer tous les fichiers")
				subTitleText: qsTr("Attention, vous ne pourrez pas revenir en arrière !")
				propertyName: "vfsEnabled"
				propertyOwner: SettingsCpp
			}
		}
	}
}
