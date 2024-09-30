import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import Linphone

Text {
	id: mainItem
	color: DefaultStyle.danger_500main
	visible: false
	function clear() {
		autoHideErrorMessage.stop()
		text = ""
		mainItem.visible = false
	}
	function setText(text) {
		if (text.length === 0) {
			clear()
		} else {
			mainItem.visible = true
			mainItem.text = text
		}
	}
	font {
		pixelSize: 12 * DefaultStyle.dp
		weight: 300 * DefaultStyle.dp
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
