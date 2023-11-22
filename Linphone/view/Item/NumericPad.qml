import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
  
Control.Popup {
	clip: true
	id: mainItem
	signal buttonPressed(string text)
	signal launchCall()
	signal wipe()
	closePolicy: Control.Popup.CloseOnEscape
	leftPadding: closeButton.width
	rightPadding: closeButton.width
	rightInset: closeButton.width
	topPadding: closeButton.height
	background: Item {
		anchors.fill: parent
		Rectangle {
			id: numPadBackground
			anchors.fill: parent
			color: DefaultStyle.numericPadBackgroundColor
			radius: 10
		}
		MultiEffect {
			id: effect
			anchors.fill: parent
			source: numPadBackground
			shadowEnabled: true
			shadowColor: DefaultStyle.numericPadShadowColor
		}
		Button {
			id: closeButton
			anchors.right: parent.right
			anchors.top: parent.top
			background: Item {
				anchors.fill: parent
				visible: false
			}
			contentItem: Image {
				anchors.centerIn: parent
				source: AppIcons.closeX
				width: 10
				sourceSize.width: 10
				fillMode: Image.PreserveAspectFit
			}
			onClicked: mainItem.close()
		}
	}
	contentItem: GridLayout {
		columns: 3
		columnSpacing: 3
		Layout.fillWidth: true
		Layout.fillHeight: true
		Repeater {
			model: 9
			Button {
				id: numPadButton
				required property int index
				implicitWidth: 40
				implicitHeight: 40
				background: Rectangle {
					anchors.fill: parent
					color: numPadButton.down ? DefaultStyle.numericPadPressedButtonColor : DefaultStyle.grey_0
					radius: 20
				}
				contentItem: Text {
					id: innerText
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					anchors.fill: parent
					anchors.centerIn: parent
					text: index + 1
					font.pointSize: DefaultStyle.numericPadButtonTextSize
				}
				onClicked: {
					mainItem.buttonPressed(innerText.text)
				}
			}
		}
		Repeater {
			model: [
				{pressText: "*"},
				{pressText: "0", longPressText: "+"},
				{pressText: "#"}
			]
			Button {
				id: digitButton
				shadowEnabled: true
				implicitWidth: 40
				implicitHeight: 40
				background: Rectangle {
					anchors.fill: parent
					color: digitButton.down ? DefaultStyle.numericPadPressedButtonColor : DefaultStyle.grey_0
					radius: 20
				}
				contentItem: Item {
					anchors.fill: parent
					anchors.centerIn: parent
					Text {
						id: pressText
						anchors.left: parent.left
						anchors.right: parent.right
						horizontalAlignment: Text.AlignHCenter
						width: parent.width
						text: modelData.pressText
						font.pointSize: DefaultStyle.numericPadButtonTextSize
					}
					Text {
						id: longPressText
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.top: pressText.bottom
						horizontalAlignment: Text.AlignHCenter
						visible: modelData.longPressText ? modelData.longPressText.length > 0 : false
						text: modelData.longPressText ? modelData.longPressText : ""
						font.pointSize: DefaultStyle.numericPadButtonSubtextSize
					}
				}
				onClicked: mainItem.buttonPressed(pressText.text)
				onPressAndHold: mainItem.buttonPressed(longPressText.text)
			}
		}
		Item {
			// Invisible item to move the last two buttons to the right
		}
		Button {
			leftPadding: 20
			rightPadding: 20
			topPadding: 15
			bottomPadding: 15
			background: Rectangle {
				anchors.fill: parent
				color: DefaultStyle.launchCallButtonColor
				radius: 15
			}
			contentItem: EffectImage {
				id: buttonIcon
				image.source: AppIcons.phone
				anchors.fill: parent
				anchors.centerIn: parent
				width: 20
				height: 20
				image.fillMode: Image.PreserveAspectFit
				colorizationColor: DefaultStyle.grey_0
			}
			onClicked: mainItem.launchCall()
		}
		Button {
			leftPadding: 5
			rightPadding: 5
			topPadding: 5
			bottomPadding: 5
			background: Item {
				visible: false
			}
			contentItem: Image {
				source: AppIcons.backspaceFill
				anchors.centerIn: parent
			}
			onClicked: mainItem.wipe()
		}
	}
}