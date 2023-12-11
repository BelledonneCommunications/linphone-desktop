import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.CheckBox {
	id: mainItem
	
	indicator: Rectangle {
		implicitWidth: 20 * DefaultStyle.dp
		implicitHeight: 20 * DefaultStyle.dp
		x: (parent.width - width) / 2
		y: (parent.height - height) / 2
		radius: 3 * DefaultStyle.dp
		border.color: DefaultStyle.main1_500_main
		border.width: 2 * DefaultStyle.dp
		// color: mainItem.checked ? DefaultStyle.main1_500_main : "transparent"
		EffectImage {
			visible: mainItem.checked
			image.source: AppIcons.check
			colorizationColor: DefaultStyle.main1_500_main
			anchors.fill: parent
		}
	}
}
