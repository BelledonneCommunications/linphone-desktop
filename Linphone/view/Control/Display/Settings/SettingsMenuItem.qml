import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
import CustomControls 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

Item {
	id: mainItem
    height: visible ? Utils.getSizeWithScreenRatio(50) : 0
	anchors.right: parent.right
	anchors.left: parent.left
	property bool keyboardOtherFocus: FocusHelper.keyboardFocus || FocusHelper.otherFocus

	property string titleText
	property bool isSelected: false
	
	signal selected()

	//: %1 settings
	Accessible.name: qsTr("setting_tab_accessible_name").arg(titleText)
	
	Keys.onPressed: (event)=>{
		if(event.key == Qt.Key_Space || event.key == Qt.Key_Return || event.key == Qt.Key_Enter){
			mainItem.selected()
		}
	}
	MouseArea {
		id: mouseArea
		hoverEnabled: true
		anchors.fill: parent
		Rectangle {
			id: background
			anchors.fill: parent
			color: mainItem.isSelected ? DefaultStyle.main2_200 : parent.containsMouse ? DefaultStyle.main2_100 : "transparent"
            radius: mainItem.height / 2
			bottomRightRadius: 0
			topRightRadius: 0
			visible: parent.containsMouse || mainItem.isSelected || mainItem.keyboardOtherFocus
			border.color: DefaultStyle.main2_900
			border.width: mainItem.keyboardOtherFocus ? Utils.getSizeWithScreenRatio(3) : 0
		}
		onClicked: {
			mainItem.selected()
		}
	}
	Text {
		anchors.margins: 25
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		text: mainItem.titleText
		font: Typography.h4
	}
	
}
