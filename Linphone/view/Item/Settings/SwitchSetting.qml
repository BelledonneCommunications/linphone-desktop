import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0

RowLayout {
	id:mainItem
	property string titleText
	property string subTitleText
	property string propertyName
	property bool enabled: true
	spacing : 20 * DefaultStyle.dp
	property int textWidth: 286 * DefaultStyle.dp
	ColumnLayout {
		Layout.preferredWidth: textWidth
		Text {
			text: titleText
			font: Typography.p2
			wrapMode: Text.WordWrap
			Layout.maximumWidth: textWidth
		}
		Text {
			text: subTitleText
			font: Typography.p1
			wrapMode: Text.WordWrap
			Layout.maximumWidth: textWidth
			visible: subTitleText.length > 0
		}
	}
	SwitchButton {
		id: switchButton
		Layout.alignment: Qt.AlignRight
		checked: SettingsCpp[mainItem.propertyName]
		enabled: mainItem.enabled
		onToggled: {
			binding.when = true
		}
	}
	Binding {
		id: binding
		target: SettingsCpp
		property: mainItem.propertyName
		value: switchButton.checked
		when: false
	}
}
