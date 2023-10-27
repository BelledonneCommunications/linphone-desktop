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
	spacing: 40

	background: Item {
		anchors.fill: parent

		Rectangle {
			id: barBG
			height: 4
			color: DefaultStyle.lightGrayColor
			anchors.bottom: parent.bottom
			width: parent.width
		}

		Rectangle {
			height: 4
			color: DefaultStyle.orangeColor
			anchors.bottom: parent.bottom
			x: mainItem.currentItem 
					? mainItem.currentItem.x - mainItem.originX
					: 0
			width: mainItem.currentItem ? mainItem.currentItem.width : 0
			clip: true
			Behavior on x { NumberAnimation {duration: 100}}
			Behavior on width {NumberAnimation {duration: 100}}
		}
	}

	Repeater {
		model: mainItem.model
		Control.TabButton {
			required property string modelData
			width: txtMeter. advanceWidth

			background: Item {
				visible: false
			}

			contentItem: Text {
				id: tabText
				anchors.fill: parent
				font.bold: true
				font.pointSize: DefaultStyle.tabButtonTextSize
				text: txtMeter.text
				bottomPadding: 5
				width: txtMeter.advanceWidth
			}

			TextMetrics {
				id: txtMeter
				font: tabText.font
				text: modelData
			}
		}
	}
}