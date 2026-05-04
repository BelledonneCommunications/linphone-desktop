import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
import QtQuick.Effects
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.CheckBox {
	id: mainItem
	hoverEnabled: enabled
	property bool keyboardFocus: FocusHelper.keyboardFocus
	indicator: Item{
        implicitWidth: Utils.getSizeWithScreenRatio(20)
        implicitHeight: Utils.getSizeWithScreenRatio(20)
		x: (parent.width - width) / 2
		y: (parent.height - height) / 2
		Rectangle {
			id: backgroundArea
			anchors.fill: parent	
            radius: Utils.getSizeWithScreenRatio(3)
			border.color: mainItem.keyboardFocus
				? DefaultStyle.main2_900
				: mainItem.hovered || mainItem.activeFocus 
					? DefaultStyle.main1_700
					: DefaultStyle.main1_500_main
            border.width: mainItem.hovered || mainItem.activeFocus || mainItem.keyboardFocus ? Utils.getSizeWithScreenRatio(3) : Utils.getSizeWithScreenRatio(2)
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
