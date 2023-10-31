import QtQuick 2.7
import QtQuick.Controls as Control
import Linphone
  
Control.ToolTip {
	id: mainItem
	delay: 1000
	clip: true
	background: Rectangle {
		id: tooltipBackground
		opacity: 0.7
		color: DefaultStyle.tooltipBackgroundColor
		radius: 15
	}
	contentItem: Text {
		textItem.text: mainItem.text
		textItem.color: DefaultStyle.defaultTextColor
		textItem.width: tooltipBackground.width
		textItem.wrapMode: Text.Wrap
		textItem.elide: Text.ElideRight
	}
}