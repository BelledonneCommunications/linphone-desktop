import QtQuick
import QtQuick.Effects
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Control {
	id: mainItem
    // width: Utils.getSizeWithScreenRatio(269)
	y: -height
	z: 1
    topPadding: Utils.getSizeWithScreenRatio(8)
    bottomPadding: Utils.getSizeWithScreenRatio(8)
    leftPadding: Utils.getSizeWithScreenRatio(37)
    rightPadding: Utils.getSizeWithScreenRatio(37)
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
        border.width:  Utils.getSizeWithScreenRatio(1)
        radius: Utils.getSizeWithScreenRatio(50)
	}
	contentItem: RowLayout {
		Image {
			visible: mainItem.imageSource != undefined
			source: mainItem.imageSource
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
			fillMode: Image.PreserveAspectFit
			Layout.fillWidth: true
		}
		Text {
			color: mainItem.contentColor
			text: mainItem.text
			Layout.fillWidth: true
			font {
                pixelSize: Utils.getSizeWithScreenRatio(14)
			}
		}
	}
}
