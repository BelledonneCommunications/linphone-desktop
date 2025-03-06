import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
import QtQuick.Effects
 
Control.CheckBox {
	id: mainItem
	hoverEnabled: enabled
	indicator: Item{
        implicitWidth: Math.round(20 * DefaultStyle.dp)
        implicitHeight: Math.round(20 * DefaultStyle.dp)
		x: (parent.width - width) / 2
		y: (parent.height - height) / 2
		Rectangle {
			id: backgroundArea
			anchors.fill: parent	
            radius: Math.round(3 * DefaultStyle.dp)
			border.color: mainItem.hovered || mainItem.activeFocus ? DefaultStyle.main1_600 : DefaultStyle.main1_500_main
            border.width: Math.round(2 * DefaultStyle.dp)
			color: mainItem.checked ? DefaultStyle.main1_500_main : "transparent"
			EffectImage {
				visible: mainItem.checked
				imageSource: AppIcons.check
				colorizationColor: DefaultStyle.grey_0
				anchors.fill: parent
			}
		}
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
		acceptedButtons: Qt.NoButton
	}
}
