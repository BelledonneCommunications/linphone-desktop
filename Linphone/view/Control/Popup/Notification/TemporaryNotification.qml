import QtQuick
import QtQuick.Effects
import Linphone

Control.Control {
	id: mainItem
    // width: Math.round(269 * DefaultStyle.dp)
	y: -height
	z: 1
    topPadding: Math.round(8 * DefaultStyle.dp)
    bottomPadding: Math.round(8 * DefaultStyle.dp)
    leftPadding: Math.round(37 * DefaultStyle.dp)
    rightPadding: Math.round(37 * DefaultStyle.dp)
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
        border.width:  Math.max(Math.round(1 * DefaultStyle.dp), 1)
        radius: Math.round(50 * DefaultStyle.dp)
	}
	contentItem: RowLayout {
		Image {
			visible: mainItem.imageSource != undefined
			source: mainItem.imageSource
            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
			fillMode: Image.PreserveAspectFit
			Layout.fillWidth: true
		}
		Text {
			color: mainItem.contentColor
			text: mainItem.text
			Layout.fillWidth: true
			font {
                pixelSize: Math.round(14 * DefaultStyle.dp)
			}
		}
	}
}
