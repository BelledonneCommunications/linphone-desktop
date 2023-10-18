import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.TabBar {
	id: bar
	spacing: 40

	function appendTab(label) {
		var newTab = tab.createObject(bar, {title: label, index: bar.count})
	}

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
			x: bar.currentItem ? bar.currentItem.x : 0
			width: bar.currentItem ? bar.currentItem.width : 0
			clip: true
			Behavior on x { NumberAnimation {duration: 100}}
		}
	}

	Component {
		id: tab
		Control.TabButton {
			property string title
			property int index
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
				text: title
			}
		}
	}
}