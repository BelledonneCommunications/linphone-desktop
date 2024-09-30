import QtQuick
import QtQuick.Controls.Basic
import Linphone

ProgressBar {
	id: mainItem

	padding: 3 * DefaultStyle.dp
	
	property color backgroundColor: DefaultStyle.main2_100
	property color innerColor: DefaultStyle.info_500_main
	property color innerTextColor: DefaultStyle.grey_0
	property bool innerTextVisible: true
	property string innerText: Number.parseFloat(value*100).toFixed(0) + "%"

	background: Rectangle {
		color: mainItem.backgroundColor
		radius: 50 * DefaultStyle.dp
		anchors.fill: mainItem
		width: mainItem.width
		height: mainItem.height
	}
	contentItem: Item {
		Rectangle {
			color: mainItem.innerColor
			radius: 50 * DefaultStyle.dp
			width: mainItem.visualPosition * mainItem.width
			height: parent.height
			Text {
				visible: innerTextVisible && mainItem.value > 0
				text: mainItem.innerText
				anchors.centerIn: parent
				color: mainItem.innerTextColor
				font {
					pixelSize: 10 * DefaultStyle.dp
					weight: 700 * DefaultStyle.dp
				}
			}
		}
	}
}
