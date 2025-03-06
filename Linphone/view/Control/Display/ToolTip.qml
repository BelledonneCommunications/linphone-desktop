import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
  
Control.ToolTip {
	id: mainItem
	delay: 1000
	clip: true
	background: Rectangle {
		id: tooltipBackground
		opacity: 0.7
		color: DefaultStyle.main2_200
        radius: Math.round(15 * DefaultStyle.dp)
	}
	contentItem: Text {
		text: mainItem.text
		color: DefaultStyle.main2_600
		width: tooltipBackground.width
		wrapMode: Text.Wrap
		elide: Text.ElideRight
	}
}
