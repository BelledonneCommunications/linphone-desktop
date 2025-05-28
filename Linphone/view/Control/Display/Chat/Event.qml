import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp

RowLayout {
	id: mainLayout
	height: 40 * DefaultStyle.dp
	visible: eventLogCore.handled
	property EventLogGui eventLogGui
	property var eventLogCore: eventLogGui.core

	Rectangle {
		height: 1
		Layout.fillWidth: true
		color: DefaultStyle.main2_200
	}

	ColumnLayout {
		Layout.rightMargin: 20 * DefaultStyle.dp
		Layout.leftMargin: 20 * DefaultStyle.dp
		Layout.alignment: Qt.AlignVCenter

		Text {
			id: message
			text: eventLogCore.eventDetails
			font: Typography.p3
			color: eventLogCore.important ? DefaultStyle.danger_500main : DefaultStyle.main2_500main
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}
		Text {
			id: date
			text: UtilsCpp.toDateTimeString(eventLogCore.timestamp)
			font: Typography.p3
			color: DefaultStyle.main2_500main
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}
	}

	Rectangle {
		height: 1
		Layout.fillWidth: true
		color: DefaultStyle.main2_200
	}
}

