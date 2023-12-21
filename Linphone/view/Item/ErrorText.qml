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
		pixelSize: 13 * DefaultStyle.dp
		weight: 600 * DefaultStyle.dp
	}
	states: [
		State{
			name: "Visible"
			PropertyChanges{target: mainItem; opacity: 1.0}
		},
		State{
			name:"Invisible"
			PropertyChanges{target: mainItem; opacity: 0.0}
		}
	]
	transitions: [
		Transition {
			from: "Visible"
			to: "Invisible"
			NumberAnimation {
				property: "opacity"
				duration: 1000
			}
			// NumberAnimation {
			// 	property: "visible"
			// 	duration: 1100
			// }
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
				errorText.state = "Visible"
			}
		}
	}
}