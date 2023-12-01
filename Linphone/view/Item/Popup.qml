import QtQuick
import QtQuick.Controls as Control
import QtQuick.Effects
import Linphone

Control.Popup{
	id: mainItem
	padding: 0
	background: Item{
		Rectangle{
			id: backgroundItem
			width: mainItem.width
			height: mainItem.height
			radius: 16 * DefaultStyle.dp
			border.color: DefaultStyle.grey_0
			border.width: 1
		}
		MultiEffect {
			anchors.fill: backgroundItem
			source: backgroundItem
			maskSource: backgroundItem
			shadowEnabled: true
			shadowBlur: 1.0
			shadowOpacity: 0.1
		}
	}
}
