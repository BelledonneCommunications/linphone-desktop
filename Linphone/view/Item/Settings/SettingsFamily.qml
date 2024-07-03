import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import Linphone

Rectangle {

	id: mainItem
	
	height: visible ? 50 * DefaultStyle.dp : 0
	anchors.right: parent.right
	anchors.left: parent.left

	property string titleText
	property bool isSelected: false
	
	signal selected()
	
	MouseArea {
		hoverEnabled: true
		anchors.fill: parent
		Rectangle {
			id: background
			anchors.fill: parent
			color: DefaultStyle.main2_200
			radius: 35 * DefaultStyle.dp
			visible: parent.containsMouse || isSelected
		}
		Rectangle {
			id: backgroundRightFiller
			anchors.right: parent.right
			color: DefaultStyle.main2_200
			width: 35 * DefaultStyle.dp
			height: 50 * DefaultStyle.dp
			visible: parent.containsMouse || isSelected
		}
		onClicked: {
			mainItem.selected()
		}
	}
	Text {
		anchors.margins: 25
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		text: titleText
		font: Typography.h4
	}
	
	
}
