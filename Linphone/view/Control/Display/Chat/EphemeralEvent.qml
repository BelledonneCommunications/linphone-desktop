import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Rectangle {
	anchors.centerIn: parent
	property EventLogGui eventLogGui
	visible: eventLogGui.core.handled
	height: row.height + Utils.getSizeWithScreenRatio(15)
	width: row.width + Utils.getSizeWithScreenRatio(15)
	radius: Utils.getSizeWithScreenRatio(10)
	border.width: Utils.getSizeWithScreenRatio(2)
	border.color: DefaultStyle.main2_200
	color: "transparent"
	RowLayout {
		id: row
		anchors.centerIn: parent
		EffectImage {
			Layout.preferredWidth: visible ? Utils.getSizeWithScreenRatio(20) : 0
			Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
			colorizationColor: DefaultStyle.main2_400
			imageSource: AppIcons.clockCountDown
			Layout.alignment: Qt.AlignHCenter
		}
		Text {
			id: message
			text: eventLogGui.core.eventDetails
			font: Typography.p3
			color: DefaultStyle.main2_400
		}
	}
}
