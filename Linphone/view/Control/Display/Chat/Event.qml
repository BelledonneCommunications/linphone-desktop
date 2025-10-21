import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

RowLayout {
	id: mainLayout
	height: Utils.getSizeWithScreenRatio(40)
	visible: eventLogCore.handled
	property EventLogGui eventLogGui
	property var eventLogCore: eventLogGui.core

	Rectangle {
		height: 1
		Layout.fillWidth: true
		color: DefaultStyle.main2_200
	}

	ColumnLayout {
		Layout.rightMargin: Utils.getSizeWithScreenRatio(20)
		Layout.leftMargin: Utils.getSizeWithScreenRatio(20)
		Layout.alignment: Qt.AlignVCenter

		Text {
			id: message
			text: eventLogCore.eventDetails
			font: Typography.p3
			color: eventLogCore.important ? DefaultStyle.danger_500_main : DefaultStyle.main2_500_main
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}
		Text {
			id: date
			text: UtilsCpp.toDateTimeString(eventLogCore.timestamp)
			font: Typography.p3
			color: DefaultStyle.main2_500_main
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

