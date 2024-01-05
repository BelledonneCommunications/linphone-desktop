import QtQuick
import QtQuick.Controls as Control
import QtQuick.Effects
import Linphone

Control.Popup{
	id: mainItem
	padding: 0
	property color underlineColor
	property int radius: 16 * DefaultStyle.dp
	background: Item{
		Rectangle {
			visible: mainItem.underlineColor != undefined
			width: mainItem.width
			height: mainItem.height + 2 * DefaultStyle.dp
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
			shadowColor: DefaultStyle.grey_900
			shadowBlur: 1.0
			shadowOpacity: 0.1
		}
	}
}
