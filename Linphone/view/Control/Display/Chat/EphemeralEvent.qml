import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp

Rectangle {
	anchors.centerIn: parent
	property EventLogGui eventLogGui
	property var eventLogCore: eventLogGui.core
	visible: eventLogCore.handled
	height: row.height + 15 * DefaultStyle.dp
	width: row.width + 15 * DefaultStyle.dp
	radius: 10 * DefaultStyle.dp
	border.width: 2 * DefaultStyle.dp
	border.color: DefaultStyle.main2_200
	color: "transparent"
	RowLayout {
		id: row
		anchors.centerIn: parent
		EffectImage {
			Layout.preferredWidth: visible ? 20 * DefaultStyle.dp : 0
			Layout.preferredHeight: 20 * DefaultStyle.dp
			colorizationColor: DefaultStyle.main2_400
			imageSource: AppIcons.clockCountDown
			Layout.alignment: Qt.AlignHCenter
		}
		Text {
			id: message
			text: eventLogCore.eventDetails
			font: Typography.p3
			color: DefaultStyle.main2_400
		}
	}
}
