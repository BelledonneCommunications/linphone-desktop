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
		border.color: DefaultStyle.checkboxBorderColor
		border.width: DefaultStyle.checkboxBorderWidth
		// color: checkbox.checked ? DefaultStyle.checkboxBorderColor : "transparent"

		Text {
			visible: mainItem.checked
			textItem.text: "\u2714"
			textItem.font.pointSize: 18
			textItem.color: DefaultStyle.checkboxBorderColor
			anchors.centerIn: parent
		}
	}
}
