import QtQuick 2.7 as QT
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
	background: QT.Item {
		id: tabBarBackground
		anchors.fill: parent

		QT.Rectangle {
			id: barBG
			height: 4
			color: DefaultStyle.lightGrayColor
			anchors.bottom: parent.bottom
			width: parent.width
		}

		// QT.Rectangle {
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
		// 	QT.Behavior on x { QT.NumberAnimation {duration: 100}}
		// 	QT.Behavior on width {QT.NumberAnimation {duration: 100}}
		// }
	}

	QT.Repeater {
		model: mainItem.model
		Control.TabButton {
			required property string modelData
			required property int index
			width: Math.min(txtMeter.advanceWidth, Math.max(50, mainItem.width - (x - mainItem.x)))
			hoverEnabled: true
			ToolTip {
				visible: tabText.truncated && hovered
				delay: 1000
				text: modelData
			}

			background: QT.Item {
				anchors.fill: parent

				QT.Rectangle {
					visible: mainItem.currentIndex === index
					height: 4
					color: DefaultStyle.orangeColor
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.right: parent.right
				}
			}

			contentItem: QT.Text {
				id: tabText
				anchors.fill: parent
				font.bold: true
				color: DefaultStyle.defaultTextColor
				font.family: DefaultStyle.defaultFont
				font.pointSize: DefaultStyle.tabButtonTextSize
				elide: QT.Text.ElideRight
				maximumLineCount: 1
				text: txtMeter.elidedText
				// width: Math.min(txtMeter.advanceWidth, Math.max(50, mainItem.width - (x - mainItem.x)))
				bottomPadding: 5
			}

			QT.TextMetrics {
				id: txtMeter
				font: tabText.font
				text: modelData
			}
		}
	}
}