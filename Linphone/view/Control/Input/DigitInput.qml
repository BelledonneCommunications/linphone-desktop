import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
  
Control.TextField {
	id: mainItem
    property real inputSize: Math.round(100 * DefaultStyle.dp)
	color: activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
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
    font.weight: Math.round(300 * DefaultStyle.dp)

	background: Item {
		anchors.fill: parent
		// width: mainItem.inputSize * 0.9
		// height: mainItem.inputSize
		Rectangle {
			id: background
            border.width: Math.round(Math.max(DefaultStyle.dp), 1)
			border.color: mainItem.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
			radius: mainItem.inputSize * 0.15
			width: mainItem.inputSize * 0.9
			height: mainItem.inputSize
		}
		Rectangle {
			id: indicator
			visible: mainItem.activeFocus
			color: DefaultStyle.main1_500_main
            height : Math.max(1, Math.round(1 * DefaultStyle.dp))
			width: mainItem.inputSize * 0.67
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.bottom: parent.bottom
            anchors.bottomMargin: Math.round((mainItem.inputSize / 8) * DefaultStyle.dp)
		}
	}
}
