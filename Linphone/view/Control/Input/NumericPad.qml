import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts as Layout
import QtQuick.Effects
import Linphone
import UtilsCpp

FocusScope{
	id: mainItem

	property var currentCall
	property bool lastRowVisible: true

	onButtonPressed: (text) => {
		if (currentCall) currentCall.core.lSendDtmf(text)
		else UtilsCpp.playDtmf(text)
	}
	signal buttonPressed(string text)
	signal launchCall()
	signal wipe()

	function keypadKeyPressedAtIndex(index) {
		var button = numPadGrid.getButtonAt(index)
		button.shadowEnabled = true
		button.clicked()
		removeButtonsShadow.restart()
	}

	Timer {
		id: removeButtonsShadow
		interval: 250
		repeat: false
		onTriggered: {
			for (var i = 0; i < 12; i++) {
				numPadGrid.getButtonAt(i).shadowEnabled = false
			}
		}
	}

	Keys.onPressed: (event) => {
		if (event.modifiers & Qt.KeypadModifier) {
			if (event.key === Qt.Key_0) {
				keypadKeyPressedAtIndex(10)
			}
			if (event.key === Qt.Key_1) {
				keypadKeyPressedAtIndex(0)
			}
			if (event.key === Qt.Key_2) {
				keypadKeyPressedAtIndex(1)
			}
			if (event.key === Qt.Key_3) {
				keypadKeyPressedAtIndex(2)
			}
			if (event.key === Qt.Key_4) {
				keypadKeyPressedAtIndex(3)
			}
			if (event.key === Qt.Key_5) {
				keypadKeyPressedAtIndex(4)
			}
			if (event.key === Qt.Key_6) {
				keypadKeyPressedAtIndex(5)
			}
			if (event.key === Qt.Key_7) {
				keypadKeyPressedAtIndex(6)
			}
			if (event.key === Qt.Key_8) {
				keypadKeyPressedAtIndex(7)
			}
			if (event.key === Qt.Key_9) {
				keypadKeyPressedAtIndex(8)
			}
			if (event.key === Qt.Key_Asterisk) {
				keypadKeyPressedAtIndex(9)
			}
			if (event.key === Qt.Key_Plus) {
				mainItem.buttonPressed("+")
			}
			if (event.key === Qt.Key_Enter) {
				mainItem.launchCall()
			}
		}
		if (event.key === Qt.Key_Backspace) {
			mainItem.wipe()
		}
	}

	Layout.GridLayout {
		id: numPadGrid
		anchors.fill: parent
		columns: 3
		columnSpacing: 40 * DefaultStyle.dp
		rowSpacing: 10 * DefaultStyle.dp
		function getButtonAt(index){
			index = (index+15) % 15
			if(index >= 0){
				if( index < 9){
					return numPadRepeater.itemAt(index)
				}else if( index < 12){
					return digitRepeater.itemAt(index-9)
				}else if (index < 14){
					return launchCallButton
				}else if( index < 15){
					return eraseButton
				}
			}
		}
		Repeater {
			id: numPadRepeater
			model: 9
			Button {
				id: numPadButton
				Layout.Layout.alignment: Qt.AlignHCenter
				required property int index
				implicitWidth: 60 * DefaultStyle.dp
				implicitHeight: 60 * DefaultStyle.dp
				onClicked: {
					mainItem.buttonPressed(innerText.text)
				}
				KeyNavigation.left: numPadGrid.getButtonAt(index - 1)
				KeyNavigation.right: numPadGrid.getButtonAt(index + 1)
				KeyNavigation.up: numPadGrid.getButtonAt(index - 3)
				KeyNavigation.down: numPadGrid.getButtonAt(index + 3)
				background: Rectangle {
					anchors.fill: parent
					color: numPadButton.down  || numPadButton.shadowEnabled? DefaultStyle.numericPadPressedButtonColor : DefaultStyle.grey_0
					radius: 71 * DefaultStyle.dp
				}
				contentItem: Text {
					id: innerText
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					anchors.centerIn: parent
					text: index + 1
					font {
						pixelSize: 32 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
					}
				}
			}
		}
		Repeater {
			id: digitRepeater
			model: [
				{pressText: "*"},
				{pressText: "0", longPressText: "+"},
				{pressText: "#"}
			]
			Button {
				id: digitButton
				Layout.Layout.alignment: Qt.AlignHCenter
				implicitWidth: 60 * DefaultStyle.dp
				implicitHeight: 60 * DefaultStyle.dp
				
				onClicked: mainItem.buttonPressed(pressText.text)
				onPressAndHold: mainItem.buttonPressed(longPressText.text)
				
				KeyNavigation.left: numPadGrid.getButtonAt((index - 1)+9)
				KeyNavigation.right: numPadGrid.getButtonAt((index + 1)+9)
				KeyNavigation.up: numPadGrid.getButtonAt((index - 3)+9)
				KeyNavigation.down: numPadGrid.getButtonAt((index + 3)+9)

				background: Rectangle {
					anchors.fill: parent
					color: digitButton.down || digitButton.shadowEnabled? DefaultStyle.numericPadPressedButtonColor : DefaultStyle.grey_0
					radius: 71 * DefaultStyle.dp
				}
				contentItem: Item {
					anchors.fill: parent
					Text {
						id: pressText
						height: contentHeight
						anchors.left: parent.left
						anchors.right: parent.right
						horizontalAlignment: Text.AlignHCenter
						Component.onCompleted: {if (modelData.longPressText === undefined) anchors.centerIn= parent}
						text: modelData.pressText
						font.pixelSize: 32 * DefaultStyle.dp
					}
					Text {
						id: longPressText
						height: contentHeight
						anchors.left: parent.left
						anchors.right: parent.right
						y: digitButton.height/2
						horizontalAlignment: Text.AlignHCenter
						visible: modelData.longPressText ? modelData.longPressText.length > 0 : false
						text: modelData.longPressText ? modelData.longPressText : ""
						font.pixelSize: 22 * DefaultStyle.dp
					}
				}
			}
		}
		Item {
			visible: mainItem.lastRowVisible
			// Invisible item to move the last two buttons to the right
		}
		Button {
			id: launchCallButton
			visible: mainItem.lastRowVisible
			implicitWidth: 75 * DefaultStyle.dp
			implicitHeight: 55 * DefaultStyle.dp
			Layout.Layout.alignment: Qt.AlignHCenter
			icon.source: AppIcons.phone
			icon.width: 32 * DefaultStyle.dp
			icon.height: 32 * DefaultStyle.dp
			contentImageColor: DefaultStyle.grey_0
			
			onClicked: mainItem.launchCall()
			
			KeyNavigation.left: eraseButton
			KeyNavigation.right: eraseButton
			KeyNavigation.up: numPadGrid.getButtonAt(10)
			KeyNavigation.down: numPadGrid.getButtonAt(1)
			
			background: Rectangle {
				anchors.fill: parent
				color: DefaultStyle.success_500main
				radius: 71 * DefaultStyle.dp
			}
		}
		Button {
			id: eraseButton
			visible: mainItem.lastRowVisible
			leftPadding: 5 * DefaultStyle.dp
			rightPadding: 5 * DefaultStyle.dp
			topPadding: 5 * DefaultStyle.dp
			bottomPadding: 5 * DefaultStyle.dp
			Layout.Layout.alignment: Qt.AlignHCenter
			icon.source: AppIcons.backspaceFill
			icon.width: 38 * DefaultStyle.dp
			icon.height: 38 * DefaultStyle.dp
			
			onClicked: mainItem.wipe()
			
			KeyNavigation.left: launchCallButton
			KeyNavigation.right: launchCallButton
			KeyNavigation.up: numPadGrid.getButtonAt(11)
			KeyNavigation.down: numPadGrid.getButtonAt(1)
			
			background: Item {
				visible: false
			}
		}
	}
}
