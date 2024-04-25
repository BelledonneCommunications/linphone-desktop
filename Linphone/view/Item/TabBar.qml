import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.TabBar {
	id: mainItem
	property var model
	readonly property int originX: count > 0 
							? itemAt(0).x 
							: 0
	spacing: 40 * DefaultStyle.dp
	property int pixelSize: 22 * DefaultStyle.dp
	property int textWeight: 800 * DefaultStyle.dp
	wheelEnabled: true
	background: Item {
		id: tabBarBackground
		anchors.fill: parent

		Rectangle {
			id: barBG
			height: 4 * DefaultStyle.dp
			color: DefaultStyle.grey_200
			anchors.bottom: parent.bottom
			width: parent.width
		}

		// Rectangle {
		// 	height: 4
		// 	color: DefaultStyle.main1_500_main
		// 	anchors.bottom: parent.bottom
		// 	// anchors.left: mainItem.currentItem.left
		// 	// anchors.right: mainItem.currentItem.right
		// 	x: mainItem.currentItem 
		// 		? mainItem.currentItem.x - mainItem.originX
		// 		: 0
		// 	width: mainItem.currentItem ? mainItem.currentItem.width : 0
		// 	// clip: true
		// 	Behavior on x { NumberAnimation {duration: 100}}
		// 	Behavior on width {NumberAnimation {duration: 100}}
		// }
	}

	Repeater {
		model: mainItem.model
		Control.TabButton {
			required property string modelData
			required property int index
			width: implicitWidth
			hoverEnabled: true
			ToolTip {
				visible: tabText.truncated && hovered
				delay: 1000
				text: modelData
			}

			background: Item {
				anchors.fill: parent

				Rectangle {
					visible: mainItem.currentIndex === index
					height: 5 * DefaultStyle.dp
					color: DefaultStyle.main1_500_main
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.right: parent.right
				}
			}

			contentItem: Text {
				id: tabText
				width: Math.min(implicitWidth, mainItem.width / mainItem.model.length)
				font.weight: mainItem.textWeight
				color: mainItem.currentIndex === index ? DefaultStyle.main2_600 : DefaultStyle.main2_400
				font.family: DefaultStyle.defaultFont
				font.pixelSize: mainItem.pixelSize
				elide: Text.ElideRight
				maximumLineCount: 1
				text: modelData
				bottomPadding: 5 * DefaultStyle.dp
			}
		}
	}
}
