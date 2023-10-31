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
		text: mainItem.text
		color: DefaultStyle.defaultTextColor
		width: tooltipBackground.width
		wrapMode: Text.Wrap
		elide: Text.ElideRight
	}
}