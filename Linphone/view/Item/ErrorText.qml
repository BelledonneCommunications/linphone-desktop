import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import Linphone

Text {
	id: mainItem
	color: DefaultStyle.danger_500main
	opacity: 0
	font {
		pixelSize: 12 * DefaultStyle.dp
		weight: 300 * DefaultStyle.dp
	}
	states: [
		State{
			name: "Visible"
			PropertyChanges{target: mainItem; opacity: 1.0}
		},
		State{
			name:"Invisible"
			PropertyChanges{target: mainItem; opacity: 0.0; text: ""}
		}
	]
	transitions: [
		Transition {
			from: "Visible"
			to: "Invisible"
			NumberAnimation {
				property: "opacity"
				duration: 500
			}
		}
	]
	Timer {
		id: autoHideErrorMessage
		interval: 2500
		onTriggered: mainItem.state = "Invisible"
	}

	onOpacityChanged: if (opacity === 1) autoHideErrorMessage.restart()

	Connections {
		target: mainItem
		onTextChanged: {
			if (mainItem.text.length > 0) {
				mainItem.state = "Visible"
			} else {
				mainItem.state = "Invisible"
			}
		}
	}
}