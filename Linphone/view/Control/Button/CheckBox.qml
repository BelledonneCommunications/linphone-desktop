import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
import QtQuick.Effects
 
Control.CheckBox {
	id: mainItem
	property bool shadowEnabled: mainItem.activeFocus || mainItem.hovered
	indicator: Item{
		implicitWidth: 20 * DefaultStyle.dp
		implicitHeight: 20 * DefaultStyle.dp
		x: (parent.width - width) / 2
		y: (parent.height - height) / 2
		Rectangle {
			id: backgroundArea
			anchors.fill: parent	
			radius: 3 * DefaultStyle.dp
			border.color: DefaultStyle.main1_500_main
			border.width: 2.2 * DefaultStyle.dp
			// color: mainItem.checked ? DefaultStyle.main1_500_main : "transparent"
			EffectImage {
				visible: mainItem.checked
				imageSource: AppIcons.check
				colorizationColor: DefaultStyle.main1_500_main
				anchors.fill: parent
			}
		}
		MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: backgroundArea
			source: backgroundArea
			visible:  mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
		}
	}
}
