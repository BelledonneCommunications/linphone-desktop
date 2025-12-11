import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

RowLayout {
	id:mainItem
	property string titleText
	property string subTitleText
	property string propertyName
	property var propertyOwner
	property var propertyOwnerGui
	property bool enabled: true
	property alias checked: switchButton.checked
    spacing : Utils.getSizeWithScreenRatio(20)

	signal toggled()

	ColumnLayout {
        Layout.minimumHeight: Utils.getSizeWithScreenRatio(32)
        spacing: Utils.getSizeWithScreenRatio(4)
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
		onToggled: {
			binding.when = true
			mainItem.toggled()
		}
		implicitHeight: Utils.getSizeWithScreenRatio(30)
		Accessible.name: "%1 %2".arg(mainItem.titleText).arg(mainItem.subTitleText)
	}
	Binding {
		id: binding
		target: propertyOwnerGui ? propertyOwnerGui.core : propertyOwner ? propertyOwner : null
		property: mainItem.propertyName
		value: switchButton.checked
		when: false
	}
}
