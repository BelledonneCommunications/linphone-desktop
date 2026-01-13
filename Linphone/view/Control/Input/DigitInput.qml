import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.TextField {
	id: mainItem
    property real inputSize: Utils.getSizeWithScreenRatio(100)
	property bool isError: false
	color: activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_500_main
	validator: IntValidator{bottom: 0; top: 9}

	width: inputSize * 0.9
	height: inputSize
	horizontalAlignment: TextInput.AlignHCenter
	verticalAlignment: TextInput.AlignVCenter
	overwriteMode: true

	// just reserve the space for the background
	placeholderText: "0"
	placeholderTextColor: "transparent"

	// cursorVisible is overwritten on focus change so useless to hide the cursor
	cursorDelegate: Item{}

	// horizontalAlignment: Control.TextField.AlignHCenter
	font.family: DefaultStyle.defaultFont
	font.pixelSize: inputSize / 2
    font.weight: Utils.getSizeWithScreenRatio(300)

	background: Item {
		anchors.fill: parent
		// width: mainItem.inputSize * 0.9
		// height: mainItem.inputSize
		Rectangle {
			id: background
            border.width: Utils.getSizeWithScreenRatio(1)
			border.color: mainItem.isError
			? DefaultStyle.danger_500_main
			: mainItem.activeFocus 
				? DefaultStyle.main1_500_main 
				: DefaultStyle.main2_500_main
			radius: mainItem.inputSize * 0.15
			width: mainItem.inputSize * 0.9
			height: mainItem.inputSize
		}
		Rectangle {
			id: indicator
			visible: mainItem.activeFocus
			color: DefaultStyle.main1_500_main
            height : Utils.getSizeWithScreenRatio(1)
			width: mainItem.inputSize * 0.67
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.bottom: parent.bottom
            anchors.bottomMargin: Utils.getSizeWithScreenRatio(mainItem.inputSize / 8)
		}
	}
}
