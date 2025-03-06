import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import Linphone

Control.Popup{
	id: mainItem
	padding: 0
	property color underlineColor : DefaultStyle.main1_500_main
    property real radius: Math.round(16 * DefaultStyle.dp)
	property bool hovered: mouseArea.containsMouse

	background: Item{
		Rectangle {
			visible: mainItem.underlineColor != undefined
			width: mainItem.width
            height: mainItem.height + Math.round(2 * DefaultStyle.dp)
			color: mainItem.underlineColor
			radius: mainItem.radius
		}
		Rectangle{
			id: backgroundItem
			width: mainItem.width
			height: mainItem.height
			radius: mainItem.radius
			color: DefaultStyle.grey_0
			border.color: DefaultStyle.grey_0
		}
		MultiEffect {
			anchors.fill: backgroundItem
			source: backgroundItem
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: 0.1
		}
		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
		}
	}
}
