import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

RowLayout {
	id: mainItem
	height: Utils.getSizeWithScreenRatio(40)
	visible: eventLogGui.core.handled
	property EventLogGui eventLogGui

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
			text: mainItem.eventLogGui.core.eventDetails
			font: Typography.p3
			color: mainItem.eventLogGui.core.important ? DefaultStyle.danger_500_main : DefaultStyle.main2_500_main
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}
		Text {
			id: date
			text: UtilsCpp.toDateTimeString(mainItem.eventLogGui.core.timestamp)
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

