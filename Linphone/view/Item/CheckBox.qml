import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.CheckBox {
	id: mainItem
	
	indicator: Rectangle {
		implicitWidth: 18
		implicitHeight: 18
		x: (parent.width - width) / 2
		y: (parent.height - height) / 2
		radius: 3
		border.color: DefaultStyle.main1_500_main
		border.width: DefaultStyle.checkboxBorderWidth
		// color: mainItem.checked ? DefaultStyle.main1_500_main : "transparent"

		Text {
			visible: mainItem.checked
			text: "\u2714"
			font.pointSize: 18
			color: DefaultStyle.main1_500_main
			anchors.centerIn: parent
		}
	}
}
