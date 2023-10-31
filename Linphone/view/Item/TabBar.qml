import QtQuick 2.7 as Quick
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.TabBar {
	id: mainItem
	property var model
	readonly property int originX: count > 0 
							? itemAt(0).x 
							: 0
	spacing: 40
	wheelEnabled: true
	background: Quick.Item {
		id: tabBarBackground
		anchors.fill: parent

		Quick.Rectangle {
			id: barBG
			height: 4
			color: DefaultStyle.lightGrayColor
			anchors.bottom: parent.bottom
			width: parent.width
		}

		// Quick.Rectangle {
		// 	height: 4
		// 	color: DefaultStyle.orangeColor
		// 	anchors.bottom: parent.bottom
		// 	// anchors.left: mainItem.currentItem.left
		// 	// anchors.right: mainItem.currentItem.right
		// 	x: mainItem.currentItem 
		// 		? mainItem.currentItem.x - mainItem.originX
		// 		: 0
		// 	width: mainItem.currentItem ? mainItem.currentItem.width : 0
		// 	// clip: true
		// 	Quick.Behavior on x { Quick.NumberAnimation {duration: 100}}
		// 	Quick.Behavior on width {Quick.NumberAnimation {duration: 100}}
		// }
	}

	Quick.Repeater {
		model: mainItem.model
		Control.TabButton {
			required property string modelData
			required property int index
			// width: Math.min(txtMeter.advanceWidth, Math.max(50, mainItem.width - (x - mainItem.x)))
			width: txtMeter.advanceWidth
			hoverEnabled: true
			ToolTip {
				visible: tabText.truncated && hovered
				delay: 1000
				text: modelData
			}

			background: Quick.Item {
				anchors.fill: parent

				Quick.Rectangle {
					visible: mainItem.currentIndex === index
					height: 4
					color: DefaultStyle.orangeColor
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.right: parent.right
				}
			}

			contentItem: Quick.Text {
				id: tabText
				anchors.fill: parent
				font.bold: true
				color: mainItem.currentIndex === index ? DefaultStyle.defaultTextColor : DefaultStyle.disableTextColor
				font.family: DefaultStyle.defaultFont
				font.pointSize: DefaultStyle.tabButtonTextSize
				elide: Quick.Text.ElideRight
				maximumLineCount: 1
				text: txtMeter.elidedText
				// width: Math.min(txtMeter.advanceWidth, Math.max(50, mainItem.width - (x - mainItem.x)))
				bottomPadding: 5
			}

			Quick.TextMetrics {
				id: txtMeter
				font: tabText.font
				text: modelData
			}
		}
	}
}