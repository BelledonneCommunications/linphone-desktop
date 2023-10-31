import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.TabBar {
	id: mainItem
	spacing: 40
	property color tabBarColor: DefaultStyle.verticalTabBarColor

	function appendTab(label) {
		var newTab = tab.createObject(mainItem, {title: label, index: mainItem.count})
	}

	contentItem: ListView {
		orientation: ListView.Vertical
		model: mainItem.model
	}

	background: Item {
		anchors.fill: parent

		Rectangle {
			id: barBG
			height: 4
			color: mainItem.tabBarColor
			anchors.bottom: parent.bottom
			width: parent.width
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