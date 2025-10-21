import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.ProgressBar {
	id: mainItem

    padding: Utils.getSizeWithScreenRatio(3)
	
	property color backgroundColor: DefaultStyle.main2_100
	property color innerColor: DefaultStyle.info_500_main
	property color innerTextColor: centeredText ? DefaultStyle.info_500_main : DefaultStyle.grey_0
	property bool innerTextVisible: true
    property string innerText: Number.parseFloat(value*100).toFixed(0) + "%"
    property real barWidth: mainItem.visualPosition * mainItem.width
	property bool centeredText: textSize.width >= barWidth

    TextMetrics{
        id: textSize
        text: mainItem.innerText
        font {
            pixelSize: Utils.getSizeWithScreenRatio(10)
            weight: Utils.getSizeWithScreenRatio(700)
			bold: true
        }
    }

	background: Rectangle {
		color: mainItem.backgroundColor
        radius: Utils.getSizeWithScreenRatio(50)
		anchors.fill: mainItem
		width: mainItem.width
		height: mainItem.height
	}
	contentItem: Item {
		id: content
		Rectangle {
			id: bar
			color: mainItem.innerColor
            radius: Utils.getSizeWithScreenRatio(50)
			width: mainItem.barWidth
			height: parent.height
		}
		Text {
			visible: mainItem.innerTextVisible
			text: mainItem.innerText
			parent: mainItem.centeredText ? content : bar
			anchors.fill: parent
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			color: mainItem.innerTextColor
			maximumLineCount: 1
			font {
                pixelSize: Utils.getSizeWithScreenRatio(10)
                weight: Utils.getSizeWithScreenRatio(700)
            }
		}
	}
}
