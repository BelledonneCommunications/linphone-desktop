import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.TextField {
	id: mainItem
	property int inputSize: 60
	color: activeFocus ? DefaultStyle.digitInputFocusedColor : DefaultStyle.digitInputColor
	rightPadding: inputSize / 4
	leftPadding: inputSize / 4
	validator: IntValidator{bottom: 0; top: 9}

	// just reserve the space for the background
	placeholderText: "0"
	placeholderTextColor: "transparent"

	// horizontalAlignment: Control.TextField.AlignHCenter
	font.family: DefaultStyle.defaultFont
	font.pointSize: inputSize / 1.5

	background: Rectangle {
		// id: background
		border.color: mainItem.activeFocus ? DefaultStyle.digitInputFocusedColor : DefaultStyle.digitInputColor
		radius: mainItem.inputSize / 8
	}
	// cursorDelegate: Rectangle {
	// 	visible: mainItem.activeFocus
	// 	// width: mainItem.cursorRectangle.width
	// 	// height: mainItem.cursorRectangle.height - inputSize/5
	// 	x: background.x
	// 	y: background.height - inputSize/8
	// 	transform: Rotation {angle: -90}
	// 	// anchors.bottom: parent.bottom
	// 	// anchors.left: parent.left
	// 	// anchors.bottomMargin: inputSize/8
	// 	// transform: [/*Translate {x: mainItem.cursorRectangle.height},*/ Rotation {angle: -90}]
	// 	color:DefaultStyle.digitInputFocusedColor
	// }
}
