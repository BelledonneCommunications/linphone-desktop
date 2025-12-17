import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle


IconLabelButton {
	id: mainItem

	property var accountGui
	property var presence
	signal click()
	
	style: ButtonStyle.hoveredBackgroundBis
    height: Utils.getSizeWithScreenRatio(22)
    radius: Utils.getSizeWithScreenRatio(5)
	text: UtilsCpp.getPresenceStatus(presence)
	textSize: Typography.p1.pixelSize
	textColor: UtilsCpp.getPresenceColor(mainItem.presence)
	textWeight: Typography.p1.weight
	icon.width: Utils.getSizeWithScreenRatio(11)
	icon.height: Utils.getSizeWithScreenRatio(11)
	icon.source: UtilsCpp.getPresenceIcon(mainItem.presence)
	Layout.fillWidth: true
	shadowEnabled: false
	padding: 0

	onClicked: {
		mainItem.accountGui.core.presence = mainItem.presence
		mainItem.click()
	}
}
