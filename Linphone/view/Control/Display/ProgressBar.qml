import QtQuick
import QtQuick.Controls.Basic
import Linphone

ProgressBar {
	id: mainItem

    padding: Math.round(3 * DefaultStyle.dp)
	
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
            pixelSize: Math.round(10 * DefaultStyle.dp)
            weight: Math.round(700 * DefaultStyle.dp)
			bold: true
        }
    }

	background: Rectangle {
		color: mainItem.backgroundColor
        radius: Math.round(50 * DefaultStyle.dp)
		anchors.fill: mainItem
		width: mainItem.width
		height: mainItem.height
	}
	contentItem: Item {
		id: content
		Rectangle {
			id: bar
			color: mainItem.innerColor
            radius: Math.round(50 * DefaultStyle.dp)
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
                pixelSize: Math.round(10 * DefaultStyle.dp)
                weight: Math.round(700 * DefaultStyle.dp)
            }
		}
	}
}
