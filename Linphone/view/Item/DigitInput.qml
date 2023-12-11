import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.TextField {
	id: mainItem
	property int inputSize: 100 * DefaultStyle.dp
	color: activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
	rightPadding: width * 0.32
	leftPadding: width  * 0.32
	topPadding: height  * 0.2
	bottomPadding: height  * 0.2
	validator: IntValidator{bottom: 0; top: 9}
	// horizontalAlignment: TextInput.AlignHCenter
	// verticalAlignment: TextInput.AlignVCenter

	// just reserve the space for the background
	placeholderText: "0"
	placeholderTextColor: "transparent"

	// horizontalAlignment: Control.TextField.AlignHCenter
	font.family: DefaultStyle.defaultFont
	font.pixelSize: inputSize / 2
	font.weight: 300 * DefaultStyle.dp

	background: Rectangle {
		id: background
		border.width: Math.max(DefaultStyle.dp, 1)
		border.color: mainItem.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
		radius: mainItem.inputSize * 0.15
		width: mainItem.inputSize * 0.9
		height: mainItem.inputSize
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
	// 	color:DefaultStyle.main1_500_main
	// }
}
