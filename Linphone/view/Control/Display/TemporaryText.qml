import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import Linphone

Text {
	id: mainItem
	color: DefaultStyle.danger_500main
	property bool isVisible: text.length > 0
	function clear() {
		autoHideErrorMessage.stop()
		text = ""
	}
	function setText(text) {
		if (text.length === 0) {
			clear()
		} else {
			mainItem.text = text
		}
	}
	font {
        pixelSize: Typography.b3.pixelSize
        weight: Typography.b3.weight
	}
	Timer {
		id: autoHideErrorMessage
		interval: 5000
		onTriggered: {
			mainItem.clear()
		}
	}

	onTextChanged: if (mainItem.text.length > 0) autoHideErrorMessage.restart()
}
