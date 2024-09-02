import QtQuick 2.7
import QtQuick.Effects
import Linphone

Control.Control {
	id: mainItem
	// width: 269 * DefaultStyle.dp
	y: -height
	z: 1
	topPadding: 8 * DefaultStyle.dp
	bottomPadding: 8 * DefaultStyle.dp
	leftPadding: 37 * DefaultStyle.dp
	rightPadding: 37 * DefaultStyle.dp
	anchors.horizontalCenter: parent.horizontalCenter
	clip: true

	property string text
	property string imageSource
	property color contentColor
	property int yCoord

	signal clicked()

	function open() {
		y = mainItem.yCoord
		autoCloseNotification.restart()
	}
	MouseArea {
		anchors.fill: parent
		onClicked: mainItem.clicked()
	}
	Timer {
		id: autoCloseNotification
		interval: 4000
		onTriggered: {
			mainItem.y = -mainItem.height
		}
	}
	Behavior on y {NumberAnimation {duration: 1000}}
	background: Rectangle {
		anchors.fill: parent
		color: DefaultStyle.grey_0
		border.color: mainItem.contentColor
		border.width:  1 * DefaultStyle.dp
		radius: 50 * DefaultStyle.dp
	}
	contentItem: RowLayout {
		Image {
			visible: mainItem.imageSource != undefined
			source: mainItem.imageSource
			Layout.preferredWidth: 24 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			Layout.fillWidth: true
		}
		Text {
			color: mainItem.contentColor
			text: mainItem.text
			Layout.fillWidth: true
			font {
				pixelSize: 14 * DefaultStyle.dp
			}
		}
	}
}