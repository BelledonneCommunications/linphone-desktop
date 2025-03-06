import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone

Item {
	id: mainItem
	
    height: visible ? Math.round(50 * DefaultStyle.dp) : 0
	anchors.right: parent.right
	anchors.left: parent.left

	property string titleText
	property bool isSelected: false
	property bool shadowEnabled: mainItem.activeFocus || mouseArea.containsMouse
	
	signal selected()
	
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
			color: DefaultStyle.main2_200
            radius: Math.round(35 * DefaultStyle.dp)
			visible: parent.containsMouse || isSelected || mainItem.shadowEnabled
		}
		Rectangle {
			id: backgroundRightFiller
			anchors.right: parent.right
			color: DefaultStyle.main2_200
            width: Math.round(35 * DefaultStyle.dp)
            height: Math.round(50 * DefaultStyle.dp)
			visible: parent.containsMouse || isSelected
		}
		// MultiEffect {
		// 	enabled: mainItem.shadowEnabled
		// 	anchors.fill: background
		// 	source: background
		// 	visible:  mainItem.shadowEnabled
		// 	// Crash : https://bugreports.qt.io/browse/QTBUG-124730
		// 	shadowEnabled: true //mainItem.shadowEnabled
		// 	shadowColor: DefaultStyle.grey_1000
		// 	shadowBlur: 0.1
		// 	shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
		// }
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
