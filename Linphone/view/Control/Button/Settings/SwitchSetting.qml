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
	property var propertyOwnerGui
	property bool enabled: true
    spacing : Math.round(20 * DefaultStyle.dp)
	signal checkedChanged(bool checked)

	function setChecked(value) {
		switchButton.checked = value
	}

	ColumnLayout {
        Layout.minimumHeight: Math.round(32 * DefaultStyle.dp)
        spacing: Math.round(4 * DefaultStyle.dp)
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
		checked: propertyOwnerGui ? propertyOwnerGui.core[mainItem.propertyName]
						: propertyOwner ? propertyOwner[mainItem.propertyName] : false
		enabled: mainItem.enabled
		onCheckedChanged: mainItem.checkedChanged(checked)
		onToggled: binding.when = true
	}
	Binding {
		id: binding
		target: propertyOwnerGui ? propertyOwnerGui.core : propertyOwner ? propertyOwner : null
		property: mainItem.propertyName
		value: switchButton.checked
		when: false
	}
}
