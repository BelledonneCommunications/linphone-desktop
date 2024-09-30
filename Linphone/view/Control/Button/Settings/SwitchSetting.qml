import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Linphone

RowLayout {
	id:mainItem
	property string titleText
	property string subTitleText
	property string propertyName
	property var propertyOwner
	property bool enabled: true
	spacing : 20 * DefaultStyle.dp
	Layout.minimumHeight: 32 * DefaultStyle.dp
	ColumnLayout {
		Text {
			text: titleText
			font: Typography.p2l
			wrapMode: Text.WordWrap
			color: DefaultStyle.main2_600
			Layout.fillWidth: true
		}
		Text {
			text: subTitleText
			font: Typography.p1
			wrapMode: Text.WordWrap
			visible: subTitleText.length > 0
			color: DefaultStyle.main2_600
			Layout.fillWidth: true
		}
	}
	Switch {
		id: switchButton
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		checked: propertyOwner[mainItem.propertyName]
		enabled: mainItem.enabled
		onToggled: {
			binding.when = true
		}
	}
	Binding {
		id: binding
		target: propertyOwner
		property: mainItem.propertyName
		value: switchButton.checked
		when: false
	}
}
